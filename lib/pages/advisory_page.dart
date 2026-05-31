import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/colors.dart';

/// 健康游戏忠告 — 启动页
class AdvisoryPage extends StatefulWidget {
  const AdvisoryPage({super.key});

  @override
  State<AdvisoryPage> createState() => _AdvisoryPageState();
}

class _AdvisoryPageState extends State<AdvisoryPage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/characters');
      }
    });
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),

              // 标题
              Text('健康游戏忠告',
                style: GoogleFonts.maShanZheng(
                  color: TianniColors.gold,
                  fontSize: 24,
                  letterSpacing: 8,
                ),
              ),
              const SizedBox(height: 32),

              // 分隔线
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 60),
                child: Container(
                  height: 1,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.transparent, TianniColors.goldDark, Colors.transparent],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // 忠告内容
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  children: const [
                    _AdvisoryLine(text: '抵制不良游戏，拒绝盗版游戏。'),
                    SizedBox(height: 12),
                    _AdvisoryLine(text: '注意自我保护，谨防受骗上当。'),
                    SizedBox(height: 12),
                    _AdvisoryLine(text: '适度游戏益脑，沉迷游戏伤身。'),
                    SizedBox(height: 12),
                    _AdvisoryLine(text: '合理安排时间，享受健康生活。'),
                  ],
                ),
              ),

              const Spacer(flex: 2),

              // 底部信息
              Padding(
                padding: const EdgeInsets.only(bottom: 40),
                child: Column(
                  children: [
                    Text('天逆',
                      style: GoogleFonts.maShanZheng(
                        color: TianniColors.goldDim,
                        fontSize: 16,
                        letterSpacing: 6,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('适龄提示：16+',
                      style: TextStyle(
                        color: TianniColors.goldDark,
                        fontSize: 11,
                        letterSpacing: 3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdvisoryLine extends StatelessWidget {
  final String text;
  const _AdvisoryLine({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: TianniColors.goldDim,
        fontSize: 13,
        letterSpacing: 2,
        height: 1.6,
      ),
    );
  }
}
