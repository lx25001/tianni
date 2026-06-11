import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/colors.dart';
import '../widgets/ancient_border.dart';
import '../widgets/ink_divider.dart';
import '../widgets/ancient_button.dart';
import '../widgets/tianni_dialog.dart';
import '../widgets/tianni_feedback.dart';
import '../models/character_data.dart';
import '../models/item_data.dart';
import '../models/inventory.dart';
import '../services/character_storage.dart';
import '../widgets/game_map_widget.dart';
import '../providers/game_clock_provider.dart';
import '../providers/inventory_provider.dart';
import '../providers/equipment_provider.dart';
import '../providers/combat_stats_provider.dart';
import '../providers/character_provider.dart';
import '../models/equipment.dart';
import '../services/cultivation_engine.dart';

/// 游戏主界面
class GamePage extends StatefulWidget {
  final int slotIndex;

  const GamePage({super.key, required this.slotIndex});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  String _activeMenu = 'home';
  CharacterData? _char;
  bool _loading = true;

  static const List<Map<String, String>> _menuItems = [
    {'id': 'cultivate', 'label': '修炼', 'icon': '修'},
    {'id': 'battle', 'label': '洞府', 'icon': '府'},
    {'id': 'home', 'label': '主界', 'icon': '◈'},
    {'id': 'sect', 'label': '游历', 'icon': '游'},
    {'id': 'bag', 'label': '储物', 'icon': '囊'},
    {'id': 'equip', 'label': '装备', 'icon': '铠'},
  ];

  static const List<Map<String, String>> _menuRow2 = [
    {'id': 'clan', 'label': '宗门', 'icon': '門'},
    {'id': 'skill', 'label': '功法', 'icon': '诀'},
    {'id': 'social', 'label': '社交', 'icon': '友'},
    {'id': 'trade', 'label': '交易', 'icon': '市'},
    {'id': 'setting', 'label': '设置', 'icon': '设'},
  ];

  @override
  void initState() {
    super.initState();
    _loadCharacter();
  }

