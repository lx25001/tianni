import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/character_data.dart';
import '../services/cultivation_engine.dart';
import '../services/character_storage.dart';

/// 修炼状态
class CultivationState {
  final bool isActive;
  final double accumulatedXp;   // 本次修炼积累的 XP（秒为单位）
  final int layersGained;       // 本次修炼突破的层数
  final double rate;            // 当前速率

  const CultivationState({
    this.isActive = false,
    this.accumulatedXp = 0,
    this.layersGained = 0,
    this.rate = 0,
  });

  CultivationState copyWith({
    bool? isActive,
    double? accumulatedXp,
    int? layersGained,
    double? rate,
  }) {
    return CultivationState(
      isActive: isActive ?? this.isActive,
      accumulatedXp: accumulatedXp ?? this.accumulatedXp,
      layersGained: layersGained ?? this.layersGained,
      rate: rate ?? this.rate,
    );
  }
}

/// 修炼 Provider：管理计时器 + 每秒 tick
class CultivationNotifier extends StateNotifier<CultivationState> {
  Timer? _timer;
  int _slot = 0;
  CharacterData _character;

  CultivationNotifier(this._character, this._slot) : super(const CultivationState());

  CharacterData get character => _character;

  void updateCharacter(CharacterData c) {
    _character = c;
  }

  void updateSlot(int slot) {
    _slot = slot;
  }

  /// 开始修炼
  void start({
    double veinDensity = 1.0,
    double skillWu = 10.0,
    double shichenMatch = 1.0,
    double pillBoost = 1.0,
    double stoneMultiplier = 1.0,
  }) {
    if (state.isActive) return;

    final rate = CultivationEngine.xpPerSecond(
      realmIndex: _character.realmIndex,
      character: _character,
      veinDensity: veinDensity,
      skillWu: skillWu,
      shichenMatch: shichenMatch,
      pillBoost: pillBoost,
      stoneMultiplier: stoneMultiplier,
      isOnline: true,
    );

    state = state.copyWith(isActive: true, accumulatedXp: 0, rate: rate);

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _tick();
    });
  }

  /// 停止修炼
  Future<void> stop() async {
    if (!state.isActive) return;
    _timer?.cancel();
    _timer = null;
    // 保存角色数据
    await CharacterStorage.save(_slot, _character);
    state = state.copyWith(isActive: false);
  }

  void _tick() {
    final (newXp, breakthrough, layers) = CultivationEngine.applyCultivation(
      character: _character,
      seconds: 1,
    );

    int newLayer = _character.layer + layers;
    int newRealm = _character.realmIndex;
    // 如果突破大境界
    while (newLayer > 9) {
      newRealm++;
      newLayer -= 9;
    }

    _character = CharacterData(
      surname: _character.surname,
      givenName: _character.givenName,
      rootElement: _character.rootElement,
      rootPurity: _character.rootPurity,
      purityRate: _character.purityRate,
      con: _character.con,
      spi: _character.spi,
      qi: _character.qi,
      dao: _character.dao,
      ins: _character.ins,
      bon: _character.bon,
      realmIndex: newRealm,
      layer: newLayer,
      xpPercent: newXp,
    );

    state = state.copyWith(
      accumulatedXp: state.accumulatedXp + state.rate,
      layersGained: state.layersGained + layers,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final cultivationProvider =
    StateNotifierProvider.autoDispose.family<CultivationNotifier, CultivationState, int>(
  (ref, slot) {
    // 需要外部注入 character —— 在 GamePage 中通过 ref.read 设置
    throw UnimplementedError('使用 cultivationNotifierFor(slot, character) 创建');
  },
);

/// 外部注入方式创建
CultivationNotifier cultivationNotifierFor(int slot, CharacterData character) {
  // 通过 ProviderScope 的外部 override 注入
  throw UnimplementedError('暂时直连');
}
