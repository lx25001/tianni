import '../models/character_data.dart';

/// 修炼公式引擎。
/// 
/// 实现 SYSTEMS.md 第三章的化乘为加新公式。
/// 所有修炼计算集中于此，UI 层只调用不写公式。
class CultivationEngine {
  CultivationEngine._();

  // ── 3.2.1 Base（基础速率） ─────────────────

  /// Base = 10 × 1.2^realmIndex
  static double baseRate(int realmIndex) {
    return 10.0 * _pow1_2(realmIndex);
  }

  static double _pow1_2(int n) {
    double v = 1.0;
    for (int i = 0; i < n; i++) {
      v *= 1.2;
    }
    return v;
  }

  // ── 3.2.2 先天倍率（加算区 A） ──────────────

  /// 先天倍率 = 根骨增益 + 道心增益 + 灵根资质
  static double innateBonus(CharacterData c) {
    return boneBonus(c.bon) + daoBonus(c.dao) + rootBonus(c.purityRate);
  }

  /// 根骨增益 = (BON - 10) / 100
  static double boneBonus(int bon) => (bon - 10) / 100.0;

  /// 道心增益 = (DAO - 50) / 100
  static double daoBonus(int dao) => (dao - 50) / 100.0;

  /// 灵根资质 = purityRate - 1.0
  static double rootBonus(double purityRate) => purityRate - 1.0;

  // ── 3.2.3 后天环境（加算区 B） ──────────────

  /// 后天环境 = 灵脉加成 + 功法增益 + 时辰加成
  static double envBonus({
    double veinDensity = 1.0,
    double skillWu = 10.0,
    double shichenMatch = 1.0,
  }) {
    return (veinDensity - 1.0) + (skillWu / 100.0) + (shichenMatch - 1.0);
  }

  // ── 3.2.4 外力催化（乘算区 C） ──────────────

  /// 外力催化 = 丹药加成 × 灵石加速
  static double catalyst({
    double pillBoost = 1.0,
    double stoneMultiplier = 1.0,
  }) {
    // 丹药上限 2.0，灵石上限 5.0
    final p = pillBoost.clamp(1.0, 2.0);
    final s = stoneMultiplier.clamp(1.0, 5.0);
    return p * s;
  }

  // ── 3.2.5 离线衰减 ─────────────────────────

  /// 在线 1.0，离线 0.6，洞府修炼室离线 0.66
  static double offlineAttenuation({
    bool isOnline = true,
    bool inCaveTrainingRoom = false,
  }) {
    if (isOnline) return 1.0;
    return inCaveTrainingRoom ? 0.66 : 0.6;
  }

  // ── 主公式 ─────────────────────────────────

  /// 每秒修炼值
  static double xpPerSecond({
    required int realmIndex,
    required CharacterData character,
    double veinDensity = 1.0,
    double skillWu = 10.0,
    double shichenMatch = 1.0,
    double pillBoost = 1.0,
    double stoneMultiplier = 1.0,
    bool isOnline = true,
    bool inCaveTrainingRoom = false,
  }) {
    final base = baseRate(realmIndex);
    final innate = innateBonus(character);
    final env = envBonus(
      veinDensity: veinDensity,
      skillWu: skillWu,
      shichenMatch: shichenMatch,
    );
    final cat = catalyst(pillBoost: pillBoost, stoneMultiplier: stoneMultiplier);
    final offline = offlineAttenuation(
      isOnline: isOnline,
      inCaveTrainingRoom: inCaveTrainingRoom,
    );

    return base * (1 + innate + env) * cat * offline;
  }

  // ── 3.3 单层所需 XP ────────────────────────

  /// 返回境界对应的单层 XP 需求
  static int xpRequired(int realmIndex) {
    const xpTable = [
      3600,        // 炼气
      12960,       // 筑基
      51840,       // 金丹
      129600,      // 元婴
      298080,      // 化神
      655776,      // 合体
      1311552,     // 大乘
      2295216,     // 渡劫
      3672346,     // 飞升
      5508518,     // 地仙
      7711926,     // 天仙
      9254311,     // 真仙
      9254311,     // 玄仙  ← XP 封顶
      9254311,     // 金仙
      9254311,     // 太乙
      9254311,     // 大罗
      9254311,     // 混元
      9254311,     // 鸿蒙
      9254311,     // 混沌
      9254311,     // 主宰
      9254311,     // 虚空
      9254311,     // 造化
      9254311,     // 道祖
      9254311,     // 永恒
    ];
    if (realmIndex < 0) return xpTable[0];
    if (realmIndex >= xpTable.length) return xpTable.last;
    return xpTable[realmIndex];
  }

  /// 修炼时长（秒）→ XP 积累 → 新 xpPercent
  /// 返回 [新 xpPercent, 是否突破, 突破次数]
  static (int xp, bool breakthrough, int layersGained) applyCultivation({
    required CharacterData character,
    required double seconds,
    double veinDensity = 1.0,
    double skillWu = 10.0,
    double shichenMatch = 1.0,
    double pillBoost = 1.0,
    double stoneMultiplier = 1.0,
    bool isOnline = true,
    bool inCaveTrainingRoom = false,
  }) {
    final rate = xpPerSecond(
      realmIndex: character.realmIndex,
      character: character,
      veinDensity: veinDensity,
      skillWu: skillWu,
      shichenMatch: shichenMatch,
      pillBoost: pillBoost,
      stoneMultiplier: stoneMultiplier,
      isOnline: isOnline,
      inCaveTrainingRoom: inCaveTrainingRoom,
    );

    final totalXpGained = (rate * seconds).round();
    int currentXp = character.xpPercent;
    int required = xpRequired(character.realmIndex);
    int layers = 0;

    int accumulated = currentXp + totalXpGained;
    while (accumulated >= required) {
      layers++;
      accumulated -= required;
      required = xpRequired(character.realmIndex + layers);
    }

    final newXp = layers > 0 ? accumulated : accumulated;
    final breakthrough = layers > 0;

    return (newXp.clamp(0, 999999999), breakthrough, layers);
  }
}