  Future<void> _loadCharacter() async {
    var char = await CharacterStorage.load(widget.slotIndex);
    if (char == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    // 离线补算
    final now = DateTime.now().millisecondsSinceEpoch;
    final offlineSec = char.lastSaveTs > 0 ? ((now - char.lastSaveTs) / 1000).floor() : 0;
    if (offlineSec > 0) {
      final (updated, sec, layers, realmBreaks) = CultivationEngine.applyOffline(
        character: char,
        offlineSeconds: offlineSec,
      );
      char = updated.copyWith(lastSaveTs: now);
      _offlineSummary = '离线 ${_fmtDuration(offlineSec)}，突破 $layers 层';
      if (realmBreaks > 0) _offlineSummary = _offlineSummary! + '，晋升 $realmBreaks 大境界';
    }
    if (mounted) setState(() { _char = char; _loading = false; });
    // 显示离线收益
    if (offlineSec > 0 && _offlineSummary != null && mounted) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          TianniToast.show(context, '${_offlineSummary!.replaceAll('，', '\n')}');
        }
      });
    }
  }

  String _fmtDuration(int seconds) {
    if (seconds < 60) return '$seconds 秒';
    final m = seconds ~/ 60;
    if (m < 60) return '$m 分${seconds % 60}秒';
    final h = m ~/ 60;
    return '$h 时${m % 60}分';
  }

  String? _offlineSummary;

  void _onCharChanged(CharacterData updated) {
    setState(() => _char = updated);
  }

  String get _charName => _char?.fullName ?? '修士';
  String get _realmName => _char?.realmName ?? '炼气期';
  int get _expPercent => _char?.xpPercent ?? 0;
  int get _hpPercent => ((_char?.con ?? 10) * 10) ~/ 2; // rough
  int get _mpPercent => ((_char?.qi ?? 10) * 8) ~/ 2;
  int get realmIdx => _char?.realmIndex ?? 0;

  Color get realmColor {
    return TianniColors.realmColors[_realmName] ?? TianniColors.gold;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: TianniColors.bg,
        body: Center(child: CircularProgressIndicator(color: TianniColors.gold)),
      );
    }
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: TianniColors.bg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ── 角色信息 ──
            Container(
                padding: const EdgeInsets.fromLTRB(14, 6, 14, 6),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: TianniColors.inkLight, width: 0.5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(_charName,
                          style: const TextStyle(color: TianniColors.goldBright, fontSize: 15, letterSpacing: 3, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 10),
                        Text('$_realmName · ${_char?.layer ?? 1}层',
                          style: TextStyle(color: realmColor, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        Text('灵石 ${_char?.spiritStones ?? 0}',
                          style: const TextStyle(color: TianniColors.gold, fontSize: 10),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    // 境界进度条
                    Row(
                      children: [
                        const Text('修为 ', style: TextStyle(color: TianniColors.goldDark, fontSize: 9)),
                        Expanded(
                          child: Container(
                            height: 3,
                            decoration: BoxDecoration(
                              color: TianniColors.inkLight,
                              border: Border.all(color: TianniColors.inkMid, width: 0.3),
                            ),
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: _expPercent / 100,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(colors: [TianniColors.goldDark, TianniColors.goldBright]),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text('$_expPercent%', style: const TextStyle(color: TianniColors.goldDim, fontSize: 9)),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Text('${_char?.rootElement ?? "金"}灵根 · ${_char?.rootPurity ?? "中品"}',
                          style: const TextStyle(color: TianniColors.gold, fontSize: 11),
                        ),
                        const SizedBox(width: 12),
                        Text('气血 ${(_char?.con ?? 10) * 10}',
                          style: const TextStyle(color: Color(0xFFFF5555), fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 12),
                        Text('灵气 ${(_char?.qi ?? 10) * 8}',
                          style: const TextStyle(color: Color(0xFF66B3FF), fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        Text('寿元 360',
                          style: const TextStyle(color: TianniColors.goldDim, fontSize: 10),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const _TimeDisplay(),
                  ],
                ),
              ),
              // ── 主内容区 ──
              Expanded(
                child: IndexedStack(
                  index: [..._menuItems, ..._menuRow2].indexWhere((m) => m['id'] == _activeMenu),
                  children: [
                    _CultivatePanel(character: _char, onCharacterChanged: _onCharChanged, slotIndex: widget.slotIndex),
                    const _BattlePanel(),
                    const GameMapWidget(),
                    const _SectPanel(),
                    _BagPanel(slotIndex: widget.slotIndex),
                    _EquipPanel(slotIndex: widget.slotIndex),
                    const _PlaceholderPanel(label: '宗门', desc: '宗门系统开发中'),
                    const _PlaceholderPanel(label: '功法', desc: '功法系统开发中'),
                    const _PlaceholderPanel(label: '社交', desc: '社交系统开发中'),
                    const _PlaceholderPanel(label: '交易', desc: '交易系统开发中'),
                    const _PlaceholderPanel(label: '设置', desc: '设置项开发中'),
                  ],
                ),
              ),

              // ── 底部菜单 ──
              Container(
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: TianniColors.goldDark2, width: 1)),
                  color: TianniColors.bg,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _BottomMenu(
                      active: _activeMenu,
                      items: _menuItems,
                      onSelect: (id) => setState(() => _activeMenu = id),
                    ),
                    Container(height: 0.5, color: TianniColors.inkLight),
                    _BottomMenu(
                      active: _activeMenu,
                      items: _menuRow2,
                      onSelect: (id) => setState(() => _activeMenu = id),
                      sub: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
    );
  }
}

// END

// ── 游戏时间显示（Riverpod）──
class _TimeDisplay extends ConsumerWidget {
  const _TimeDisplay();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameTime = ref.watch(gameClockProvider);
    final si = gameTime.shichen.index;
    final brightness = 0.4 + (6 - (si - 6).abs()) / 6.0 * 0.6;
    final color = Color.lerp(TianniColors.goldDim, TianniColors.goldBright, brightness)!;
    final fest = gameTime.festival;

    return Row(
      children: [
        Text(gameTime.formatted,
          style: TextStyle(color: color, fontSize: 10, letterSpacing: 1),
        ),
        if (fest != null) ...[
          const SizedBox(width: 8),
          const _FestivalBadge(),
        ],
      ],
    );
  }
}

class _FestivalBadge extends ConsumerStatefulWidget {
  const _FestivalBadge();

  @override
  ConsumerState<_FestivalBadge> createState() => _FestivalBadgeState();
}

class _FestivalBadgeState extends ConsumerState<_FestivalBadge> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
    _scaleAnim = Tween<double>(begin: 1.0, end: 1.08).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fest = ref.watch(gameClockProvider).festival;
    if (fest == null) return const SizedBox.shrink();

    return ScaleTransition(
      scale: _scaleAnim,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
        decoration: BoxDecoration(
          border: Border.all(color: TianniColors.crimson),
          color: TianniColors.crimson.withValues(alpha: 0.2),
        ),
        child: Text(fest.name,
          style: const TextStyle(color: Color(0xFFFF6666), fontSize: 10, letterSpacing: 1, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

// ============================================================
// 底部菜单
// ============================================================
class _BottomMenu extends StatelessWidget {
  final String active;
  final List<Map<String, String>> items;
  final void Function(String id) onSelect;
  final bool sub;

  const _BottomMenu({
    required this.active,
    required this.items,
    required this.onSelect,
    this.sub = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: sub ? 36 : 44,
      child: Row(
        children: items.map((item) {
          final isActive = active == item['id'];
          return Expanded(
            child: GestureDetector(
              onTap: () => onSelect(item['id']!),
              behavior: HitTestBehavior.opaque,
              child: Container(
                color: isActive ? const Color.fromRGBO(200, 169, 110, 0.04) : Colors.transparent,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!sub)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        width: isActive ? 22 : 0,
                        height: 2,
                        decoration: BoxDecoration(
                          color: TianniColors.gold,
                          boxShadow: isActive ? [const BoxShadow(color: TianniColors.gold, blurRadius: 3, spreadRadius: -1)] : null,
                        ),
                      ),
                    if (!sub) const Spacer(),
                    Text(item['icon']!,
                      style: TextStyle(
                        color: isActive ? TianniColors.goldBright : sub ? TianniColors.goldDark2 : TianniColors.goldDark,
                        fontSize: sub ? 14 : 13,
                        height: 1,
                      ),
                    ),
                    SizedBox(height: sub ? 2 : 1),
                    Text(item['label']!,
                      style: TextStyle(
                        color: isActive ? TianniColors.gold : sub ? TianniColors.goldDark2 : TianniColors.goldDark,
                        fontSize: sub ? 9 : 10,
                        letterSpacing: 1,
                      ),
                    ),
                    if (!sub) const Spacer(),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ============================================================
// 修炼面板
// ============================================================
class _CultivatePanel extends ConsumerStatefulWidget {
  final CharacterData? character;
  final void Function(CharacterData updated)? onCharacterChanged;
  final int slotIndex;
  const _CultivatePanel({this.character, this.onCharacterChanged, this.slotIndex = 0});

  @override
  ConsumerState<_CultivatePanel> createState() => _CultivatePanelState();
}

class _CultivatePanelState extends ConsumerState<_CultivatePanel> {
  Timer? _timer;
  bool _cultivating = false;
  double _rate = 0;
  int _layersGained = 0;
  CharacterData? _char;
  double _displayPercent = 0;  // 平滑进度显示
  int _currentRealm = 0;

  @override
  void initState() {
    super.initState();
    _char = widget.character;
    _displayPercent = (_char?.xpPercent ?? 0).toDouble();
    _currentRealm = _char?.realmIndex ?? 0;
  }

  @override
  void didUpdateWidget(covariant _CultivatePanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_cultivating) {
      _char = widget.character;
      _displayPercent = (_char?.xpPercent ?? 0).toDouble();
      _currentRealm = _char?.realmIndex ?? 0;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startCultivation() {
    if (_cultivating) return;
    final c = _char ?? widget.character;
    if (c == null) return;

    final rate = CultivationEngine.xpPerSecond(
      realmIndex: c.realmIndex,
      character: c,
    );
    setState(() {
      _cultivating = true;
      _rate = rate;
      _layersGained = 0;
    });

    _timer = Timer.periodic(const Duration(milliseconds: 200), (_) => _tick());
  }

  void _stopCultivation() {
    _timer?.cancel();
    setState(() => _cultivating = false);
    final c = _char;
    if (c != null) {
      CharacterStorage.save(widget.slotIndex, c).ignore();
      widget.onCharacterChanged?.call(c);
    }
  }

  void _tick() {
    final c = _char;
    if (c == null) return;

    // 实时重算速率（时辰可能已变化）
    final gameTime = ref.read(gameClockProvider);
    final element = c.rootElement;
    final shichenMatch = gameTime.shichen.element == element ? 1.15 : 1.0;

    final rate = CultivationEngine.xpPerSecond(
      realmIndex: c.realmIndex,
      character: c,
      shichenMatch: shichenMatch,
    );
    _rate = rate; // 同步给 UI 显示的速率

    final xpGained = rate * 0.2;
    final required = CultivationEngine.xpRequired(c.realmIndex).toDouble();
    final percentGain = (xpGained / required) * 100.0;

    double newPercent = _displayPercent + percentGain;
    int layers = 0;

    while (newPercent >= 100.0) {
      layers++;
      newPercent -= 100.0;
    }

    if (layers == 0) {
      _displayPercent = newPercent;
      _char = CharacterData(
        surname: c.surname, givenName: c.givenName,
        rootElement: c.rootElement, rootPurity: c.rootPurity,
        purityRate: c.purityRate,
        con: c.con, spi: c.spi, qi: c.qi,
        dao: c.dao, ins: c.ins, bon: c.bon,
        realmIndex: c.realmIndex, layer: c.layer,
        xpPercent: newPercent.round(),
        spiritStones: c.spiritStones,
      );
      setState(() {});
      widget.onCharacterChanged?.call(_char!);
      return;
    }

    // 有突破
    int newLayer = c.layer + layers;
    int newRealm = c.realmIndex;
    int realmBreaks = 0;
    while (newLayer > 9) {
      newRealm++;
      newLayer -= 9;
      realmBreaks++;
    }

    final rng = DateTime.now().microsecondsSinceEpoch;
    int conGain = 0, spiGain = 0, qiGain = 0;
    for (int i = 0; i < layers; i++) {
      conGain += 1 + ((rng + i * 3) % 3);
      spiGain += 1 + ((rng + i * 3 + 1) % 3);
      qiGain += 1 + ((rng + i * 3 + 2) % 3);
    }
    for (int i = 0; i < realmBreaks; i++) {
      conGain += 10 + ((rng + i * 7) % 21);
      spiGain += 10 + ((rng + i * 7 + 1) % 21);
      qiGain += 10 + ((rng + i * 7 + 2) % 21);
    }

    _displayPercent = newPercent;
    _currentRealm = newRealm;

    _char = CharacterData(
      surname: c.surname, givenName: c.givenName,
      rootElement: c.rootElement, rootPurity: c.rootPurity,
      purityRate: c.purityRate,
      con: c.con + conGain, spi: c.spi + spiGain, qi: c.qi + qiGain,
      dao: c.dao, ins: c.ins, bon: c.bon,
      realmIndex: newRealm, layer: newLayer,
      xpPercent: newPercent.round(),
      spiritStones: c.spiritStones,
    );

    setState(() {
      _layersGained += layers;
    });
    widget.onCharacterChanged?.call(_char!);
  }

  @override
  Widget build(BuildContext context) {
    final gameTime = ref.watch(gameClockProvider);
    final c = _char;
    final realm = c?.realmName ?? '炼气期';
    final layer = c?.layer ?? 1;
    final xpPercent = _displayPercent;
    final bon = c?.bon ?? 10;
    final daoXin = c?.dao ?? 50;
    final element = c?.rootElement ?? '金';
    final purity = c?.rootPurity ?? '下品';

    // 用引擎计算各项因子
    final purityRate = c?.purityRate ?? 1.0;
    final purityMult = purityRate;
    final boneMult = CultivationEngine.boneBonus(bon);
    final daoMult = CultivationEngine.daoBonus(daoXin);
    final shichenMatch = gameTime.shichen.element == element ? 1.15 : 1.0;
    final rate = c != null
        ? CultivationEngine.xpPerSecond(
            realmIndex: c.realmIndex,
            character: c,
            shichenMatch: shichenMatch,
          )
        : 10.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 当前境界
          Row(
            children: [
              Transform.rotate(angle: 0.785, child: Container(width: 6, height: 6, decoration: BoxDecoration(border: Border.all(color: TianniColors.gold)))),
              const SizedBox(width: 8),
              Text(realm, style: const TextStyle(color: TianniColors.goldBright, fontSize: 14, letterSpacing: 2, fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              Text('第${layer}层', style: const TextStyle(color: TianniColors.goldDim, fontSize: 12)),
              const Spacer(),
              Text('${xpPercent.toStringAsFixed(1)}%', style: const TextStyle(color: TianniColors.gold, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 6),
          // 境界进度
          Container(
            height: 4,
            decoration: BoxDecoration(color: TianniColors.inkLight, border: Border.all(color: TianniColors.inkMid, width: 0.3)),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: (xpPercent / 100.0).clamp(0.0, 1.0),
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [TianniColors.goldDark, TianniColors.goldBright]),
                ),
              ),
            ),
          ),
          if (_cultivating) ...[
            const SizedBox(height: 4),
            Text('修炼中 · ${_layersGained > 0 ? "已突破$_layersGained层" : "积累中..."}',
              style: const TextStyle(color: TianniColors.gold, fontSize: 9)),
          ],
          const SizedBox(height: 14),
          // 修炼速率
          Text('修炼速率', style: const TextStyle(color: TianniColors.goldBright, fontSize: 12, letterSpacing: 2)),
          const SizedBox(height: 6),
          _RateRow(label: '$element灵根$purity', value: '×${purityMult.toStringAsFixed(1)}', color: TianniColors.gold),
          _RateRow(label: '根骨加成', value: '×${(1 + boneMult).toStringAsFixed(2)}', color: const Color(0xFFC8A96E)),
          _RateRow(label: '${gameTime.shichen.name} · ${gameTime.shichen.element}行${shichenMatch > 1 ? "+" : ""}${((shichenMatch - 1) * 100).round()}%', value: '×${shichenMatch.toStringAsFixed(2)}', color: const Color(0xFF9B6FD4)),
          _RateRow(label: '道心', value: '×${(1 + daoMult).toStringAsFixed(2)}', color: TianniColors.goldDim),
          const SizedBox(height: 4),
          Container(height: 0.5, color: TianniColors.inkMid),
          const SizedBox(height: 6),
          Row(
            children: [
              const Text('当前速率', style: TextStyle(color: TianniColors.goldBright, fontSize: 13, letterSpacing: 2)),
              const Spacer(),
              Text('${rate.toStringAsFixed(1)} XP/秒', style: const TextStyle(color: TianniColors.gold, fontSize: 14, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 14),
          // 时辰提示
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              border: Border.all(color: TianniColors.inkLight),
              color: TianniColors.bgCard,
            ),
            child: Row(
              children: [
                const Text('辰', style: TextStyle(color: TianniColors.gold, fontSize: 13)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '当前${gameTime.shichen.name}（${gameTime.shichen.period}），${gameTime.shichen.element}行灵气${gameTime.shichen.element == element ? "旺盛" : "平稳"}',
                    style: const TextStyle(color: TianniColors.goldDim, fontSize: 10, letterSpacing: 1),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // 修炼按钮
          SizedBox(
            width: double.infinity,
            height: 42,
            child: GestureDetector(
              onTap: _cultivating ? _stopCultivation : _startCultivation,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: _cultivating ? TianniColors.goldDim : TianniColors.gold, width: 1.5),
                  color: _cultivating
                      ? TianniColors.inkLight
                      : TianniColors.gold.withValues(alpha: 0.08),
                ),
                alignment: Alignment.center,
                child: Text(
                  _cultivating ? '停止修炼' : '开始修炼',
                  style: TextStyle(
                    color: _cultivating ? TianniColors.goldDim : TianniColors.goldBright,
                    fontSize: 15, letterSpacing: 6,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(_cultivating ? '点击停止后将自动保存进度' : '修炼可离线挂机，离线速率 ×0.6',
            textAlign: TextAlign.center,
            style: const TextStyle(color: TianniColors.goldDark2, fontSize: 9),
          ),
          const SizedBox(height: 18),
          // 下一境界
          const _SectionDivider(label: '道 途'),
          const SizedBox(height: 8),
          _NextRealmInfo(realmIndex: c?.realmIndex ?? 0, layer: layer, xpPercent: xpPercent.round()),
          const SizedBox(height: 16),
          // 当前功法
          const _SectionDivider(label: '功 法'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(border: Border.all(color: TianniColors.inkLight)),
            child: const Row(
              children: [
                Text('太虚吐纳术', style: TextStyle(color: TianniColors.goldBright, fontSize: 12, letterSpacing: 2)),
                Spacer(),
                Text('入门', style: TextStyle(color: TianniColors.goldDim, fontSize: 10)),
              ],
            ),
          ),
          const SizedBox(height: 4),
          const Text('基础吐纳之法，引天地灵气入体', style: TextStyle(color: TianniColors.goldDark2, fontSize: 9)),
        ],
      ),
    );
  }
}

class _SectionDivider extends StatelessWidget {
  final String label;
  const _SectionDivider({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 4, height: 4, decoration: const BoxDecoration(color: TianniColors.gold, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(color: TianniColors.gold, fontSize: 11, letterSpacing: 3)),
        const SizedBox(width: 8),
        const Expanded(child: Divider(color: TianniColors.inkMid, thickness: 0.5)),
      ],
    );
  }
}

class _NextRealmInfo extends StatelessWidget {
  final int realmIndex;
  final int layer;
  final int xpPercent;
  const _NextRealmInfo({required this.realmIndex, required this.layer, required this.xpPercent});

  @override
  Widget build(BuildContext context) {
    final realms = CharacterData.realms;
    final isBreakthrough = layer >= 9;
    final nextRealm = realmIndex < realms.length - 1 ? realms[realmIndex + (isBreakthrough ? 1 : 0)] : '大道尽头';
    final target = isBreakthrough ? '突破至$nextRealm' : '第${layer + 1}层 · $nextRealm';
    return Row(
      children: [
        Text(isBreakthrough ? '破' : '→', style: const TextStyle(color: TianniColors.gold, fontSize: 12)),
        const SizedBox(width: 8),
        Text(target, style: const TextStyle(color: TianniColors.goldBright, fontSize: 12, letterSpacing: 1)),
        const Spacer(),
        if (isBreakthrough)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(border: Border.all(color: TianniColors.crimson)),
            child: const Text('需手动突破', style: TextStyle(color: TianniColors.crimson, fontSize: 9)),
          ),
      ],
    );
  }
}

class _RateRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _RateRow({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Row(
        children: [
          Container(width: 3, height: 3, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(color: TianniColors.goldDim, fontSize: 10)),
          const Spacer(),
          Text(value, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

// ============================================================
// 洞府面板
// ============================================================
class _BattlePanel extends StatelessWidget {
  const _BattlePanel();

  @override
  Widget build(BuildContext context) {
    final items = [
      {'name': '天元城郊', 'level': '1-20阶', 'monster': '炼气妖兽', 'reward': '修为 灵石', 'danger': '★☆☆'},
      {'name': '苍穹秘境', 'level': '30-50阶', 'monster': '筑基妖王', 'reward': '法宝 功法', 'danger': '★★☆'},
      {'name': '魔渊深处', 'level': '60+阶', 'monster': '元婴魔尊', 'reward': '传承 神器', 'danger': '★★★'},
    ];

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        const Text('征\u3000战', textAlign: TextAlign.center,
          style: TextStyle(color: TianniColors.gold, fontSize: 14, letterSpacing: 4),
        ),
        const SizedBox(height: 8),
        const InkDivider(thin: true),
        const SizedBox(height: 8),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: AncientBorder(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(item['name']!, style: const TextStyle(color: TianniColors.parchment, fontSize: 13, letterSpacing: 2)),
                          const SizedBox(width: 6),
                          Text(item['level']!, style: const TextStyle(color: TianniColors.goldDark, fontSize: 9)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text('妖兽：${item['monster']}', style: const TextStyle(color: TianniColors.goldDim, fontSize: 9)),
                          const SizedBox(width: 12),
                          Text('危险：${item['danger']}', style: const TextStyle(color: TianniColors.crimson, fontSize: 9)),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text('掉落：${item['reward']}', style: const TextStyle(color: TianniColors.goldDark2, fontSize: 9)),
                    ],
                  ),
                ),
                AncientButton(text: '出征', fontSize: 11, letterSpacing: 2,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  onTap: () {
                    TianniDialog.show(
                      context,
                      title: '出\u3000征',
                      subtitle: '天元城郊 · 1-20阶',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          _DialogRow(label: '妖兽', value: '炼气妖兽'),
                          SizedBox(height: 8),
                          _DialogRow(label: '危险', value: '★☆☆'),
                          SizedBox(height: 8),
                          _DialogRow(label: '掉落', value: '修为 灵石'),
                        ],
                      ),
                      actions: [
                        DialogAction(text: '踏入战场', onTap: () => Navigator.of(context).pop()),
                        DialogAction(text: '暂不前往', isPrimary: false),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        )),
      ],
    );
  }
}

// ============================================================
// 游历面板
// ============================================================
class _SectPanel extends StatelessWidget {
  const _SectPanel();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        const Text('宗\u3000门', textAlign: TextAlign.center,
          style: TextStyle(color: TianniColors.gold, fontSize: 14, letterSpacing: 4),
        ),
        const SizedBox(height: 8),
        const InkDivider(thin: true),
        const SizedBox(height: 8),

        // 宗门主卡
        AncientBorder(
          gold: true,
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(border: Border.all(color: TianniColors.gold)),
                    alignment: Alignment.center,
                    child: const Text('劍', style: TextStyle(color: TianniColors.gold, fontSize: 18)),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('天剑宗', style: TextStyle(color: TianniColors.goldBright, fontSize: 14, letterSpacing: 3)),
                      const SizedBox(height: 2),
                      const Text('宗门等级 Lv.42 · 人数 388', style: TextStyle(color: TianniColors.goldDim, fontSize: 10)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const InkDivider(thin: true),
              const SizedBox(height: 8),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _SectStat(value: '12,800', label: '宗门贡献'),
                  _SectStat(value: '5,240', label: '功勋'),
                  _SectStat(value: '长老', label: '职位'),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // 子项
        ...[
          {'label': '宗门任务', 'value': '3个待完成', 'color': TianniColors.crimson},
          {'label': '宗门秘境', 'value': '今日可进入', 'color': TianniColors.gold},
          {'label': '传功长老', 'value': '可领取功法', 'color': TianniColors.goldDim},
        ].map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: AncientBorder(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(item['label'] as String,
                  style: const TextStyle(color: TianniColors.goldDim, fontSize: 12, letterSpacing: 2),
                ),
                Text(item['value'] as String,
                  style: TextStyle(color: item['color'] as Color, fontSize: 11),
                ),
              ],
            ),
          ),
        )),
      ],
    );
  }
}

class _SectStat extends StatelessWidget {
  final String value, label;
  const _SectStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: TianniColors.gold, fontSize: 12)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: TianniColors.goldDark2, fontSize: 9)),
      ],
    );
  }
}

// ============================================================
// 储物面板
// ============================================================
class _BagPanel extends ConsumerStatefulWidget {
  final int slotIndex;
  const _BagPanel({this.slotIndex = 0});

  @override
  ConsumerState<_BagPanel> createState() => _BagPanelState();
}

class _BagPanelState extends ConsumerState<_BagPanel> {
  static const _cols = 5;
  String _activeTab = '全部';
  String _query = '';
  final _searchCtrl = TextEditingController();

  static const _tabs = ['全部', '丹药', '材料', '装备', '符箓'];

  List<InventorySlot> get _allItems {
    final inv = ref.watch(inventoryProvider(widget.slotIndex));
    return inv.toList();
  }

  List<InventorySlot> get _filtered {
    var list = _allItems;
    if (_activeTab == '丹药') list = list.where((s) => s.cat == ItemCategory.pill).toList();
    if (_activeTab == '材料') list = list.where((s) => s.cat == ItemCategory.mat).toList();
    if (_activeTab == '装备') list = list.where((s) => s.cat == ItemCategory.equip).toList();
    if (_activeTab == '符箓') list = list.where((s) => s.cat == ItemCategory.talisman).toList();
    if (_query.isNotEmpty) list = list.where((s) => s.name.contains(_query)).toList();
    return list;
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inv = ref.watch(inventoryProvider(widget.slotIndex));
    final usedSlots = inv.usedSlots;
    final isFiltering = _activeTab != '全部' || _query.isNotEmpty;
    // 全部分类：严格按底层 slots 数组渲染，保留空洞
    // 过滤/搜索：紧凑展示匹配项
    final List<InventorySlot?> displayItems = isFiltering
        ? [..._filtered.cast<InventorySlot?>()]
        : inv.slots.toList();

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.translucent,
      child: Column(
        children: [
          // 标题 + 容量 + 整理按钮
          Padding(
          padding: const EdgeInsets.fromLTRB(14, 8, 14, 4),
          child: Row(
            children: [
              Container(width: 4, height: 4, decoration: const BoxDecoration(color: TianniColors.gold, shape: BoxShape.circle)),
              const SizedBox(width: 6),
              const Text('储 物', style: TextStyle(color: TianniColors.goldBright, fontSize: 14, letterSpacing: 4)),
              const Spacer(),
              isFiltering ? const SizedBox.shrink() : GestureDetector(
                onTap: () => ref.read(inventoryProvider(widget.slotIndex).notifier).compact(),
                child: const Text('整 理', style: TextStyle(color: TianniColors.goldDark, fontSize: 10, letterSpacing: 3)),
              ),
              const SizedBox(width: 10),
              Text('$usedSlots / ${inv.capacity}',
                style: const TextStyle(color: TianniColors.gold, fontSize: 11)),
              const SizedBox(width: 4),
              const Text('格', style: TextStyle(color: TianniColors.goldDark2, fontSize: 9)),
            ],
          ),
        ),
        // 搜索 + 分类 Tab
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 30,
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: (v) => setState(() => _query = v),
                    style: const TextStyle(color: TianniColors.goldBright, fontSize: 11),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                      filled: true,
                      fillColor: TianniColors.bgDark,
                      hintText: '搜索物品',
                      hintStyle: const TextStyle(color: TianniColors.goldDark2, fontSize: 10),
                      prefixIcon: const Icon(Icons.search, color: TianniColors.goldDark2, size: 14),
                      suffixIcon: _query.isNotEmpty
                          ? GestureDetector(
                              onTap: () { _searchCtrl.clear(); setState(() => _query = ''); },
                              child: const Icon(Icons.close, color: TianniColors.goldDark2, size: 14),
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.zero,
                        borderSide: const BorderSide(color: TianniColors.inkLight),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.zero,
                        borderSide: const BorderSide(color: TianniColors.inkLight),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.zero,
                        borderSide: const BorderSide(color: TianniColors.goldDark),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          height: 28,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            children: _tabs.map((tab) {
              final active = _activeTab == tab;
              return GestureDetector(
                onTap: () => setState(() => _activeTab = tab),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  margin: const EdgeInsets.only(right: 6),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: active ? TianniColors.gold : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                  ),
                  child: Text(tab,
                    style: TextStyle(
                      color: active ? TianniColors.goldBright : TianniColors.goldDark,
                      fontSize: 11, letterSpacing: 2,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        Container(height: 0.5, color: TianniColors.inkMid, margin: const EdgeInsets.symmetric(horizontal: 14)),
        const SizedBox(height: 4),
        // 格子
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.fromLTRB(10, 2, 10, 10),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: _cols,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
              childAspectRatio: 1.05,
            ),
            itemCount: isFiltering ? (displayItems.length + 1) : inv.capacity,
            itemBuilder: (context, index) {
              if (isFiltering) {
                if (index < displayItems.length && displayItems[index] != null) {
                  return _BagSlot(slot: displayItems[index]!, slotIndex: widget.slotIndex);
                }
                return const _EmptySlot();
              } else {
                final slotData = displayItems[index];
                if (slotData != null) {
                  return _BagSlot(slot: slotData, slotIndex: widget.slotIndex);
                }
                return const _EmptySlot();
              }
            },
          ),
        ),
      ],
      ),
    );
  }
}

class _BagSlot extends ConsumerWidget {
  final InventorySlot slot;
  final int slotIndex;
  const _BagSlot({required this.slot, this.slotIndex = 0});

  String get _countText => slot.count > 99 ? '99+' : '${slot.count}';

  String catLabel(ItemCategory cat) => switch (cat) {
        ItemCategory.pill => '丹药',
        ItemCategory.mat => '材料',
        ItemCategory.equip => '装备',
        ItemCategory.talisman => '符箓',
        ItemCategory.skill => '功法',
        ItemCategory.junk => '杂物',
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gColor = gradeColor(slot.grade);
    return GestureDetector(
      onTap: () => _showDetail(context, ref),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: gColor.withValues(alpha: 0.55)),
          color: const Color.fromRGBO(10, 7, 2, 0.8),
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(slot.name[0],
                    style: TextStyle(color: gColor, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(catLabel(slot.cat),
                    style: const TextStyle(color: TianniColors.goldDark2, fontSize: 8, letterSpacing: 1),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 2, top: 1,
              child: Text(gradeLabel(slot.grade),
                style: TextStyle(color: gColor.withValues(alpha: 0.7), fontSize: 8),
              ),
            ),
            Positioned(
              right: 2, bottom: 2,
              child: Text(_countText,
                style: const TextStyle(color: TianniColors.goldDark, fontSize: 9, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDetail(BuildContext context, WidgetRef ref) {
    final tmpl = slot.template;
    final desc = tmpl?.desc ?? '';
    final effectsText = tmpl?.effects
            ?.map((e) => e.desc ?? '${effectLabel(e.type)} +${e.value.toStringAsFixed(0)}')
            .join('\n') ?? '';
    final statsText = tmpl?.baseStats
            ?.entries.map((e) => '${statLabel(e.key)} +${e.value.toStringAsFixed(0)}')
            .join(' · ') ?? '';

    TianniDialog.show(
      context,
      title: slot.name,
      subtitle: '${gradeLabel(slot.grade)} · ${catLabel(slot.cat)} · 数量 ${slot.count}',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (desc.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(desc, style: const TextStyle(color: TianniColors.goldDim, fontSize: 11, letterSpacing: 1)),
            ),
          if (statsText.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(statsText, style: const TextStyle(color: TianniColors.gold, fontSize: 11)),
            ),
          if (effectsText.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(effectsText, style: const TextStyle(color: TianniColors.goldDark, fontSize: 10)),
            ),
          if (tmpl?.realmRequired != null)
            Text('需求: ${CharacterData.realms[tmpl!.realmRequired ?? 0]}',
              style: const TextStyle(color: TianniColors.crimson, fontSize: 10)),
        ],
      ),
      actions: [
        DialogAction(
          text: slot.cat == ItemCategory.pill ? '服用' : 
                slot.cat == ItemCategory.equip ? '装备' :
                slot.cat == ItemCategory.skill ? '学习' :
                '使用',
          isPrimary: true,
          onTap: () {
            if (slot.cat == ItemCategory.pill) {
              Navigator.of(context).pop();
              _usePill(context, ref);
            } else if (slot.cat == ItemCategory.equip) {
              Navigator.of(context).pop();
              _equipItem(context, ref);
            } else {
              Navigator.of(context).pop();
              ref.read(inventoryProvider(slotIndex)).removeItem(slot.itemId, 1);
              Navigator.of(context).pop();
              TianniToast.show(context, '使用了 1 个 ${slot.name}');
            }
          },
        ),
        DialogAction(
          text: '丢弃',
          isPrimary: false,
          onTap: () {
            Navigator.of(context).pop();
            ref.read(inventoryProvider(slotIndex)).removeItem(slot.itemId, slot.count);
            TianniToast.show(context, '丢弃了 ${slot.name} ×${slot.count}');
          },
        ),
      ],
    );
  }

  void _usePill(BuildContext context, WidgetRef ref) {
    final tmpl = slot.template;
    if (tmpl == null) return;
    final boost = tmpl.effects?.where((e) => e.type == 'cultivateBoost').firstOrNull;
    if (boost != null) {
      // 修炼加速 buff 后续由修炼系统读取
    }
    ref.read(inventoryProvider(slotIndex)).removeItem(slot.itemId, 1);
    TianniToast.show(context, '服用了 ${slot.name}');
  }

  void _equipItem(BuildContext context, WidgetRef ref) {
    final tmpl = slot.template;
    if (tmpl == null) {
      TianniToast.show(context, '物品模板未找到');
      return;
    }
    final equipType = tmpl.equipSlot;
    if (equipType == null) {
      TianniToast.show(context, '此物品不可装备');
      return;
    }
    final eqType = switch (equipType) {
      EquipSlot.weapon => 'weapon',
      EquipSlot.armor => 'armor',
      EquipSlot.accessory => 'accessory',
      EquipSlot.artifact => 'artifact',
    };
    final copySlot = InventorySlot(itemId: slot.itemId, count: 1, slotIdx: slot.slotIdx, data: slot.data);
    final ok = ref.read(equipmentProvider(slotIndex).notifier).equip(eqType, copySlot);
    ok.then((success) {
      if (success) {
        TianniToast.show(context, '装备了 ${slot.name}');
      } else {
        TianniToast.show(context, '装备失败');
      }
    });
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 48,
            child: Text(label, style: const TextStyle(color: TianniColors.goldDark, fontSize: 11, letterSpacing: 2)),
          ),
          const Text('  ', style: TextStyle(color: TianniColors.goldDark2)),
          Expanded(
            child: Text(value, style: const TextStyle(color: TianniColors.goldBright, fontSize: 13, letterSpacing: 2)),
          ),
        ],
      ),
    );
  }
}

class _EmptySlot extends StatelessWidget {
  const _EmptySlot();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: TianniColors.inkLight.withValues(alpha: 0.25)),
        color: const Color.fromRGBO(5, 3, 1, 0.35),
      ),
      alignment: Alignment.center,
      child: const Text('＋', style: TextStyle(color: TianniColors.goldDark2, fontSize: 14, fontWeight: FontWeight.w100)),
    );
  }
}

// ── 装备面板 ──
class _EquipPanel extends ConsumerWidget {
  final int slotIndex;
  const _EquipPanel({required this.slotIndex});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final equips = ref.watch(equipmentProvider(slotIndex));
    final charAsync = ref.watch(characterProvider(slotIndex));

    return charAsync.when(
      data: (char) => _buildBody(ref, equips, char),
      loading: () => const Center(child: Text('加载中…', style: TextStyle(color: TianniColors.goldDim))),
      error: (_, __) => const Center(child: Text('读取角色数据失败', style: TextStyle(color: TianniColors.crimson))),
    );
  }

  Widget _buildBody(WidgetRef ref, Equipment equips, CharacterData? char) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 4, height: 4, decoration: const BoxDecoration(color: TianniColors.gold, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          const Text('装 备', style: TextStyle(color: TianniColors.goldBright, fontSize: 14, letterSpacing: 4)),
        ]),
        const SizedBox(height: 10),
        if (char != null) ...
          _buildStats(ref, char),
        const SizedBox(height: 14),
        ...Equipment.defaultTypes.map((t) => _EquipSlotRow(equipType: t, label: Equipment.labels[t] ?? t, item: equips.slots[t], slotIndex: slotIndex)),
      ]),
    );
  }

  List<Widget> _buildStats(WidgetRef ref, CharacterData char) {
    final c = ref.watch(combatStatsProvider((slot: slotIndex, char: char)));
    return [Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(border: Border.all(color: TianniColors.inkLight)), child: Column(children: [
      _s('生命', '${c.maxHp}', TianniColors.crimson),
      _s('灵力', '${c.maxQi}', const Color(0xFF4A90D9)),
      _s('攻击', '${c.attack}', Colors.amber),
      _s('防御', '${c.defense}', TianniColors.gold),
      _s('法抗', '${c.magicResist}', const Color(0xFF9B6FD4)),
      _s('暴率', '${(c.critRate * 100).toStringAsFixed(1)}%', TianniColors.goldBright),
    ]))];
  }

  Widget _s(String label, String value, Color color) => Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Row(children: [
      SizedBox(width: 40, child: Text(label, style: const TextStyle(color: TianniColors.goldDark, fontSize: 11))),
      Expanded(child: Text(value, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w600))),
    ]),
  );
}

