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
    // 先复制一份再操作，触发 UI 刷新，后台持久化
    final copy = Inventory.fromSlotList(state.toList(), capacity: state.capacity);
    copy.addItem(itemId, count);
    state = copy;
    await InventoryDao.saveAll(slot, state);
  }

  Future<bool> removeItem(String itemId, int count) async {
    final copy = Inventory.fromSlotList(state.toList(), capacity: state.capacity);
    final ok = copy.removeItem(itemId, count);
    if (ok) {
      state = copy;
      await InventoryDao.saveAll(slot, state);
    }
    return ok;
  }

  void refresh() {
    _load();
  }
}

final inventoryProvider =
    StateNotifierProvider.autoDispose.family<InventoryNotifier, Inventory, int>(
  (ref, slot) => InventoryNotifier(slot),
);
