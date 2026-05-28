import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../widgets/ancient_border.dart';
import '../widgets/ink_divider.dart';
import '../widgets/ancient_input.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/ancient_button.dart';

/// 登录 / 注册 合并页面
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isRegisterMode = false;

  final TextEditingController _accountController = TextEditingController(text: '');
  final TextEditingController _passwordController = TextEditingController(text: '');

  final List<List<double>> _starPositions = const [
    [40, 80], [320, 120], [80, 200], [300, 280], [60, 380], [350, 450],
    [120, 500], [280, 560], [180, 650], [340, 700], [50, 730], [310, 750],
    [160, 160], [220, 350], [100, 600], [260, 420],
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
      resizeToAvoidBottomInset: false,
      body: Center(
        child: SizedBox(
          width: 375,
          height: 812,
          child: Stack(
            children: [
              ..._starPositions.map((pos) => Positioned(
                left: pos[0], top: pos[1],
                child: _StarDot(delay: pos[0].toInt() + pos[1].toInt()),
              )),

              const Positioned(top: 0, left: 0, child: _CloudPattern()),

              Column(
                children: [
                  const SizedBox(height: 60),

                  const _TaijiOrnament(),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(width: 30, height: 1,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(colors: [Colors.transparent, TianniColors.goldDark]),
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text('修仙问道',
                        style: TextStyle(color: TianniColors.goldDim, fontSize: 11, letterSpacing: 3),
                      ),
                      const SizedBox(width: 6),
                      Container(width: 30, height: 1,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(colors: [TianniColors.goldDark, Colors.transparent]),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text('天逆',
                    style: GoogleFonts.maShanZheng(
                      color: TianniColors.gold,
                      fontSize: 52,
                      letterSpacing: 16,
                      fontWeight: FontWeight.normal,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text('TIAN NI · IMMORTAL WORLD',
                    style: TextStyle(color: TianniColors.goldDark, fontSize: 10, letterSpacing: 5),
                  ),

                  const SizedBox(height: 40),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 42),
                    child: AncientBorder(
                      gold: true,
                      padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
                      child: Column(
                        children: [
                          const Text('踏入仙途',
                            style: TextStyle(color: TianniColors.gold, fontSize: 14, letterSpacing: 4),
                          ),
                          const SizedBox(height: 8),
                          const InkDivider(thin: true),
                          const SizedBox(height: 20),

                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text('道\u3000号',
                              style: TextStyle(color: TianniColors.goldDim, fontSize: 11, letterSpacing: 3),
                            ),
                          ),
                          const SizedBox(height: 6),
                          AncientInput(
                            hintText: '请输入您的道号',
                            controller: _accountController,
                          ),
                          const SizedBox(height: 22),

                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text('道\u3000诀',
                              style: TextStyle(color: TianniColors.goldDim, fontSize: 11, letterSpacing: 3),
                            ),
                          ),
                          const SizedBox(height: 6),
                          AncientInput(
                            hintText: '请输入您的道诀',
                            obscureText: true,
                            controller: _passwordController,
                          ),
                          const SizedBox(height: 28),

                          AncientButton(
                            text: _isRegisterMode ? '立册入道' : '踏入修仙路',
                            onTap: () => Navigator.of(context).pushNamed('/characters'),
                          ),
                          const SizedBox(height: 16),

                          GestureDetector(
                            onTap: () {
                              FocusScope.of(context).unfocus();
                              setState(() => _isRegisterMode = !_isRegisterMode);
                            },
                            child: Text(
                              _isRegisterMode ? '已有道籍？返回登入' : '尚无道籍？前往立册',
                              style: const TextStyle(color: TianniColors.goldDark, fontSize: 11, letterSpacing: 2),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Spacer(),

                  Padding(
                    padding: const EdgeInsets.only(bottom: 18),
                    child: Text('◆ 天逆仙途 · 万古长存 ◆',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.liuJianMaoCao(color: TianniColors.goldDark2, fontSize: 10, letterSpacing: 2),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StarDot extends StatelessWidget {
  final int delay;
  const _StarDot({required this.delay});

  @override
  Widget build(BuildContext context) {
    final bool isBig = delay % 3 == 0;
    return Container(
      width: isBig ? 2.0 : 1.0,
      height: isBig ? 2.0 : 1.0,
      decoration: BoxDecoration(
        color: TianniColors.gold.withValues(alpha: 0.4),
        shape: BoxShape.circle,
      ),
    );
  }
}

class _CloudPattern extends StatelessWidget {
  const _CloudPattern();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 375, height: 60,
      child: CustomPaint(painter: _CloudPatternPainter()),
    );
  }
}

class _CloudPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint1 = Paint()
      ..color = const Color(0xFF3A2C14)..strokeWidth = 1..style = PaintingStyle.stroke;
    final paint2 = Paint()
      ..color = const Color(0xFF1A1208)..strokeWidth = 0.5..style = PaintingStyle.stroke;
    final paintDot = Paint()
      ..color = const Color(0xFF5A4420)..strokeWidth = 0.5..style = PaintingStyle.stroke;

    final path1 = Path()
      ..moveTo(0, 40)..quadraticBezierTo(30, 20, 60, 35)..quadraticBezierTo(90, 50, 120, 30)
      ..quadraticBezierTo(150, 10, 180, 30)..quadraticBezierTo(210, 50, 240, 35)
      ..quadraticBezierTo(270, 20, 300, 35)..quadraticBezierTo(330, 50, 360, 30)
      ..quadraticBezierTo(368, 27, 375, 28);
    canvas.drawPath(path1, paint1);

    final path2 = Path()
      ..moveTo(0, 45)..quadraticBezierTo(40, 25, 80, 40)..quadraticBezierTo(120, 55, 160, 35)
      ..quadraticBezierTo(200, 15, 240, 40)..quadraticBezierTo(280, 60, 320, 40)
      ..quadraticBezierTo(350, 25, 375, 35);
    canvas.drawPath(path2, paint2);

    for (final x in [30.0, 90.0, 150.0, 220.0, 290.0, 350.0]) {
      canvas.drawCircle(Offset(x, 20), 3, paintDot);
      canvas.drawCircle(Offset(x + 5, 18), 4, paintDot);
      canvas.drawCircle(Offset(x + 10, 20), 3, paintDot);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TaijiOrnament extends StatelessWidget {
  const _TaijiOrnament();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 60, height: 60,
      child: CustomPaint(painter: _TaijiPainter()),
    );
  }
}

class _TaijiPainter extends CustomPainter {
  const _TaijiPainter();
  @override
  void paint(Canvas canvas, Size size) {
    const cx = 30.0, cy = 30.0;
    final paintOuter = Paint()
      ..color = const Color(0xFF3A2C14)..strokeWidth = 1..style = PaintingStyle.stroke;
    final paintInner = Paint()
      ..color = const Color(0xFF5A4420)..strokeWidth = 0.5..style = PaintingStyle.stroke;
    final paintCenter = Paint()
      ..color = const Color(0xFFC8A96E)..style = PaintingStyle.fill;
    final paintLine = Paint()
      ..color = const Color(0xFF3A2C14)..strokeWidth = 0.5..style = PaintingStyle.stroke;
    final paintDot = Paint()
      ..color = const Color(0xFF5A4420)..style = PaintingStyle.fill;

    canvas.drawCircle(const Offset(cx, cy), 28, paintOuter);
    canvas.drawCircle(const Offset(cx, cy), 24, paintInner);
    canvas.drawCircle(const Offset(cx, cy), 1.5, paintCenter);

    for (final angle in [0, 45, 90, 135]) {
      final rad = angle * pi / 180;
      canvas.drawLine(
        Offset(cx + 24 * cos(rad), cy + 24 * sin(rad)),
        Offset(cx - 24 * cos(rad), cy - 24 * sin(rad)),
        paintLine,
      );
    }

    for (final angle in [0, 45, 90, 135, 180, 225, 270, 315]) {
      final rad = angle * pi / 180;
      canvas.drawCircle(Offset(cx + 26 * cos(rad), cy + 26 * sin(rad)), 1.2, paintDot);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
