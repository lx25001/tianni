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
    final inv = state.copy();
    inv.addItem(itemId, count);
    state = inv;
    await InventoryDao.saveAll(slot, state);
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

  void refresh() {
    _load();
  }
}

final inventoryProvider =
    StateNotifierProvider.family<InventoryNotifier, Inventory, int>(
  (ref, slot) => InventoryNotifier(slot),
);
