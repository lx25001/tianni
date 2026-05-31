import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/character_data.dart';

class CharacterStorage {
  static const _keyPrefix = 'char_slot_';
  static const int maxSlots = 5;

  static Future<void> save(int slot, CharacterData data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_keyPrefix$slot', jsonEncode(data.toJson()));
  }

  static Future<CharacterData?> load(int slot) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_keyPrefix$slot');
    if (raw == null) return null;
    return CharacterData.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  static Future<List<CharacterData?>> loadAll() async {
    final result = <CharacterData?>[];
    for (int i = 0; i < maxSlots; i++) {
      result.add(await load(i));
    }
    return result;
  }

  static Future<void> delete(int slot) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_keyPrefix$slot');
  }
}
