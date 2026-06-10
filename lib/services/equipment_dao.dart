import '../models/equipment.dart';
import '../models/inventory.dart';
import 'database_service.dart';

class EquipmentDao {
  static const _table = 'equipment_slot';

  static Future<void> saveAll(int slot, Equipment equipment) async {
    final db = await DatabaseService.db;
    final batch = db.batch();
    batch.delete(_table, where: 'slot = ?', whereArgs: [slot]);
    for (final e in equipment.slots.entries) {
      final s = e.value;
      if (s == null) continue;
      batch.insert(_table, {
        'slot': slot,
        'equip_type': e.key,
        'item_id': s.itemId,
        'data': s.data,
      });
    }
    await batch.commit(noResult: true);
  }

  static Future<Equipment> load(int slot) async {
    final db = await DatabaseService.db;
    final rows = await db.query(_table, where: 'slot = ?', whereArgs: [slot]);
    final initSlots = <String, InventorySlot?>{};
    for (final t in Equipment.defaultTypes) {
      initSlots[t] = null;
    }
    for (final row in rows) {
      final type = row['equip_type'] as String;
      initSlots[type] = InventorySlot(
        itemId: row['item_id'] as String,
        count: 1,
        data: row['data'] as String?,
      );
    }
    return Equipment(slot: slot, initSlots: initSlots);
  }
}
