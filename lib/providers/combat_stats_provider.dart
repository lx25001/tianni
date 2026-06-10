import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/character_data.dart';
import '../models/item_data.dart';
import '../providers/inventory_provider.dart';
import '../providers/equipment_provider.dart';

/// 战斗面板总属性（派生计算，不入库）
class CombatStats {
  final int maxHp;
  final int maxQi;
  final int attack;
  final int defense;
  final int magicResist;
  final double critRate;

  const CombatStats({
    required this.maxHp,
    required this.maxQi,
    required this.attack,
    required this.defense,
    required this.magicResist,
    this.critRate = 0,
  });
}

final combatStatsProvider = Provider.family<CombatStats, ({int slot, CharacterData char})?>(
  (ref, args) {
    if (args == null) {
      return const CombatStats(maxHp: 100, maxQi: 80, attack: 10, defense: 0, magicResist: 0);
    }
    final char = args.char;
    final equips = ref.watch(equipmentProvider(args.slot));

    int maxHp = char.con * 10;
    int maxQi = char.qi * 8;
    int attack = char.spi * 2;
    int defense = 0;
    int magicResist = 0;
    double critRate = 0;

    for (final info in equips.equipped) {
      final bs = info.slot.template?.baseStats;
      if (bs == null) continue;
      attack += (bs['attack'] ?? 0).toInt();
      defense += (bs['defense'] ?? 0).toInt();
      magicResist += (bs['magicResist'] ?? 0).toInt();
      critRate += bs['critRate'] ?? 0;
    }

    return CombatStats(
      maxHp: maxHp,
      maxQi: maxQi,
      attack: attack,
      defense: defense,
      magicResist: magicResist,
      critRate: critRate,
    );
  },
);
