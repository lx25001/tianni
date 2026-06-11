import 'package:sqflite/sqflite.dart';
import '../models/inventory.dart';
import 'database_service.dart';

/// 背包数据访问层
class InventoryDao {
  static const _table = 'inventory_slot';

  /// [txn] 传入时在事务中写入，否则使用默认 db 连接。
  static Future<void> saveAll(int slot, Inventory inv, {DatabaseExecutor? txn}) async {
    final db = txn ?? await DatabaseService.db;
    final batch = db.batch();
    batch.delete(_table, where: 'slot = ?', whereArgs: [slot]);
    for (final s in inv.slots) {
      if (s == null) continue;
      batch.insert(_table, {
        'slot': slot,
        'item_id': s.itemId,
        'count': s.count,
        'slot_idx': s.slotIdx,
        'data': s.data,
      });
    }
    await batch.commit(noResult: true);
  }

  static Future<Inventory> load(int slot, {int capacity = 30}) async {
    final db = await DatabaseService.db;
    final rows = await db.query(_table, where: 'slot = ?', whereArgs: [slot]);
    final slotList = rows.map((row) => InventorySlot(
          itemId: row['item_id'] as String,
          count: row['count'] as int? ?? 1,
          slotIdx: row['slot_idx'] as int? ?? 0,
          data: row['data'] as String?,
        )).toList();
    return Inventory.fromSlotList(slotList, capacity: capacity);
  }
}
