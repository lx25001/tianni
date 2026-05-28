import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/colors.dart';
import '../widgets/ancient_border.dart';
import '../widgets/ink_divider.dart';
import '../widgets/ancient_input.dart';
import '../widgets/ancient_button.dart';

/// 注册页面 (React RegisterPage.tsx)
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _accountController = TextEditingController(text: '');
  final TextEditingController _passwordController = TextEditingController(text: '');

  final List<List<double>> _starPositions = const [
    [50, 100], [300, 150], [100, 300], [320, 400], [70, 500],
    [340, 550], [150, 650], [250, 700], [180, 200], [280, 350],
  ];

  @override
  void dispose() {
    _accountController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TianniColors.bg,
      body: Center(
        child: SizedBox(
          width: 375,
          height: 812,
          child: Stack(
            children: [
              // ── 星点背景 ──
              ..._starPositions.map((pos) => Positioned(
                left: pos[0], top: pos[1],
                child: Container(
                  width: 1, height: 1,
                  decoration: BoxDecoration(
                    color: TianniColors.gold.withValues(alpha: 0.35),
                    shape: BoxShape.circle,
                  ),
                ),
              )),

              // ── 侧边卷轴装饰 ──
              const Positioned(top: 180, left: 6, child: _ScrollDecor(side: 'left')),
              const Positioned(top: 180, right: 6, child: _ScrollDecor(side: 'right')),

              // ── 返回按钮 ──
              Positioned(
                top: 20, left: 20,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: const Row(
                    children: [
                      Icon(Icons.chevron_left, size: 14, color: TianniColors.goldDim),
                      SizedBox(width: 4),
                      Text('返回', style: TextStyle(color: TianniColors.goldDim, fontSize: 12, letterSpacing: 2)),
                    ],
                  ),
                ),
              ),

              // ── 主内容 ──
              Positioned.fill(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      const SizedBox(height: 55),

                      // ── 顶部装饰 ──
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Column(children: [
                            _VerticalChar('天'), _VerticalChar('道'),
                            _VerticalChar('立'), _VerticalChar('册'),
                          ]),
                          const SizedBox(width: 10),
                          Column(
                            children: [
                              const Text('立\u3000册',
                                style: TextStyle(
                                  color: TianniColors.gold, fontSize: 32, letterSpacing: 10,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text('创立道籍 · 结缘仙途',
                                style: TextStyle(color: TianniColors.goldDark, fontSize: 11, letterSpacing: 4),
                              ),
                            ],
                          ),
                          const SizedBox(width: 10),
                          const Column(children: [
                            _VerticalChar('仙'), _VerticalChar('途'),
                            _VerticalChar('缘'), _VerticalChar('起'),
                          ]),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 88),
                        child: InkDivider(text: '道籍注录'),
                      ),

                      const SizedBox(height: 30),

                      // ── 注册表单 ──
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 37),
                        child: AncientBorder(
                          gold: true,
                          padding: const EdgeInsets.fromLTRB(26, 28, 26, 24),
                          child: Column(
                            children: [
                              // 顶部标注
                              const Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('◈ 天机密录 ◈', style: TextStyle(color: TianniColors.goldDark2, fontSize: 10, letterSpacing: 1)),
                                  Text('◈ 不可外传 ◈', style: TextStyle(color: TianniColors.goldDark2, fontSize: 10, letterSpacing: 1)),
                                ],
                              ),
                              const SizedBox(height: 20),

                              // 道号
                              const _FieldLabel(label: '道\u3000号', sub: '（修仙名讳）'),
                              const SizedBox(height: 6),
                              AncientInput(
                                hintText: '赐予道号，方可立册',
                                controller: _accountController,
                              ),
                              const SizedBox(height: 24),

                              // 道诀
                              const _FieldLabel(label: '道\u3000诀', sub: '（不可外泄）'),
                              const SizedBox(height: 6),
                              AncientInput(
                                hintText: '设定护身道诀，六字以上',
                                obscureText: true,
                                controller: _passwordController,
                              ),
                              const SizedBox(height: 28),

                              const InkDivider(thin: true),
                              const SizedBox(height: 16),

                              // 立册按钮
                              AncientButton(text: '立册入道', onTap: () => Navigator.of(context).pushNamed('/servers')),
                              const SizedBox(height: 14),

                              // 返回登录
                              GestureDetector(
                                onTap: () => Navigator.of(context).pop(),
                                child: const Text('已有道籍？返回登入',
                                  style: TextStyle(color: TianniColors.goldDark, fontSize: 11, letterSpacing: 2),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // 底部竖排警示
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _VerticalText('道不可轻传'),
                          SizedBox(width: 20),
                          _VerticalText('诀不可外露'),
                          SizedBox(width: 20),
                          _VerticalText('名不可虚立'),
                        ],
                      ),

                      const SizedBox(height: 60),
                    ],
                  ),
                ),
              ),

              // ── 底部分隔 ──
              Positioned(
                bottom: 15, left: 0, right: 0,
                child: Text('◆ 天逆仙途 · 万古长存 ◆',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.liuJianMaoCao(color: TianniColors.goldDark2, fontSize: 10, letterSpacing: 2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VerticalChar extends StatelessWidget {
  final String char;
  const _VerticalChar(this.char);
  @override
  Widget build(BuildContext context) {
    return Text(char, style: const TextStyle(color: TianniColors.goldDark, fontSize: 10, height: 1));
  }
}

class _VerticalText extends StatelessWidget {
  final String text;
  const _VerticalText(this.text);
  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.4,
      child: Column(
        children: text.split('').map((c) => Text(c,
          style: const TextStyle(color: TianniColors.goldDark, fontSize: 9, height: 1.4),
        )).toList(),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;
  final String sub;
  const _FieldLabel({required this.label, required this.sub});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text('◆', style: TextStyle(color: TianniColors.gold, fontSize: 10)),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(color: TianniColors.goldDim, fontSize: 11, letterSpacing: 3)),
        const SizedBox(width: 8),
        Text(sub, style: const TextStyle(color: TianniColors.goldDark2, fontSize: 10)),
      ],
    );
  }
}

// ── 侧边卷轴装饰 ──
class _ScrollDecor extends StatelessWidget {
  final String side;
  const _ScrollDecor({required this.side});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20, height: 200,
      child: CustomPaint(
        painter: _ScrollDecorPainter(side: side),
      ),
    );
  }
}

class _ScrollDecorPainter extends CustomPainter {
  final String side;
  _ScrollDecorPainter({required this.side});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFC8A96E).withValues(alpha: 0.25)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;
    final paintDot = Paint()
      ..color = const Color(0xFFC8A96E).withValues(alpha: 0.25)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;
    final paintLine = Paint()
      ..color = const Color(0xFFC8A96E).withValues(alpha: 0.25)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    final sign = side == 'left' ? 1.0 : -1.0;
    canvas.drawLine(const Offset(10, 0), Offset(10, 200), paint);

    for (final y in [20.0, 50.0, 80.0, 110.0, 140.0, 170.0]) {
      canvas.drawCircle(Offset(10, y), 2, paintDot);
      canvas.drawLine(Offset(10 - sign * 4, y), Offset(10 + sign * 4, y), paintLine);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
