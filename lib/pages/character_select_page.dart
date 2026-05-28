import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/colors.dart';
import '../widgets/ancient_border.dart';

/// 角色选择页面 — 5个槽位，空位显示＋，同古风风格
class CharacterSelectPage extends StatefulWidget {
  const CharacterSelectPage({super.key});

  @override
  State<CharacterSelectPage> createState() => _CharacterSelectPageState();
}

class _CharacterSelectPageState extends State<CharacterSelectPage> {
  // 假数据：1个已有角色，4个空位
  final List<Map<String, dynamic>?> _slots = [
    {
      'name': '云清玄',
      'realm': '元婴期',
      'layer': 6,     // 元婴境六层
      'xp': 75,       // 进度百分比
      'title': '青云门首席',
    },
    null,  // 空位
    null,
    null,
    null,
  ];

  static const _cnDigits = ['零','一','二','三','四','五','六','七','八','九','十'];

  static String _layerText(int layer) {
    if (layer <= 10) return _cnDigits[layer];
    return '${_cnDigits[layer ~/ 10]}十${_cnDigits[layer % 10]}';
  }

  static String realmLayerText(String realm, int layer) {
    final name = realm.replaceAll('期', '境');
    return '$name${_layerText(layer)}层';
  }

  static Widget _floatDiamond() {
    return Transform.rotate(
      angle: 0.785,
      child: Container(
        width: 6, height: 6,
        decoration: BoxDecoration(
          border: Border.all(color: TianniColors.goldDark, width: 0.6),
          color: TianniColors.bgCard,
        ),
      ),
    );
  }

