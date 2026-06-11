import 'package:sqflite/sqflite.dart';
import '../models/character_data.dart';
import 'database_service.dart';

/// 角色数据访问对象。
/// 
/// 封装 character_slot 表的 CRUD，对上层隐藏 SQL。
class CharacterDao {
  static const _table = 'character_slot';

  /// 保存角色（INSERT OR REPLACE）
  static Future<void> save(int slot, CharacterData data, {bool stampTs = true}) async {
    final db = await DatabaseService.db;
    final now = DateTime.now().toIso8601String();
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    final existing = await db.query(_table, where: 'slot = ?', whereArgs: [slot]);
    final createdAt = existing.isNotEmpty
        ? (existing.first['created_at'] as String?) ?? now
        : now;
    final d = stampTs ? data.copyWith(lastSaveTs: nowMs) : data;

    await db.insert(
      _table,
      _toRow(slot, d, createdAt, now),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// 加载单个角色
  static Future<CharacterData?> load(int slot) async {
    final db = await DatabaseService.db;
    final rows = await db.query(_table, where: 'slot = ?', whereArgs: [slot], limit: 1);
    if (rows.isEmpty) return null;
    return _fromRow(rows.first);
  }

  /// 加载所有槽位（0..4）
  static Future<List<CharacterData?>> loadAll() async {
    final db = await DatabaseService.db;
    final rows = await db.query(_table);
    final result = List<CharacterData?>.filled(5, null);
    for (final row in rows) {
      final slot = (row['slot'] as int?) ?? 0;
      if (slot >= 0 && slot < 5) {
        result[slot] = _fromRow(row);
      }
    }
    return result;
  }

  /// 删除角色槽位
  static Future<void> delete(int slot) async {
    final db = await DatabaseService.db;
    await db.delete(_table, where: 'slot = ?', whereArgs: [slot]);
  }

  // ── 私有 ─────────────────────────────────

  static Map<String, dynamic> _toRow(
      int slot, CharacterData d, String createdAt, String updatedAt) {
    return {
      'slot': slot,
      'surname': d.surname,
      'given_name': d.givenName,
      'root_element': d.rootElement,
      'root_purity': d.rootPurity,
      'purity_rate': d.purityRate,
      'con': d.con,
      'spi': d.spi,
      'qi': d.qi,
      'dao': d.dao,
      'ins': d.ins,
      'bon': d.bon,
      'realm_index': d.realmIndex,
      'layer': d.layer,
      'xp_percent': d.xpPercent,
      'spirit_stones': d.spiritStones,
      'last_save_ts': d.lastSaveTs,
      'current_hp': d.currentHp,
      'current_qi': d.currentQi,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  static CharacterData _fromRow(Map<String, dynamic> row) {
    return CharacterData(
      surname: row['surname'] as String,
      givenName: row['given_name'] as String,
      rootElement: row['root_element'] as String,
      rootPurity: row['root_purity'] as String,
      purityRate: (row['purity_rate'] as num).toDouble(),
      con: row['con'] as int,
      spi: row['spi'] as int,
      qi: row['qi'] as int,
      dao: row['dao'] as int,
      ins: row['ins'] as int,
      bon: row['bon'] as int,
      realmIndex: row['realm_index'] as int? ?? 0,
      layer: row['layer'] as int? ?? 1,
      xpPercent: row['xp_percent'] as int? ?? 0,
      spiritStones: row['spirit_stones'] as int? ?? 5,
      lastSaveTs: row['last_save_ts'] as int? ?? 0,
      currentHp: row['current_hp'] as int? ?? 100,
      currentQi: row['current_qi'] as int? ?? 80,
    );
  }
}
