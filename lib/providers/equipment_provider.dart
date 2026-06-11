import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/character_data.dart';
import '../models/equipment.dart';
import '../models/inventory.dart';
import '../services/character_storage.dart';
import '../services/database_service.dart';
import '../services/equipment_dao.dart';
import '../services/inventory_dao.dart';
import 'character_provider.dart';
import 'combat_stats_provider.dart';
import 'inventory_provider.dart';

/// 装备状态
class EquipmentNotifier extends StateNotifier<Equipment> {
  final int slot;
  final Ref _ref; // 用于访问 inventoryProvider

  EquipmentNotifier(this.slot, this._ref) : super(Equipment(slot: slot)) {
    _load();
  }

  Future<void> _load() async {
    state = await EquipmentDao.load(slot);
  }

  /// 穿戴装备。背包扣除 + 装备槽更换在同一事务中完成，防丢件。
  Future<bool> equip(String equipType, InventorySlot bagSlot) async {
    final equipCopy = state.copy();
    final old = equipCopy.equip(equipType, bagSlot);

    // 先在内存中完成所有变更
    final invCopy = _ref.read(inventoryProvider(slot)).copy();
    if (!invCopy.removeItemBySlot(bagSlot.slotIdx, 1)) return false;

    // ⚠️ 背包满预检：旧装备退回需要 1 个空位
    if (old != null) {
      final left = invCopy.addItem(old.itemId, 1, data: old.data);
      if (left > 0) return false; // 背包满，拒绝替换
    }

    // 同一事务存盘：背包 + 装备 双写
    try {
      await DatabaseService.transaction<bool>((txn) async {
        await InventoryDao.saveAll(slot, invCopy, txn: txn);
        await EquipmentDao.saveAll(slot, equipCopy, txn: txn);
        return true;
      });
    } catch (_) {
      return false; // 回滚，内存也不更新
    }

    // 事务成功才更新 state
    _ref.read(inventoryProvider(slot).notifier).refresh();
    state = equipCopy;
    // 穿戴后截断当前 HP/Qi（防刷血）
    _clampHpQi();
    return true;
  }

  /// 卸下装备。退回背包，背包满则失败。
  Future<bool> unequip(String equipType) async {
    final equipCopy = state.copy();
    final item = equipCopy.unequip(equipType);
    if (item == null) return false;

    final invCopy = _ref.read(inventoryProvider(slot)).copy();
    final left = invCopy.addItem(item.itemId, 1, data: item.data);
    if (left > 0) return false; // 背包满

    try {
      await DatabaseService.transaction<bool>((txn) async {
        await InventoryDao.saveAll(slot, invCopy, txn: txn);
        await EquipmentDao.saveAll(slot, equipCopy, txn: txn);
        return true;
      });
    } catch (_) {
      return false;
    }

    _ref.read(inventoryProvider(slot).notifier).refresh();
    state = equipCopy;
    return true;
  }

  void refresh() => _load();

  /// 截断当前 HP/Qi 不超过上限（防穿脱装备刷血）
  Future<void> _clampHpQi() async {
    final charAsync = _ref.read(characterProvider(slot));
    charAsync.whenData((char) {
      if (char == null) return;
      final combat = _ref.read(combatStatsProvider((slot: slot, char: char)));
      if (char.currentHp > combat.maxHp || char.currentQi > combat.maxQi) {
        final clamped = char.copyWith(
          currentHp: char.currentHp > combat.maxHp ? combat.maxHp : char.currentHp,
          currentQi: char.currentQi > combat.maxQi ? combat.maxQi : char.currentQi,
        );
        CharacterStorage.save(slot, clamped);
      }
    });
  }
}

final equipmentProvider =
    StateNotifierProvider.family<EquipmentNotifier, Equipment, int>((ref, slot) {
  return EquipmentNotifier(slot, ref);
});