class _EquipSlotRow extends ConsumerWidget {
  final String equipType, label;
  final InventorySlot? item;
  final int slotIndex;
  const _EquipSlotRow({required this.equipType, required this.label, required this.item, required this.slotIndex});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final has = item != null;
    return GestureDetector(
      onTap: has ? () => _unequip(context, ref) : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(border: Border.all(color: has ? gradeColor(item!.grade) : TianniColors.inkLight), color: has ? const Color.fromRGBO(10, 7, 2, 0.8) : TianniColors.bgDark),
        child: Row(children: [
          SizedBox(width: 44, child: Text(label, style: TextStyle(color: TianniColors.goldDim, fontSize: 12, letterSpacing: 2))),
          Expanded(child: Text(has ? item!.name : '—  空置', style: TextStyle(color: has ? gradeColor(item!.grade) : TianniColors.goldDark2, fontSize: 13))),
          if (has) Text(gradeLabel(item!.grade), style: TextStyle(color: gradeColor(item!.grade).withValues(alpha: 0.7), fontSize: 9)),
        ]),
      ),
    );
  }

  void _unequip(BuildContext context, WidgetRef ref) {
    TianniDialog.show(context, title: item!.name, subtitle: gradeLabel(item!.grade), child: const Text('确定要卸下这件装备吗？', style: TextStyle(color: TianniColors.goldDim, fontSize: 12)), actions: [
      DialogAction(text: '卸下', isPrimary: true, onTap: () {
        Navigator.of(context).pop();
        ref.read(equipmentProvider(slotIndex).notifier).unequip(equipType).then((ok) {
          if (!ok) TianniToast.show(context, '储物袋已满，无法卸下');
        });
      }),
      DialogAction(text: '取消', onTap: () => Navigator.of(context).pop()),
    ]);
  }
}

// ── 占位面板 ──
class _PlaceholderPanel extends StatelessWidget {
  final String label;
  final String desc;
  const _PlaceholderPanel({required this.label, required this.desc});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: TianniColors.goldDark2),
            ),
            alignment: Alignment.center,
            child: Text('✦', style: const TextStyle(color: TianniColors.goldDim, fontSize: 18)),
          ),
          const SizedBox(height: 12),
          Text(label, style: const TextStyle(color: TianniColors.goldBright, fontSize: 14, letterSpacing: 4)),
          const SizedBox(height: 6),
          Text(desc, style: const TextStyle(color: TianniColors.goldDark2, fontSize: 10)),
        ],
      ),
    );
  }
}

// ── 弹窗数据行 ──
class _DialogRow extends StatelessWidget {
  final String label, value;
  const _DialogRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
          style: const TextStyle(color: TianniColors.goldDim, fontSize: 12, letterSpacing: 2),
        ),
        Text(value,
          style: const TextStyle(color: TianniColors.goldBright, fontSize: 12, letterSpacing: 1),
        ),
      ],
    );
  }
}
