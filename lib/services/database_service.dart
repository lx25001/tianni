import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

/// 数据库单例服务。
/// 
/// 负责创建、升级和提供数据库实例。所有 DAO 层通过 [db] 访问。
class DatabaseService {
  static DatabaseService? _instance;
  static Database? _db;

  DatabaseService._();

  static DatabaseService get instance {
    _instance ??= DatabaseService._();
    return _instance!;
  }

  /// 获取已打开的数据库（使用前须先调用 [init]）
  static Future<Database> get db async {
    if (_db != null) return _db!;
    throw StateError('DatabaseService 未初始化，请先调用 DatabaseService.instance.init()');
  }

  /// 初始化数据库：创建表结构 + 版本迁移
  Future<void> init() async {
    final dbPath = await getDatabasesPath();
    _db = await openDatabase(
      p.join(dbPath, 'tianni.db'),
      version: 5,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  // ⚠️ 外键已开启：onConfigure 中注册了 PRAGMA foreign_keys = ON
  // ⚠️ 动态属性已支持：inventory_slot 有 data TEXT 字段存放词条/耐久 JSON
  // ⚠️ 版本号：4（v1→角色表, v2→背包表, v3→last_save_ts, v4→data字段+外键PRAGMA）

  /// 建表
  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE character_slot (
        slot       INTEGER PRIMARY KEY,
        surname    TEXT NOT NULL,
        given_name TEXT NOT NULL,
        root_element TEXT NOT NULL,
        root_purity  TEXT NOT NULL,
        purity_rate  REAL NOT NULL DEFAULT 1.0,
        con        INTEGER NOT NULL DEFAULT 10,
        spi        INTEGER NOT NULL DEFAULT 10,
        qi         INTEGER NOT NULL DEFAULT 10,
        dao        INTEGER NOT NULL DEFAULT 50,
        ins        INTEGER NOT NULL DEFAULT 10,
        bon        INTEGER NOT NULL DEFAULT 10,
        realm_index INTEGER NOT NULL DEFAULT 0,
        layer      INTEGER NOT NULL DEFAULT 1,
        xp_percent INTEGER NOT NULL DEFAULT 0,
        spirit_stones INTEGER NOT NULL DEFAULT 0,
        last_save_ts INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // 功法栏（每槽位最多学 1 本当前修炼的功法；后台可有多本）
    await db.execute('''
      CREATE TABLE learned_skill (
        id         INTEGER PRIMARY KEY AUTOINCREMENT,
        slot       INTEGER NOT NULL,
        skill_id   TEXT NOT NULL,
        level      INTEGER NOT NULL DEFAULT 1,
        equipped   INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (slot) REFERENCES character_slot(slot) ON DELETE CASCADE
      )
    ''');

    // 背包槽
    await db.execute('''
      CREATE TABLE inventory_slot (
        id       INTEGER PRIMARY KEY AUTOINCREMENT,
        slot     INTEGER NOT NULL,
        item_id  TEXT NOT NULL,
        count    INTEGER NOT NULL DEFAULT 1,
        slot_idx INTEGER NOT NULL,
        data     TEXT
      )
    ''');

    // 装备槽（每人最多 4 件：weapon/armor/accessory/artifact）
    await db.execute('''
      CREATE TABLE equipment_slot (
        slot        INTEGER NOT NULL,
        equip_type  TEXT NOT NULL,
        item_id     TEXT NOT NULL,
        data        TEXT,
        PRIMARY KEY (slot, equip_type),
        FOREIGN KEY (slot) REFERENCES character_slot(slot) ON DELETE CASCADE
      )
    ''');
  }

  /// 版本迁移
  static Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE inventory_slot (
          id       INTEGER PRIMARY KEY AUTOINCREMENT,
          slot     INTEGER NOT NULL,
          item_id  TEXT NOT NULL,
          count    INTEGER NOT NULL DEFAULT 1,
          slot_idx INTEGER NOT NULL
        )
      ''');
    }
    if (oldVersion < 3) {
      await db.execute("ALTER TABLE character_slot ADD COLUMN last_save_ts INTEGER NOT NULL DEFAULT 0");
    }
    if (oldVersion < 4) {
      await db.execute("ALTER TABLE inventory_slot ADD COLUMN data TEXT");
    }
    if (oldVersion < 5) {
      await db.execute('''
        CREATE TABLE equipment_slot (
          slot        INTEGER NOT NULL,
          equip_type  TEXT NOT NULL,
          item_id     TEXT NOT NULL,
          data        TEXT,
          PRIMARY KEY (slot, equip_type),
          FOREIGN KEY (slot) REFERENCES character_slot(slot) ON DELETE CASCADE
        )
      ''');
    }
  }

  /// 关闭数据库（应用退出时调用）
  Future<void> close() async {
    await _db?.close();
    _db = null;
  }
}
