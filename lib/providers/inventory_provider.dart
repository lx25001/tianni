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

  Future<void> addItem(String itemId, int count) async {
    state.addItem(itemId, count);
    await _save();
  }

  Future<bool> removeItem(String itemId, int count) async {
    final ok = state.removeItem(itemId, count);
    if (ok) await _save();
    return ok;
  }

  Future<void> _save() async {
    await InventoryDao.saveAll(slot, state);
    // 强制通知监听器（对象引用未变时也刷新）
    state = Inventory.fromSlotList(state.toList(), capacity: state.capacity);
  }

  void refresh() {
    _load();
  }
}

final inventoryProvider =
    StateNotifierProvider.autoDispose.family<InventoryNotifier, Inventory, int>(
  (ref, slot) => InventoryNotifier(slot),
);