  void _showCloudArchive(BuildContext context) {
    // 假云存档数据
    final archives = [
      {'name': '云清玄', 'realm': '元婴境', 'layer': '六层', 'date': '甲辰年·霜月', 'srv': '太虚仙域'},
      {'name': '李青竹', 'realm': '金丹境', 'layer': '三层', 'date': '甲辰年·荷月', 'srv': '苍穹云海'},
      {'name': '柳如烟', 'realm': '筑基境', 'layer': '八层', 'date': '癸卯年·桂月', 'srv': '青冥幽界'},
    ];

    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (ctx) => PopScope(
        child: Center(
          child: SizedBox(
            width: 291,
            child: _CloudArchiveDialog(archives: archives),
          ),
        ),
      ),
    );
  }

  Color _realmColor(String realm) {
    if (realm.contains('炼气')) return TianniColors.goldDim;
    if (realm.contains('筑基')) return const Color(0xFFA08040);
    if (realm.contains('金丹')) return TianniColors.gold;
    if (realm.contains('元婴')) return TianniColors.goldBright;
    if (realm.contains('化神')) return const Color(0xFF9B6FD4);
    if (realm.contains('渡劫')) return TianniColors.crimson;
    if (realm.contains('大乘')) return const Color(0xFFCC3333);
    return TianniColors.goldDim;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TianniColors.bg,
      body: Center(
        child: SizedBox(
          width: 375, height: 812,
          child: Column(
            children: [
              // ── 顶部装饰 ──
              const _TopOrnament(),

              // ── 标题栏 ──
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('道友 道友，择一道身入世',
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

              // ── 角色槽位列表 ──
              Expanded(
                child: Stack(
                  children: [
                    ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
                      itemCount: _slots.length,
                      itemBuilder: (_, i) {
                        final slot = _slots[i];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: slot != null
                              ? _CharCard(
                                  slot: slot,
                                  index: i,
                                  realmColor: _realmColor(slot['realm'] as String),
                                  layerText: realmLayerText(slot['realm'] as String, slot['layer'] as int),
                                )
                              : _EmptySlot(index: i),
                        );
                      },
                    ),

                    // ── 云存档悬浮按钮（右下浮动） ──
                    Positioned(
                      right: 8, bottom: 8,
                      child: GestureDetector(
                        onTap: () => _showCloudArchive(context),
                        child: Container(
                          height: 44,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: TianniColors.goldDark, width: 0.8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _floatDiamond(),
                              const SizedBox(width: 6),
                              Text('云存档', style: GoogleFonts.maShanZheng(color: TianniColors.goldDark, fontSize: 12, letterSpacing: 3)),
                              const SizedBox(width: 6),
                              _floatDiamond(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── 底部：修仙语录 ──
              Container(
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 20),
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: TianniColors.inkLight, width: 1)),
                ),
                child: SizedBox(
                  width: 335,
                  child: _QuoteCarousel(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 修仙语录轮换
class _QuoteCarousel extends StatefulWidget {
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
    // 每 6 秒切换一句
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
      child: Text(
        _quotes[_index],
        key: ValueKey(_index),
        textAlign: TextAlign.center,
        style: GoogleFonts.liuJianMaoCao(
          color: TianniColors.goldDark2,
          fontSize: 11,
          letterSpacing: 3,
        ),
      ),
    );
  }
}

/// 已有角色的卡片
class _CharCard extends StatelessWidget {
  final Map<String, dynamic> slot;
  final int index;
  final Color realmColor;
  final String layerText;

  const _CharCard({
    required this.slot, required this.index, required this.realmColor, required this.layerText,
  });

  @override
  Widget build(BuildContext context) {
    final name = slot['name'] as String;
    final realm = slot['realm'] as String;
    final xp = slot['xp'] as int;
    final title = slot['title'] as String;

    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed('/game'),
      child: AncientBorder(
        gold: true,
        padding: const EdgeInsets.fromLTRB(14, 16, 14, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 第一行：序号 + 名字 + 境界 ──
            Row(
              children: [
                // 序号菱形
                Transform.rotate(
                  angle: 0.785,
                  child: Container(
                    width: 22, height: 22,
                    decoration: BoxDecoration(
                      border: Border.all(color: TianniColors.gold),
                    ),
                    alignment: Alignment.center,
                    child: Transform.rotate(
                      angle: -0.785,
                      child: Text('${index + 1}',
                        style: const TextStyle(color: TianniColors.gold, fontSize: 10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // 名字
                Text(name,
                  style: GoogleFonts.maShanZheng(color: TianniColors.goldBright, fontSize: 18, letterSpacing: 3),
                ),
                const SizedBox(width: 8),

                // 境界标签
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    border: Border.all(color: realmColor, width: 0.8),
                  ),
                  child: Text(realm,
                    style: TextStyle(color: realmColor, fontSize: 9, letterSpacing: 2),
                  ),
                ),

                const Spacer(),

                // 境界层数
                Text(layerText,
                  style: TextStyle(color: realmColor, fontSize: 10, letterSpacing: 1),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // ── 第二行：称号 + 经验条 ──
            Row(
              children: [
                Text(title,
                  style: const TextStyle(color: TianniColors.goldDark2, fontSize: 9, letterSpacing: 2),
                ),
                const SizedBox(width: 10),

                // 经验条
                Expanded(
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      border: Border.all(color: TianniColors.goldDark2, width: 0.5),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: xp / 100.0,
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [TianniColors.goldDark, TianniColors.gold],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Text('$xp%',
                  style: const TextStyle(color: TianniColors.goldDark, fontSize: 8, letterSpacing: 1),
                ),

                const SizedBox(width: 8),
                // 进入箭头
                const Icon(Icons.chevron_right, size: 14, color: TianniColors.gold),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// 空槽位
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
            // 序号菱形
            Transform.rotate(
              angle: 0.785,
              child: Container(
                width: 22, height: 22,
                decoration: BoxDecoration(
                  border: Border.all(color: TianniColors.goldDark2),
                ),
                alignment: Alignment.center,
                child: Transform.rotate(
                  angle: -0.785,
                  child: Text('${index + 1}',
                    style: const TextStyle(color: TianniColors.goldDark, fontSize: 10),
                  ),
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

/// 云存档弹窗
class _CloudArchiveDialog extends StatelessWidget {
  final List<Map<String, dynamic>> archives;

  const _CloudArchiveDialog({required this.archives});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── 弹窗主体 ──
        Container(
          decoration: BoxDecoration(
            color: TianniColors.bgCard,
            border: Border.all(color: TianniColors.goldDark, width: 0.8),
          ),
          width: 260,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── 标题 ──
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 14, 20, 8),
                child: Text('云存档',
                  style: TextStyle(color: TianniColors.parchment, fontSize: 16, letterSpacing: 8),
                ),
              ),

              // ── 存档列表 ──
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                child: Column(
                  children: archives.asMap().entries.map((entry) {
                    final i = entry.key;
                    final isLast = i == archives.length - 1;
                    return Column(
                      children: [
                        _ArchiveRow(archive: entry.value, index: i + 1),
                        if (!isLast) const Padding(
                          padding: EdgeInsets.symmetric(vertical: 6),
                          child: _DotLine(),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        // ── 关闭按钮 ──
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Transform.rotate(
            angle: 0.785,
            child: Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                border: Border.all(color: TianniColors.goldDark2, width: 1),
              ),
              child: Center(
                child: Transform.rotate(
                  angle: -0.785,
                  child: const Text('✕',
                    style: TextStyle(color: TianniColors.goldDim, fontSize: 14),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// 点线分隔
class _DotLine extends StatelessWidget {
  const _DotLine();
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(11, (_) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Container(width: 1.5, height: 0.5, color: TianniColors.goldDark2),
      )),
    );
  }
}

/// 云存档单行
class _ArchiveRow extends StatelessWidget {
  final Map<String, dynamic> archive;
  final int index;

  const _ArchiveRow({required this.archive, required this.index});

  Color _realmColor(String realm) {
    if (realm.contains('元婴')) return TianniColors.goldBright;
    if (realm.contains('金丹')) return TianniColors.gold;
    if (realm.contains('筑基')) return const Color(0xFFA08040);
    return TianniColors.goldDim;
  }

  @override
  Widget build(BuildContext context) {
    final realmColor = _realmColor(archive['realm'] as String);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 序号
        SizedBox(
          width: 22,
          child: Text('$index.',
            style: const TextStyle(color: TianniColors.goldDark, fontSize: 10),
          ),
        ),

        // 信息区
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 第一行：名字
              Text(archive['name'] as String,
                style: const TextStyle(color: TianniColors.parchment, fontSize: 14, letterSpacing: 3),
              ),
              const SizedBox(height: 3),
              // 第二行：境界
              Text('${archive['realm']} · ${archive['layer']}',
                style: TextStyle(color: realmColor, fontSize: 10, letterSpacing: 1),
              ),
              const SizedBox(height: 2),
              // 第三行：服务器 & 日期
              Text('${archive['srv']}  |  ${archive['date']}',
                style: const TextStyle(color: TianniColors.goldDark2, fontSize: 9, letterSpacing: 1),
              ),
            ],
          ),
        ),

        // 下载
        GestureDetector(
          onTap: () => debugPrint('下载：${archive['name']}'),
          child: const Padding(
            padding: EdgeInsets.only(top: 4),
            child: Text('下载',
              style: TextStyle(color: TianniColors.goldDark, fontSize: 11, letterSpacing: 4),
            ),
          ),
        ),
      ],
    );
  }
}

// ── 顶部装饰纹 ──
class _TopOrnament extends StatelessWidget {
  const _TopOrnament();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 375, height: 44,
      child: CustomPaint(painter: _TopOrnamentPainter()),
    );
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

    final diamond = Path()
      ..moveTo(187.5, 8)..lineTo(196, 20)..lineTo(187.5, 32)..lineTo(179, 20)..close();
    canvas.drawPath(diamond, paintPolygon);
    final diamondInner = Path()
      ..moveTo(187.5, 12)..lineTo(193, 20)..lineTo(187.5, 28)..lineTo(182, 20)..close();
    canvas.drawPath(diamondInner, paintPolygonInner);
    canvas.drawCircle(const Offset(187.5, 20), 1.5, paintDot);
    canvas.drawLine(const Offset(0, 20), Offset(170, 20), paintExtLine);
    canvas.drawLine(const Offset(205, 20), Offset(375, 20), paintExtLine);

    for (final x in [60.0, 120.0, 255.0, 315.0]) {
      final sideDiamond = Path()
        ..moveTo(x, 16)..lineTo(x + 4, 20)..lineTo(x, 24)..lineTo(x - 4, 20)..close();
      canvas.drawPath(sideDiamond, Paint()
        ..color = const Color(0xFF3A2C14)..strokeWidth = 0.5..style = PaintingStyle.stroke);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
