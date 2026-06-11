import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/equipment.dart';
import '../models/inventory.dart';
import '../services/database_service.dart';
import '../services/equipment_dao.dart';
import '../services/inventory_dao.dart';
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
    final invNotifier = _ref.read(inventoryProvider(slot).notifier);
    final equipCopy = state.copy();
    final old = equipCopy.equip(equipType, bagSlot);

    // 先在内存中完成所有变更
    final invCopy = _ref.read(inventoryProvider(slot)).copy();
    if (!invCopy.removeItemBySlot(bagSlot.slotIdx, 1)) return false;
    if (old != null) invCopy.addItem(old.itemId, 1, data: old.data);

    // 同一事务存盘：背包 + 装备 双写
    try {
      await DatabaseService.transaction<bool>(() async {
        await InventoryDao.saveAll(slot, invCopy);
        await EquipmentDao.saveAll(slot, equipCopy);
        return true;
      });
    } catch (_) {
      return false; // 回滚，内存也不更新
    }

    // 事务成功才更新 state
    _ref.read(inventoryProvider(slot).notifier).refresh();
    state = equipCopy;
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
      await DatabaseService.transaction<bool>(() async {
        await InventoryDao.saveAll(slot, invCopy);
        await EquipmentDao.saveAll(slot, equipCopy);
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
}

final equipmentProvider =
    StateNotifierProvider.family<EquipmentNotifier, Equipment, int>((ref, slot) {
  return EquipmentNotifier(slot, ref);
});
