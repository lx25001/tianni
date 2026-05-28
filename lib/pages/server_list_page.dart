import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/colors.dart';
import '../widgets/ancient_border.dart';
import '../widgets/ink_divider.dart';

/// 大区选择页面 (React ServerListPage.tsx)
class ServerListPage extends StatefulWidget {
  const ServerListPage({super.key});

  @override
  State<ServerListPage> createState() => _ServerListPageState();
}

class _ServerListPageState extends State<ServerListPage> {
  // 静态假数据
  final List<Map<String, dynamic>> _servers = const [
    {'name': '太虚仙域', 'desc': '元老大区 · 开服已久', 'character': '云清玄', 'realm': '元婴期', 'online': 8821, 'hot': true},
    {'name': '苍穹云海', 'desc': '活跃大区 · 人气鼎盛', 'character': '', 'realm': '', 'online': 6342, 'hot': true},
    {'name': '青冥幽界', 'desc': '新开大区 · 百废待兴', 'character': '', 'realm': '', 'online': 2105, 'hot': false},
    {'name': '玄黄混沌', 'desc': '经典大区 · 老区合并', 'character': '', 'realm': '', 'online': 4570, 'hot': false},
    {'name': '渡劫天门', 'desc': '特殊大区 · 高难模式', 'character': '', 'realm': '', 'online': 1280, 'hot': false},
    {'name': '无极混元', 'desc': '新开大区 · 新手友好', 'character': '', 'realm': '', 'online': 890, 'hot': false},
  ];

