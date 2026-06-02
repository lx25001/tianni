import '../models/character_data.dart';
import 'database_service.dart';
import 'character_dao.dart';

/// 角色存储门面（Facade）。
/// 
/// 已从 SharedPreferences JSON 迁移到 SQLite。对外 API 不变。
class CharacterStorage {
  static const int maxSlots = 5;

  static bool _dbReady = false;

  /// 初始化数据库（须在应用启动时调用一次）
  static Future<void> ensureInitialized() async {
    if (_dbReady) return;
    await DatabaseService.instance.init();
    _dbReady = true;
  }

  static Future<void> _ensureDb() async => ensureInitialized();

  static Future<void> save(int slot, CharacterData data) async {
    await _ensureDb();
    await CharacterDao.save(slot, data);
  }

  static Future<CharacterData?> load(int slot) async {
    await _ensureDb();
    return CharacterDao.load(slot);
  }

  static Future<List<CharacterData?>> loadAll() async {
    await _ensureDb();
    return CharacterDao.loadAll();
  }

  static Future<void> delete(int slot) async {
    await _ensureDb();
    await CharacterDao.delete(slot);
  }
}
