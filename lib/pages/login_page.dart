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

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  bool _isRegisterMode = false;

  final TextEditingController _accountController = TextEditingController(text: '');
  final TextEditingController _passwordController = TextEditingController(text: '');
  final TextEditingController _confirmController = TextEditingController(text: '');

  final List<List<double>> _starPositions = const [
    [40, 80], [320, 120], [80, 200], [300, 280], [60, 380], [350, 450],
    [120, 500], [280, 560], [180, 650], [340, 700], [50, 730], [310, 750],
    [160, 160], [220, 350], [100, 600], [260, 420],
  ];

  @override
  void dispose() {
    _accountController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Widget _buildForm() {
    if (_isRegisterMode) {
      return _buildRegisterForm();
    }
    return _buildLoginForm();
  }

  // ── 登录表单 ──
  Widget _buildLoginForm() {
    return Column(
      key: const ValueKey('login'),
      children: [
        const Text('踏入仙途',
          style: TextStyle(color: TianniColors.gold, fontSize: 14, letterSpacing: 4),
        ),
        const SizedBox(height: 8),
        const InkDivider(thin: true),
        const SizedBox(height: 20),

        // 道号
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

        // 道诀
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

        // 登录按钮
        AncientButton(
          text: '踏入修仙路',
          onTap: () => Navigator.of(context).pushNamed('/characters'),
        ),
        const SizedBox(height: 16),

        // 切换到注册
        GestureDetector(
          onTap: () => setState(() => _isRegisterMode = true),
          child: const Text('尚无道籍？前往立册',
            style: TextStyle(color: TianniColors.goldDark, fontSize: 11, letterSpacing: 2),
          ),
        ),
      ],
    );
  }

  // ── 注册表单 ──
  Widget _buildRegisterForm() {
    return Column(
      key: const ValueKey('register'),
      children: [
        // 顶部标注
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('◈ 天机密录 ◈',
              style: TextStyle(color: TianniColors.goldDark2, fontSize: 10, letterSpacing: 1),
            ),
            Text('◈ 不可外传 ◈',
              style: TextStyle(color: TianniColors.goldDark2, fontSize: 10, letterSpacing: 1),
            ),
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
        const SizedBox(height: 24),

        // 确认道诀
        const _FieldLabel(label: '确认道诀', sub: '（再输一遍）'),
        const SizedBox(height: 6),
        AncientInput(
          hintText: '再次输入道诀以确认',
          obscureText: true,
          controller: _confirmController,
        ),
        const SizedBox(height: 28),

        const InkDivider(thin: true),
        const SizedBox(height: 16),

        // 立册按钮
        AncientButton(
          text: '立册入道',
          onTap: () => Navigator.of(context).pushNamed('/characters'),
        ),
        const SizedBox(height: 14),

        // 切换回登录
        GestureDetector(
          onTap: () => setState(() => _isRegisterMode = false),
          child: const Text('已有道籍？返回登入',
            style: TextStyle(color: TianniColors.goldDark, fontSize: 11, letterSpacing: 2),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: TianniColors.bg,
      resizeToAvoidBottomInset: false,
      body: Center(
        child: SizedBox(
          width: 375,
          height: 812,
          child: Stack(
            children: [
              // ── 星空背景点 ──
              ..._starPositions.map((pos) => Positioned(
                left: pos[0], top: pos[1],
                child: _StarDot(delay: pos[0].toInt() + pos[1].toInt()),
              )),

              // ── 顶部云纹 ──
              const Positioned(top: 0, left: 0, child: _CloudPattern()),

              // ── 顶部标题（固定） ──
              Positioned(
                top: 60,
                left: 0,
                right: 0,
                child: Column(
                  children: [
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
                  ],
                ),
              ),

              // ── 表单区（键盘弹起时整体上移） ──
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOut,
                transform: Matrix4.translationValues(0, bottomInset > 0 ? -bottomInset * 0.45 : 0, 0),
                alignment: Alignment.center,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 42),
                    child: AncientBorder(
                      gold: true,
                      padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 420),
                        switchInCurve: Curves.easeOutBack,
                        switchOutCurve: Curves.easeIn,
                        transitionBuilder: (child, animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: ScaleTransition(
                              scale: Tween(begin: 0.94, end: 1.0).animate(
                                CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
                              ),
                              child: child,
                            ),
                          );
                        },
                        child: _buildForm(),
                      ),
                    ),
                  ),
                ),
              ),

              // ── 底部版权 ──
              Positioned(
                bottom: 18, left: 0, right: 0,
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

// ──────────── 星空点 ────────────
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

// ──────────── 字段标签（注册表单） ────────────
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

// ──────────── 顶部云纹 ────────────
class _CloudPattern extends StatelessWidget {
  const _CloudPattern();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 375, height: 60,
      child: CustomPaint(
        painter: _CloudPatternPainter(),
      ),
    );
  }
}

class _CloudPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint1 = Paint()
      ..color = const Color(0xFF3A2C14)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    final paint2 = Paint()
      ..color = const Color(0xFF1A1208)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;
    final paintDot = Paint()
      ..color = const Color(0xFF5A4420)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    final path1 = Path()
      ..moveTo(0, 40)
      ..quadraticBezierTo(30, 20, 60, 35)
      ..quadraticBezierTo(90, 50, 120, 30)
      ..quadraticBezierTo(150, 10, 180, 30)
      ..quadraticBezierTo(210, 50, 240, 35)
      ..quadraticBezierTo(270, 20, 300, 35)
      ..quadraticBezierTo(330, 50, 360, 30)
      ..quadraticBezierTo(368, 27, 375, 28);
    canvas.drawPath(path1, paint1);

    final path2 = Path()
      ..moveTo(0, 45)
      ..quadraticBezierTo(40, 25, 80, 40)
      ..quadraticBezierTo(120, 55, 160, 35)
      ..quadraticBezierTo(200, 15, 240, 40)
      ..quadraticBezierTo(280, 60, 320, 40)
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

// ──────────── 中心八卦纹 ────────────
class _TaijiOrnament extends StatelessWidget {
  const _TaijiOrnament();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 60, height: 60,
      child: CustomPaint(
        painter: _TaijiPainter(),
      ),
    );
  }
}

class _TaijiPainter extends CustomPainter {
  const _TaijiPainter();
  @override
  void paint(Canvas canvas, Size size) {
    const cx = 30.0, cy = 30.0;
    final paintOuter = Paint()
      ..color = const Color(0xFF3A2C14)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    final paintInner = Paint()
      ..color = const Color(0xFF5A4420)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;
    final paintCenter = Paint()
      ..color = const Color(0xFFC8A96E)
      ..style = PaintingStyle.fill;
    final paintLine = Paint()
      ..color = const Color(0xFF3A2C14)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;
    final paintDot = Paint()
      ..color = const Color(0xFF5A4420)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(const Offset(cx, cy), 28, paintOuter);
    canvas.drawCircle(const Offset(cx, cy), 24, paintInner);
    canvas.drawCircle(const Offset(cx, cy), 1.5, paintCenter);

    for (final angle in [0, 45, 90, 135]) {
      final rad = angle * pi / 180;
      final x1 = cx + 24 * cos(rad);
      final y1 = cy + 24 * sin(rad);
      final x2 = cx - 24 * cos(rad);
      final y2 = cy - 24 * sin(rad);
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paintLine);
    }

    for (final angle in [0, 45, 90, 135, 180, 225, 270, 315]) {
      final rad = angle * pi / 180;
      canvas.drawCircle(
        Offset(cx + 26 * cos(rad), cy + 26 * sin(rad)),
        1.2, paintDot,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
