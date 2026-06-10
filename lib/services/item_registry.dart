import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/item_data.dart';

/// 物品注册表。
/// 启动时从 assets/data/items.json 加载所有物品模板。
class ItemRegistry {
  static final Map<String, ItemTemplate> _items = {};
  static bool _init = false;

  static Future<void> init() async {
    if (_init) return;
    final raw = await rootBundle.loadString('assets/data/items.json');
    final list = jsonDecode(raw) as List;
    final ids = <String>{};
    for (final e in list) {
      final tmpl = ItemTemplate.fromJson(e as Map<String, dynamic>);
      // 校验重复ID
      if (ids.contains(tmpl.id)) {
        throw Exception('物品ID重复: ${tmpl.id}');
      }
      ids.add(tmpl.id);
      // 校验境界需求范围
      if (tmpl.realmRequired != null &&
          (tmpl.realmRequired! < 0 || tmpl.realmRequired! > 23)) {
        throw Exception('${tmpl.id}: realmRequired 越界 (0-23)');
      }
      _items[tmpl.id] = tmpl;
    }
    _init = true;
  }

  static ItemTemplate? get(String id) => _items[id];
  static List<ItemTemplate> get all => _items.values.toList();
  static int get count => _items.length;

  static List<ItemTemplate> byCategory(ItemCategory cat) =>
      _items.values.where((t) => t.cat == cat).toList();

  static List<ItemTemplate> bySubCat(String subCat) =>
      _items.values.where((t) => t.subCat == subCat).toList();

  static List<ItemTemplate> byGrade(ItemGrade grade) =>
      _items.values.where((t) => t.grade == grade).toList();

  static List<ItemTemplate> search(String query) =>
      _items.values.where((t) => t.name.contains(query) || t.desc.contains(query)).toList();
}
