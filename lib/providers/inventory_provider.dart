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
    if (count <= 0) return 0;
    final inv = state.copy();
    final left = inv.addItem(itemId, count, data: data);
    // 仅在真实写入时才触发刷新和存盘
    if (left < count) {
      state = inv;
      await InventoryDao.saveAll(slot, state);
    }
    return left;
  }

  /// 批量添加。内存一次结算 → 单次 state 刷新 → 单次 DB 写入。
  /// 防并发覆盖（一键拾取安全）。
  Future<int> addItems(List<({String itemId, int count, String? data})> items) async {
    if (items.isEmpty) return 0;
    final inv = state.copy();
    final totalLeft = inv.addItems(items);
    if (totalLeft < items.fold<int>(0, (p, i) => p + i.count)) {
      state = inv;
      await InventoryDao.saveAll(slot, state);
    }
    return totalLeft;
  }

  Future<bool> removeItem(String itemId, int count) async {
    if (count <= 0) return true;
    final inv = state.copy();
    final ok = inv.removeItem(itemId, count);
    if (ok) {
      inv.compact(); // 自动消除空洞
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
      inv.compact(); // 自动消除空洞
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
