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
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

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
  }

  /// 版本迁移
  static Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // 当前 v1，暂无迁移逻辑。后续版本在此追加。
  }

  /// 关闭数据库（应用退出时调用）
  Future<void> close() async {
    await _db?.close();
    _db = null;
  }
}
