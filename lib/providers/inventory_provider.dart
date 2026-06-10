import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/inventory.dart';
import '../services/inventory_dao.dart';

/// 背包状态
class InventoryNotifier extends StateNotifier<Inventory> {
  final int slot;

  InventoryNotifier(this.slot) : super(Inventory()) {
    _load();
  }

  Future<void> _load() async {
    state = await InventoryDao.load(slot);
  }

  /// 添加物品。返回未能放入的溢出数量（0=全部成功）。
  Future<int> addItem(String itemId, int count, {String? data}) async {
    final inv = state.copy();
    final left = inv.addItem(itemId, count, data: data);
    state = inv;
    await InventoryDao.saveAll(slot, state);
    return left;
  }

  Future<bool> removeItem(String itemId, int count) async {
    final inv = state.copy();
    final ok = inv.removeItem(itemId, count);
    if (ok) {
      state = inv;
      await InventoryDao.saveAll(slot, state);
    }
    return ok;
  }

  /// 按槽位精确删除（防误删极品）
  Future<bool> removeItemBySlot(int slotIdx, int count) async {
    final inv = state.copy();
    final ok = inv.removeItemBySlot(slotIdx, count);
    if (ok) {
      state = inv;
      await InventoryDao.saveAll(slot, state);
    }
    return ok;
  }

  /// 交换两个槽位
  Future<void> swapSlots(int a, int b) async {
    final inv = state.copy();
    inv.swapSlots(a, b);
    state = inv;
    await InventoryDao.saveAll(slot, state);
  }

  /// 一键整理
  Future<void> compact() async {
    final inv = state.copy();
    inv.compact();
    state = inv;
    await InventoryDao.saveAll(slot, state);
  }

  void refresh() {
    _load();
  }
}

final inventoryProvider =
    StateNotifierProvider.family<InventoryNotifier, Inventory, int>(
  (ref, slot) => InventoryNotifier(slot),
);