  Color _realmColor(String realm) {
    if (realm == '元婴期') return TianniColors.gold;
    if (realm == '化神期') return const Color(0xFF9B6FD4);
    if (realm == '渡劫期') return TianniColors.crimson;
    return TianniColors.goldDim;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TianniColors.bg,
      body: Center(
        child: SizedBox(
          width: 375,
          height: 812,
          child: Column(
            children: [
              // ── 顶部装饰 ──
              const _TopOrnament(),

              // ── 标题栏 ──
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('道友 道友，择一界域入驻',
                          style: TextStyle(color: TianniColors.goldDim, fontSize: 10, letterSpacing: 2),
                        ),
                        const SizedBox(height: 3),
                        const Text('选择大区',
                          style: TextStyle(color: TianniColors.gold, fontSize: 20, letterSpacing: 6),
                        ),
                      ],
                    ),
                    // 右侧竖排小字
                    Opacity(
                      opacity: 0.5,
                      child: Column(
                        children: ['仙', '路', '万', '里'].map((c) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 1),
                          child: Text(c, style: const TextStyle(color: TianniColors.goldDark, fontSize: 9)),
                        )).toList(),
                      ),
                    ),
                  ],
                ),
              ),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: InkDivider(text: '界域列表'),
              ),
              const SizedBox(height: 4),

              // ── 大区说明 ──
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                child: Row(
                  children: [
                    _LegendDot(color: TianniColors.gold, label: '有角色'),
                    SizedBox(width: 12),
                    _LegendDot(color: TianniColors.goldDark2, label: '无角色，点击创建'),
                  ],
                ),
              ),

              // ── 大区列表 ──
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                  itemCount: _servers.length,
                  itemBuilder: (context, index) {
                    final server = _servers[index];
                    final hasChar = (server['character'] as String).isNotEmpty;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: GestureDetector(
                        onTap: () {
                          if (hasChar) {
                            Navigator.of(context).pushNamed('/game');
                          } else {
                            Navigator.of(context).pushNamed('/create-character');
                          }
                        },
                        child: AncientBorder(
                        gold: hasChar,
                        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                        child: Row(
                          children: [
                            // 序号
                            Transform.rotate(
                              angle: 0.785, // 45deg
                              child: Container(
                                width: 24, height: 24,
                                decoration: BoxDecoration(
                                  border: Border.all(color: hasChar ? TianniColors.gold : TianniColors.goldDark2),
                                ),
                                alignment: Alignment.center,
                                child: Transform.rotate(
                                  angle: -0.785,
                                  child: Text('${index + 1}',
                                    style: TextStyle(color: hasChar ? TianniColors.gold : TianniColors.goldDark, fontSize: 10),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),

                            // 大区信息
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(server['name'] as String,
                                        style: TextStyle(
                                          color: hasChar ? TianniColors.gold : TianniColors.parchment,
                                          fontSize: 16, letterSpacing: 2,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      if (server['hot'] == true)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                          decoration: BoxDecoration(
                                            border: Border.all(color: TianniColors.crimson),
                                          ),
                                          child: const Text('火',
                                            style: TextStyle(color: TianniColors.crimson, fontSize: 9, letterSpacing: 1),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 3),
                                  Row(
                                    children: [
                                      Text(server['desc'] as String,
                                        style: const TextStyle(color: TianniColors.goldDark, fontSize: 10),
                                      ),
                                      const SizedBox(width: 10),
                                      Text('在线 ${(server['online'] as int)}',
                                        style: const TextStyle(color: TianniColors.goldDark2, fontSize: 10),
                                      ),
                                    ],
                                  ),
                                  if (hasChar) ...[
                                    const SizedBox(height: 5),
                                    Row(
                                      children: [
                                        Container(width: 1, height: 14, color: TianniColors.goldDark),
                                        const SizedBox(width: 6),
                                        Text(server['character'] as String,
                                          style: const TextStyle(color: TianniColors.goldBright, fontSize: 12, letterSpacing: 2),
                                        ),
                                        const SizedBox(width: 6),
                                        Text('· ${server['realm']}',
                                          style: TextStyle(color: _realmColor(server['realm'] as String), fontSize: 10),
                                        ),
                                      ],
                                    ),
                                  ] else ...[
                                    const SizedBox(height: 5),
                                    const Text('＋ 点此创建角色',
                                      style: TextStyle(color: TianniColors.goldDark2, fontSize: 10, letterSpacing: 2),
                                    ),
                                  ],
                                ],
                              ),
                            ),

                            // 右箭头
                            Icon(Icons.chevron_right, size: 14,
                              color: hasChar ? TianniColors.gold : TianniColors.goldDark2,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                  },
                ),
              ),

              // ── 底部装饰 ──
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: TianniColors.inkLight, width: 1)),
                ),
                child: Center(
                  child: Text('◆ 择界而入，问道长生 ◆',
                    style: GoogleFonts.liuJianMaoCao(color: TianniColors.goldDark2, fontSize: 10, letterSpacing: 3),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Transform.rotate(
          angle: 0.785,
          child: Container(
            width: 6, height: 6,
            decoration: BoxDecoration(
              border: Border.all(color: color),
            ),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(color: color == TianniColors.gold ? TianniColors.goldDim : TianniColors.goldDark, fontSize: 10, letterSpacing: 1)),
      ],
    );
  }
}

// ── 顶部装饰纹 SVG → CustomPaint ──
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

    // 中央菱形
    final diamond = Path()
      ..moveTo(187.5, 8)..lineTo(196, 20)..lineTo(187.5, 32)..lineTo(179, 20)..close();
    canvas.drawPath(diamond, paintPolygon);

    final diamondInner = Path()
      ..moveTo(187.5, 12)..lineTo(193, 20)..lineTo(187.5, 28)..lineTo(182, 20)..close();
    canvas.drawPath(diamondInner, paintPolygonInner);

    canvas.drawCircle(const Offset(187.5, 20), 1.5, paintDot);

    // 两侧延伸线
    canvas.drawLine(const Offset(0, 20), Offset(170, 20), paintExtLine);
    canvas.drawLine(const Offset(205, 20), Offset(375, 20), paintExtLine);

    // 侧边装饰菱形
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
