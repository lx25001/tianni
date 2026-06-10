import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/equipment.dart';
import '../models/inventory.dart';
import '../services/equipment_dao.dart';
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

  /// 穿戴装备。从背包扣除 1 个，旧装备退回背包。
  Future<bool> equip(String equipType, InventorySlot bagSlot) async {
    // 从背包精确扣除
    final ok = await _ref.read(inventoryProvider(slot).notifier).removeItemBySlot(bagSlot.slotIdx, 1);
    if (!ok) return false;

    final copy = state.copy();
    final old = copy.equip(equipType, bagSlot);
    state = copy;
    await EquipmentDao.saveAll(slot, state);

    // 旧装备退回背包
    if (old != null) {
      await _ref.read(inventoryProvider(slot).notifier).addItem(old.itemId, 1, data: old.data);
    }
    return true;
  }

  /// 卸下装备。退回背包，背包满则失败。
  Future<bool> unequip(String equipType) async {
    final copy = state.copy();
    final item = copy.unequip(equipType);
    if (item == null) return false;

    final left = await _ref.read(inventoryProvider(slot).notifier).addItem(item.itemId, 1, data: item.data);
    if (left > 0) return false; // 背包满，无法卸下

    state = copy;
    await EquipmentDao.saveAll(slot, state);
    return true;
  }

  void refresh() => _load();
}

final equipmentProvider =
    StateNotifierProvider.family<EquipmentNotifier, Equipment, int>((ref, slot) {
  return EquipmentNotifier(slot, ref);
});
