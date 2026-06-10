import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/colors.dart';
import '../widgets/ancient_border.dart';
import '../widgets/tianni_dialog.dart';
import '../widgets/tianni_feedback.dart';
import '../models/character_data.dart';
import '../services/character_storage.dart';

class CharacterSelectPage extends StatefulWidget {
  const CharacterSelectPage({super.key});

  @override
  State<CharacterSelectPage> createState() => _CharacterSelectPageState();
}

class _CharacterSelectPageState extends State<CharacterSelectPage> {
  List<CharacterData?> _slots = List.filled(5, null);

  @override
  void initState() {
    super.initState();
    _loadSlots();
  }

  Future<void> _loadSlots() async {
    final slots = await CharacterStorage.loadAll();
    if (mounted) setState(() => _slots = slots);
  }

  void _confirmExit(BuildContext context) {
    TianniMessageBox.show(
      context: context,
      title: '退出游戏',
      message: '道友，确定要离开此界吗？',
      onConfirm: () {
        SystemNavigator.pop();
      },
      onCancel: () {},
    );
  }

  Color _realmColor(int realmIndex) {
    if (realmIndex <= 2) return TianniColors.goldDim;
    if (realmIndex <= 5) return const Color(0xFFA08040);
    if (realmIndex <= 8) return TianniColors.gold;
    if (realmIndex <= 11) return TianniColors.goldBright;
    if (realmIndex <= 16) return const Color(0xFF9B6FD4);
    return TianniColors.crimson;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmExit(context);
      },
      child: Scaffold(
        backgroundColor: TianniColors.bg,
        body: Center(
          child: SizedBox(
            width: 375, height: 812,
            child: Column(
            children: [
              const _TopOrnament(),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('道友，择一道身入世',
                          style: GoogleFonts.notoSerifSc(color: TianniColors.goldDim, fontSize: 10, letterSpacing: 2),
                        ),
                        const SizedBox(height: 3),
                        Text('选择道身',
                          style: GoogleFonts.maShanZheng(color: TianniColors.gold, fontSize: 22, letterSpacing: 6),
                        ),
                      ],
                    ),
                    Opacity(
                      opacity: 0.5,
                      child: Column(
                        children: ['仙', '身', '千', '面'].map((c) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 1),
                          child: Text(c, style: const TextStyle(color: TianniColors.goldDark, fontSize: 9)),
                        )).toList(),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
                  itemCount: CharacterStorage.maxSlots,
                  itemBuilder: (_, i) {
                    final slot = i < _slots.length ? _slots[i] : null;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: slot != null
                          ? _CharCard(character: slot, index: i, realmColor: _realmColor(slot.realmIndex))
                          : _EmptySlot(index: i),
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 20),
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: TianniColors.inkLight, width: 1)),
                ),
                child: const SizedBox(width: 335, child: _QuoteCarousel()),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}

class _QuoteCarousel extends StatefulWidget {
  const _QuoteCarousel();
  @override
  State<_QuoteCarousel> createState() => _QuoteCarouselState();
}

class _QuoteCarouselState extends State<_QuoteCarousel> {
  static const _quotes = [
    '凡人之躯，亦可比肩神明。',
    '道之一途，唯诚唯坚。',
    '天地为炉，造化为工。',
    '以我之血，证我之道。',
    '大道三千，各取一瓢。',
    '朝闻道，夕死可矣。',
    '一剑破万法，一念通九天。',
    '天行有常，不为尧存。',
    '修道之路，始于足下。',
    '万法皆空，因果不空。',
  ];
  int _index = 0;

  @override
  void initState() {
    super.initState();
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 6));
      if (!mounted) return false;
      setState(() => _index = (_index + 1) % _quotes.length);
      return true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 600),
      child: Text(_quotes[_index],
        key: ValueKey(_index),
        textAlign: TextAlign.center,
        style: GoogleFonts.liuJianMaoCao(color: TianniColors.goldDark2, fontSize: 11, letterSpacing: 3),
      ),
    );
  }
}

class _CharCard extends StatelessWidget {
  final CharacterData character;
  final int index;
  final Color realmColor;

