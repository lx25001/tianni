import 'package:flutter/material.dart';

// ── 枚举 ──────────────────────────────────────

enum ItemCategory { equip, pill, mat, talisman, skill, junk }

enum ItemGrade { fan, liang, ling, bao, zhen, xian, sheng, dao }

enum EquipSlot { weapon, armor, accessory, artifact }

enum AffixType { prefix, suffix }

// ── 品阶色 ────────────────────────────────────

Color gradeColor(ItemGrade g) => switch (g) {
      ItemGrade.fan => const Color(0xFF8B8378),
      ItemGrade.liang => const Color(0xFF5B9A3F),
      ItemGrade.ling => const Color(0xFF4A90D9),
      ItemGrade.bao => const Color(0xFF9B6FD4),
      ItemGrade.zhen => const Color(0xFFFF8C00),
      ItemGrade.xian => const Color(0xFFFFD700),
      ItemGrade.sheng => const Color(0xFFFF5555),
      ItemGrade.dao => const Color(0xFF00FFFF),
    };

String gradeLabel(ItemGrade g) => switch (g) {
      ItemGrade.fan => '凡品',
      ItemGrade.liang => '良品',
      ItemGrade.ling => '灵品',
      ItemGrade.bao => '宝品',
      ItemGrade.zhen => '珍品',
      ItemGrade.xian => '仙品',
      ItemGrade.sheng => '圣品',
      ItemGrade.dao => '道品',
    };

ItemCategory catFromString(String s) => switch (s) {
      'equip' => ItemCategory.equip,
      'pill' => ItemCategory.pill,
      'mat' => ItemCategory.mat,
      'talisman' => ItemCategory.talisman,
      'skill' => ItemCategory.skill,
      _ => ItemCategory.junk,
    };

ItemGrade gradeFromString(String s) => switch (s) {
      'fan' => ItemGrade.fan,
      'liang' => ItemGrade.liang,
      'ling' => ItemGrade.ling,
      'bao' => ItemGrade.bao,
      'zhen' => ItemGrade.zhen,
      'xian' => ItemGrade.xian,
      'sheng' => ItemGrade.sheng,
      'dao' => ItemGrade.dao,
      _ => ItemGrade.fan,
    };

EquipSlot equipFromString(String s) => switch (s) {
      'weapon' => EquipSlot.weapon,
      'armor' => EquipSlot.armor,
      'accessory' => EquipSlot.accessory,
      _ => EquipSlot.artifact,
    };

// ── 物品效果 ──────────────────────────────────

class ItemEffect {
  final String type;      // cultivateBoost/breakthroughBonus/damage/heal/restoreQi/burn/slow
  final double value;
  final int? duration;    // 秒
  final String? element;
  final String? scaling;
  final String? desc;

  const ItemEffect({
    required this.type,
    required this.value,
    this.duration,
    this.element,
    this.scaling,
    this.desc,
  });

  factory ItemEffect.fromJson(Map<String, dynamic> j) => ItemEffect(
        type: j['type'] as String? ?? '',
        value: (j['value'] as num?)?.toDouble() ?? 0,
        duration: j['duration'] as int?,
        element: j['element'] as String?,
        scaling: j['scaling'] as String?,
        desc: j['desc'] as String?,
      );
}

// ── 装备词条 ──────────────────────────────────

class ItemAffix {
  final String name;
  final AffixType type;
  final String grade;    // T1-T5
  final String effect;
  final double value;
  final double? procRate;
  final String? trigger;
  final String? debuff;

  const ItemAffix({
    required this.name,
    required this.type,
    required this.grade,
    required this.effect,
    required this.value,
    this.procRate,
    this.trigger,
    this.debuff,
  });

  factory ItemAffix.fromJson(Map<String, dynamic> j) => ItemAffix(
        name: j['name'] as String? ?? '',
        type: j['type'] == 'suffix' ? AffixType.suffix : AffixType.prefix,
        grade: j['grade'] as String? ?? 'T1',
        effect: j['effect'] as String? ?? '',
        value: (j['value'] as num?)?.toDouble() ?? 0,
        procRate: (j['procRate'] as num?)?.toDouble(),
        trigger: j['trigger'] as String?,
        debuff: j['debuff'] as String?,
      );
}

// ── 物品模板（静态，打包在 assets） ───────────

class ItemTemplate {
  final String id;
  final String name;
  final ItemCategory cat;
  final String subCat;
  final ItemGrade grade;
  final String desc;
  final bool stackable;
  final int stackMax;
  final int weight;
  final int value; // 基准价格（灵石）

  // 装备
  final EquipSlot? equipSlot;
  final Map<String, double>? baseStats;
  final List<ItemAffix>? affixes;
  final int? durability;
  final int? maxDurability;

  // 丹药 / 符箓
  final int? cooldown;
  final List<ItemEffect>? effects;
  final int? toxicity;

  // 功法
  final Map<String, double>? skillDimensions;

  // 材料
  final Map<String, dynamic>? properties;

  // 使用限制
  final int? realmRequired; // 境界索引

  const ItemTemplate({
    required this.id,
    required this.name,
    required this.cat,
    this.subCat = '',
    required this.grade,
    this.desc = '',
    this.stackable = true,
    this.stackMax = 999,
    this.weight = 1,
    this.value = 1,
    this.equipSlot,
    this.baseStats,
    this.affixes,
    this.durability,
    this.maxDurability,
    this.cooldown,
    this.effects,
    this.toxicity,
    this.skillDimensions,
    this.properties,
    this.realmRequired,
  });

  factory ItemTemplate.fromJson(Map<String, dynamic> j) {
    return ItemTemplate(
      id: j['id'] as String,
      name: j['name'] as String,
      cat: catFromString(j['cat'] as String? ?? 'junk'),
      subCat: j['subCat'] as String? ?? '',
      grade: gradeFromString(j['grade'] as String? ?? 'fan'),
      desc: j['desc'] as String? ?? '',
      stackable: j['stackable'] as bool? ?? true,
      stackMax: j['stackMax'] as int? ?? 999,
      weight: j['weight'] as int? ?? 1,
      value: j['value'] as int? ?? 1,
      equipSlot: j['equipSlot'] != null ? equipFromString(j['equipSlot'] as String) : null,
      baseStats: j['baseStats'] != null
          ? Map<String, double>.from((j['baseStats'] as Map).map((k, v) => MapEntry(k, (v as num).toDouble())))
          : null,
      affixes: j['affixes'] != null
          ? (j['affixes'] as List).map((a) => ItemAffix.fromJson(a)).toList()
          : null,
      durability: j['durability'] as int?,
      maxDurability: j['maxDurability'] as int?,
      cooldown: j['cooldown'] as int?,
      effects: j['effects'] != null
          ? (j['effects'] as List).map((e) => ItemEffect.fromJson(e)).toList()
          : null,
      toxicity: j['toxicity'] as int?,
      skillDimensions: j['skillDimensions'] != null
          ? Map<String, double>.from((j['skillDimensions'] as Map).map((k, v) => MapEntry(k, (v as num).toDouble())))
          : null,
      properties: j['properties'] as Map<String, dynamic>?,
      realmRequired: j['realmRequired'] as int?,
    );
  }
}
