import '../models/inventory.dart';
import 'database_service.dart';

/// 背包数据访问层
class InventoryDao {
  static const _table = 'inventory_slot';

  static Future<void> saveAll(int slot, Inventory inv) async {
    final db = await DatabaseService.db;
    await db.transaction((txn) async {
      // 清空旧数据
      await txn.delete(_table, where: 'slot = ?', whereArgs: [slot]);
      // 插入新数据
      for (final s in inv.slots) {
        if (s == null) continue;
        await txn.insert(_table, {
          'slot': slot,
          'item_id': s.itemId,
          'count': s.count,
          'slot_idx': s.slotIdx,
        });
      }
    });
  }

  static Future<Inventory> load(int slot, {int capacity = 30}) async {
    final db = await DatabaseService.db;
    final rows = await db.query(_table, where: 'slot = ?', whereArgs: [slot]);
    final slotList = rows.map((row) => InventorySlot(
          itemId: row['item_id'] as String,
          count: row['count'] as int? ?? 1,
          slotIdx: row['slot_idx'] as int? ?? 0,
        )).toList();
    return Inventory.fromSlotList(slotList, capacity: capacity);
  }
}