  const _CharCard({required this.character, required this.index, required this.realmColor});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showDetail(context),
      child: AncientBorder(
        gold: true,
        padding: const EdgeInsets.fromLTRB(14, 16, 14, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Transform.rotate(
                  angle: 0.785,
                  child: Container(
                    width: 22, height: 22,
                    decoration: BoxDecoration(border: Border.all(color: TianniColors.gold)),
                    alignment: Alignment.center,
                    child: Transform.rotate(
                      angle: -0.785,
                      child: Text('${index + 1}', style: const TextStyle(color: TianniColors.gold, fontSize: 10)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(character.fullName,
                  style: GoogleFonts.maShanZheng(color: TianniColors.goldBright, fontSize: 18, letterSpacing: 3),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(border: Border.all(color: realmColor, width: 0.8)),
                  child: Text(character.realmName,
                    style: TextStyle(color: realmColor, fontSize: 9, letterSpacing: 2),
                  ),
                ),
                const Spacer(),
                Text('${_realmLayerText()}',
                  style: TextStyle(color: realmColor, fontSize: 10, letterSpacing: 1),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text('${character.rootElement}灵根 · ${character.rootPurity}',
                  style: const TextStyle(color: TianniColors.goldDark2, fontSize: 9, letterSpacing: 2),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(border: Border.all(color: TianniColors.goldDark2, width: 0.5)),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: character.xpPercent / 100.0,
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(colors: [TianniColors.goldDark, TianniColors.gold]),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Text('${character.xpPercent}%',
                  style: const TextStyle(color: TianniColors.goldDark, fontSize: 8, letterSpacing: 1),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right, size: 14, color: TianniColors.gold),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _realmLayerText() {
    final name = character.realmName.replaceAll('期', '境');
    return '$name${_layerText(character.layer)}层';
  }

  static String _layerText(int layer) {
    if (layer <= 10) return const ['零','一','二','三','四','五','六','七','八','九','十'][layer];
    return '${const ['零','一','二','三','四','五','六','七','八','九','十'][layer ~/ 10]}十${const ['零','一','二','三','四','五','六','七','八','九','十'][layer % 10]}';
  }

  void _showDetail(BuildContext context) {
    final c = character;
    final colors = _attrColors();

    TianniDialog.show(
      context,
      barrierDismissible: true,
      title: c.fullName,
      subtitle: '${c.realmName} · ${_layerText(c.layer)}层',
      actions: [
        DialogAction(
          text: '删除',
          isPrimary: false,
          onTap: () {
            Navigator.of(context).pop();
            CharacterStorage.delete(index).then((_) {
              Navigator.of(context).pushNamedAndRemoveUntil('/characters', (route) => false);
            });
          },
        ),
        DialogAction(
          text: '踏入仙途',
          onTap: () {
            Navigator.of(context).pop();
            Navigator.of(context).pushNamed('/game', arguments: index);
          },
        ),
      ],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 灵根
          Row(
            children: [
              const Text('灵根', style: TextStyle(color: TianniColors.goldDim, fontSize: 12, letterSpacing: 2)),
              const SizedBox(width: 12),
              Text('${c.rootElement}灵根 · ${c.rootPurity}',
                style: TextStyle(color: _elemColor(c.rootElement), fontSize: 12, letterSpacing: 1),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // 六维
          _detailBar('体魄', c.con, const Color(0xFFCC3333)),
          _detailBar('神识', c.spi, const Color(0xFF9B6FD4)),
          _detailBar('气海', c.qi, const Color(0xFF4A90D9)),
          _detailBar('道心', c.dao, TianniColors.goldBright),
          _detailBar('悟性', c.ins, const Color(0xFF5B9A3F)),
          _detailBar('根骨', c.bon, const Color(0xFFC8A96E)),
          const SizedBox(height: 10),
          // 战斗属性
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _miniStat('气血', '${c.con * 10}', const Color(0xFFCC3333)),
              _miniStat('灵气', '${c.qi * 8}', const Color(0xFF4A90D9)),
              _miniStat('攻击', '${(c.con * 1.5).round()}', const Color(0xFFD4AF37)),
              _miniStat('速度', '${10 + (c.con * 0.2).round() + (c.spi * 0.1).round()}', const Color(0xFF5B9A3F)),
            ],
          ),
        ],
      ),
    );
  }

  Map<String, Color> _attrColors() => const {};
  Color _elemColor(String e) => switch (e) {
    '金' => const Color(0xFFD4AF37), '木' => const Color(0xFF5B9A3F),
    '水' => const Color(0xFF4A90D9), '火' => const Color(0xFFCC3333),
    '土' => const Color(0xFFB8860B), _ => TianniColors.gold,
  };
  Widget _detailBar(String label, int value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(width: 32, child: Text(label, style: TextStyle(color: color, fontSize: 13, letterSpacing: 1))),
          const SizedBox(width: 8),
          Text('$value', style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 5,
              decoration: BoxDecoration(color: TianniColors.inkLight, border: Border.all(color: TianniColors.inkMid, width: 0.4)),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: ((value - (label == '道心' ? 30 : 5)) / (label == '道心' ? 40 : 13)).clamp(0.0, 1.0),
                child: Container(color: color.withValues(alpha: 0.6)),
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _miniStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: TianniColors.goldDark2, fontSize: 9, letterSpacing: 1)),
      ],
    );
  }
}

class _EmptySlot extends StatelessWidget {
  final int index;
  const _EmptySlot({required this.index});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed('/create-character'),
      child: AncientBorder(
        gold: false,
        padding: const EdgeInsets.fromLTRB(14, 16, 14, 16),
        child: Row(
          children: [
            Transform.rotate(
              angle: 0.785,
              child: Container(
                width: 22, height: 22,
                decoration: BoxDecoration(border: Border.all(color: TianniColors.goldDark2)),
                alignment: Alignment.center,
                child: Transform.rotate(
                  angle: -0.785,
                  child: Text('${index + 1}', style: const TextStyle(color: TianniColors.goldDark, fontSize: 10)),
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text('＋ 点击创建角色',
                style: TextStyle(color: TianniColors.goldDark2, fontSize: 12, letterSpacing: 3),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopOrnament extends StatelessWidget {
  const _TopOrnament();
  @override
  Widget build(BuildContext context) {
    return SizedBox(width: 375, height: 44, child: CustomPaint(painter: _TopOrnamentPainter()));
  }
}

class _TopOrnamentPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paintLine = Paint()..color = const Color(0xFF3A2C14)..strokeWidth = 0.8;
    final paintLine2 = Paint()..color = const Color(0xFF1A1208)..strokeWidth = 0.4;
    final paintPolygon = Paint()..color = const Color(0xFF5A4420)..strokeWidth = 0.8..style = PaintingStyle.stroke;
    final paintPolygonInner = Paint()..color = const Color(0xFF3A2C14)..strokeWidth = 0.5..style = PaintingStyle.stroke;
    final paintDot = Paint()..color = const Color(0xFFC8A96E)..style = PaintingStyle.fill;
    final paintExtLine = Paint()..color = const Color(0xFF1A1208)..strokeWidth = 0.5;

    canvas.drawLine(const Offset(0, 43), Offset(375, 43), paintLine);
    canvas.drawLine(const Offset(0, 40), Offset(375, 40), paintLine2);
    final diamond = Path()..moveTo(187.5, 8)..lineTo(196, 20)..lineTo(187.5, 32)..lineTo(179, 20)..close();
    canvas.drawPath(diamond, paintPolygon);
    final diamondInner = Path()..moveTo(187.5, 12)..lineTo(193, 20)..lineTo(187.5, 28)..lineTo(182, 20)..close();
    canvas.drawPath(diamondInner, paintPolygonInner);
    canvas.drawCircle(const Offset(187.5, 20), 1.5, paintDot);
    canvas.drawLine(const Offset(0, 20), Offset(170, 20), paintExtLine);
    canvas.drawLine(const Offset(205, 20), Offset(375, 20), paintExtLine);
    for (final x in [60.0, 120.0, 255.0, 315.0]) {
      final d = Path()..moveTo(x, 16)..lineTo(x + 4, 20)..lineTo(x, 24)..lineTo(x - 4, 20)..close();
      canvas.drawPath(d, Paint()..color = const Color(0xFF3A2C14)..strokeWidth = 0.5..style = PaintingStyle.stroke);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
