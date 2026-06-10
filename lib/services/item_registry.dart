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
    for (final e in list) {
      final tmpl = ItemTemplate.fromJson(e as Map<String, dynamic>);
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
