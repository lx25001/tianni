import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/character_data.dart';
import '../services/character_storage.dart';

/// 角色数据 Provider（按槽位加载）
final characterProvider = FutureProvider.family<CharacterData?, int>((ref, slot) async {
  return CharacterStorage.load(slot);
});
