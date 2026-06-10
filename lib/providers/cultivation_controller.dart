import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/character_data.dart';
import '../services/cultivation_engine.dart';

/// 修炼运行时状态（仅 UI 层持有，不持久化）
class CultivationRuntime {
  final bool isActive;
  final double rate;            // 当前速率
  final int layersGained;       // 本次修炼突破的层数
  final Timer? timer;

  const CultivationRuntime({
    this.isActive = false,
    this.rate = 0,
    this.layersGained = 0,
    this.timer,
  });
}

/// 简易修炼状态持有者，不通过 Riverpod（避免过度设计）
class CultivationController extends StateNotifier<CultivationRuntime> {
  CultivationController() : super(const CultivationRuntime());

  void start({
    required CharacterData character,
    required double rate,
    required void Function(CharacterData updated) onTick,
    required VoidCallback onLayerUp,
    required VoidCallback onRealmUp,
  }) {
    if (state.isActive) return;

    int prevRealm = character.realmIndex;

    final timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final (newXp, breakthrough, layers) = CultivationEngine.applyCultivation(
        character: character,
        seconds: 1,
      );

      int newLayer = character.layer + layers;
      int newRealm = character.realmIndex;
      while (newLayer > 9) {
        newRealm++;
        newLayer -= 9;
      }

      final updated = CharacterData(
        surname: character.surname,
        givenName: character.givenName,
        rootElement: character.rootElement,
        rootPurity: character.rootPurity,
        purityRate: character.purityRate,
        con: character.con,
        spi: character.spi,
        qi: character.qi,
        dao: character.dao,
        ins: character.ins,
        bon: character.bon,
        realmIndex: newRealm,
        layer: newLayer,
        xpPercent: newXp,
      );

      character = updated;
      onTick(updated);

      if (layers > 0) onLayerUp();
      if (newRealm != prevRealm) {
        prevRealm = newRealm;
        onRealmUp();
      }
    });

    state = CultivationRuntime(
      isActive: true,
      rate: rate,
      timer: timer,
    );
  }

  void stop() {
    state.timer?.cancel();
    state = const CultivationRuntime();
  }

  @override
  void dispose() {
    state.timer?.cancel();
    super.dispose();
  }
}
