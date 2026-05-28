import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../widgets/ancient_border.dart';
import '../widgets/ink_divider.dart';
import '../widgets/ancient_button.dart';
import '../widgets/tianni_dialog.dart';

/// 游戏主界面 (React GamePage.tsx)
class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  String _activeMenu = 'home';

  // ── 静态假数据 ──
  static const String _charName = '云清玄';
  static const String _realmName = '元婴期';
  static const String _serverName = '太虚仙域';
  static const int _expPercent = 65;
  static const int _hpPercent = 82;
  static const int _mpPercent = 58;

  static const List<String> _realms = ['炼气期', '筑基期', '金丹期', '元婴期', '化神期', '渡劫期', '大乘期', '飞升期'];

  static const List<Map<String, String>> _menuItems = [
    {'id': 'cultivate', 'label': '修炼', 'icon': '修'},
    {'id': 'battle', 'label': '征战', 'icon': '剑'},
    {'id': 'home', 'label': '主界', 'icon': '◈'},
    {'id': 'sect', 'label': '宗门', 'icon': '門'},
    {'id': 'bag', 'label': '储物', 'icon': '囊'},
  ];

  Color get realmColor {
    return TianniColors.realmColors[_realmName] ?? TianniColors.gold;
  }

  int get realmIdx {
    final idx = _realms.indexOf(_realmName);
    return idx >= 0 ? idx : 3;
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
              // ── 顶部装饰线 ──
              Container(
                height: 2,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.transparent, TianniColors.goldDark, TianniColors.gold, TianniColors.goldDark, Colors.transparent],
                    stops: [0.0, 0.2, 0.5, 0.8, 1.0],
                  ),
                ),
              ),

              // ── 顶部标题栏 ──
              Container(
                height: 32,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: TianniColors.inkLight, width: 1)),
                  color: TianniColors.bg,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('天逆',
                      style: TextStyle(color: TianniColors.gold, fontSize: 14, letterSpacing: 4),
                    ),
                    Row(
                      children: [
                        Container(width: 4, height: 4,
                          decoration: const BoxDecoration(color: TianniColors.onlineGreen, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 4),
                        const Text('在线', style: TextStyle(color: TianniColors.goldDark, fontSize: 9)),
                        const SizedBox(width: 12),
                        const Text('灵石 12,480', style: TextStyle(color: TianniColors.goldDark2, fontSize: 9)),
                      ],
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false),
                      child: const Text('离开',
                        style: TextStyle(color: TianniColors.goldDark2, fontSize: 9, letterSpacing: 1),
                      ),
                    ),
                  ],
                ),
              ),

              // ── 角色信息区 ──
              _CharacterHeader(
                charName: _charName, realmName: _realmName,
                serverName: _serverName, realmColor: realmColor,
                realmIdx: realmIdx, expPercent: _expPercent,
                hpPercent: _hpPercent, mpPercent: _mpPercent,
              ),

              // ── 修炼状态条 ──
              const _CultivateBar(),

              // ── 主内容区 ──
              Expanded(
                child: IndexedStack(
                  index: _menuItems.indexWhere((m) => m['id'] == _activeMenu),
                  children: const [
                    _MapArea(),           // home
                    _CultivatePanel(),    // cultivate
                    _BattlePanel(),       // battle
                    _SectPanel(),         // sect
                    _BagPanel(),          // bag
                  ],
                ),
              ),

              // ── 底部菜单 ──
              _BottomMenu(
                active: _activeMenu,
                items: _menuItems,
                onSelect: (id) => setState(() => _activeMenu = id),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// 角色信息头部
// ============================================================
class _CharacterHeader extends StatelessWidget {
  final String charName, realmName, serverName;
  final Color realmColor;
  final int realmIdx, expPercent, hpPercent, mpPercent;

  const _CharacterHeader({
    required this.charName, required this.realmName, required this.serverName,
    required this.realmColor, required this.realmIdx,
    required this.expPercent, required this.hpPercent, required this.mpPercent,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 4),
      child: AncientBorder(
        gold: true,
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 头像框 ──
            _AvatarFrame(realmColor: realmColor, realmName: realmName),
            const SizedBox(width: 10),

            // ── 角色信息 ──
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 名字+大区
                  Row(
                    children: [
                      Text(charName, style: const TextStyle(color: TianniColors.goldBright, fontSize: 16, letterSpacing: 3)),
                      const SizedBox(width: 8),
                      const Text('|', style: TextStyle(color: TianniColors.goldDark2, fontSize: 9)),
                      const SizedBox(width: 8),
                      Text(serverName, style: const TextStyle(color: TianniColors.goldDark, fontSize: 9, letterSpacing: 1)),
                    ],
                  ),
                  const SizedBox(height: 2),

                  // 修为进度
                  _StatBar(label: '修为', percent: expPercent, color: TianniColors.gold, labelColor: TianniColors.goldDim, valueColor: TianniColors.goldDark),
                  const SizedBox(height: 5),

                  // 气血+灵力
                  Row(
                    children: [
                      Expanded(child: _StatBar(label: '气血', percent: hpPercent, color: TianniColors.hpRed, labelColor: TianniColors.hpRed, valueColor: const Color(0xFF5A4020), height: 2, fontSize: 8)),
                      const SizedBox(width: 8),
                      Expanded(child: _StatBar(label: '灵力', percent: mpPercent, color: TianniColors.mpBlue, labelColor: const Color(0xFF2A4A8B), valueColor: const Color(0xFF3A4A60), height: 2, fontSize: 8)),
                    ],
                  ),
                ],
              ),
            ),

            // ── 右侧属性 ──
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _AttrItem(label: '境界', value: '第${realmIdx + 1}层', color: realmColor),
                const SizedBox(height: 4),
                const _AttrItem(label: '战力', value: '48,820', color: TianniColors.gold),
                const SizedBox(height: 4),
                const _AttrItem(label: '宗门', value: '天剑宗', color: TianniColors.goldDim),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AttrItem extends StatelessWidget {
  final String label, value;
  final Color color;
  const _AttrItem({required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(text: '$label ', style: const TextStyle(color: TianniColors.goldDark2, fontSize: 8)),
          TextSpan(text: value, style: TextStyle(color: color, fontSize: 9, letterSpacing: 1)),
        ],
      ),
    );
  }
}

class _StatBar extends StatelessWidget {
  final String label;
  final int percent;
  final Color color;
  final Color labelColor;
  final Color valueColor;
  final double height;
  final double fontSize;

  const _StatBar({
    required this.label, required this.percent,
    required this.color, required this.labelColor, required this.valueColor,
    this.height = 3, this.fontSize = 9,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(color: labelColor, fontSize: fontSize, letterSpacing: 1)),
            Text('$percent%', style: TextStyle(color: valueColor, fontSize: fontSize)),
          ],
        ),
        const SizedBox(height: 2),
        Container(
          height: height,
          decoration: BoxDecoration(color: height > 2 ? TianniColors.inkLight : const Color(0xFF1A0808)),
          child: Align(
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: percent / 100,
              child: Container(color: color),
            ),
          ),
        ),
      ],
    );
  }
}

// ── 头像框 ──
class _AvatarFrame extends StatelessWidget {
  final Color realmColor;
  final String realmName;
  const _AvatarFrame({required this.realmColor, required this.realmName});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 54 + 16,
      child: Column(
        children: [
          Container(
            width: 54, height: 54,
            decoration: BoxDecoration(
              border: Border.all(color: realmColor),
              color: const Color.fromRGBO(10, 7, 2, 0.8),
            ),
            child: const CustomPaint(
              painter: _AvatarSymbolPainter(),
              child: Center(),
            ),
          ),
          const SizedBox(height: 1),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
            decoration: BoxDecoration(
              border: Border.all(color: realmColor),
              color: TianniColors.bg,
            ),
            child: Text(realmName,
              style: TextStyle(color: realmColor, fontSize: 8, letterSpacing: 1),
            ),
          ),
        ],
      ),
    );
  }
}

class _AvatarSymbolPainter extends CustomPainter {
  const _AvatarSymbolPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2, cy = size.height / 2;
    final paint = Paint()
      ..color = TianniColors.gold
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(Offset(cx, cy), 14, paint);
    canvas.drawCircle(Offset(cx, cy), 8, paint..strokeWidth = 0.4);
    canvas.drawCircle(Offset(cx, cy), 2, paint..style = PaintingStyle.fill);

    for (int i = 0; i < 6; i++) {
      final angle = i * 60 * pi / 180;
      canvas.drawLine(
        Offset(cx + 8 * cos(angle), cy + 8 * sin(angle)),
        Offset(cx + 14 * cos(angle), cy + 14 * sin(angle)),
        paint..style = PaintingStyle.stroke..strokeWidth = 0.6,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ============================================================
// 修炼状态栏
// ============================================================
class _CultivateBar extends StatelessWidget {
  const _CultivateBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          border: Border.all(color: TianniColors.inkLight),
        ),
        child: Row(
          children: [
            Container(width: 4, height: 4,
              decoration: const BoxDecoration(color: TianniColors.gold, shape: BoxShape.circle),
            ),
            const SizedBox(width: 5),
            const Text('正在修炼', style: TextStyle(color: TianniColors.goldDim, fontSize: 9, letterSpacing: 1)),
            const SizedBox(width: 8),
            Container(width: 1, height: 10, color: TianniColors.inkMid),
            const SizedBox(width: 8),
            const Text('功法：天逆剑诀', style: TextStyle(color: TianniColors.goldDark, fontSize: 9)),
            const Spacer(),
            const Text('剩余：02:34:18', style: TextStyle(color: TianniColors.goldDark2, fontSize: 9)),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// 地图区域
// ============================================================
class _MapArea extends StatelessWidget {
  const _MapArea();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
      child: Column(
        children: [
          // 地图标题
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Transform.rotate(
                    angle: 0.785,
                    child: Container(
                      width: 6, height: 6,
                      decoration: BoxDecoration(border: Border.all(color: TianniColors.gold)),
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text('天元仙域',
                    style: TextStyle(color: TianniColors.gold, fontSize: 11, letterSpacing: 2),
                  ),
                ],
              ),
              const Text('◈ 坐标 天元城 ◈',
                style: TextStyle(color: TianniColors.goldDark2, fontSize: 9),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const InkDivider(thin: true),
          const SizedBox(height: 4),

          // 地图容器
          Expanded(
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: TianniColors.inkLight),
                    color: const Color.fromRGBO(5, 3, 1, 0.95),
                  ),
                  child: const CustomPaint(
                    painter: _InkWorldMapPainter(),
                    child: Center(),
                  ),
                ),
                // 地图操作提示
                const Positioned(
                  top: 8, right: 8,
                  child: Column(
                    children: [
                      _MapChip('妖兽区'),
                      SizedBox(height: 4),
                      _MapChip('采集区'),
                      SizedBox(height: 4),
                      _MapChip('秘境'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MapChip extends StatelessWidget {
  final String label;
  const _MapChip(this.label);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(color: TianniColors.goldDark2),
        color: const Color.fromRGBO(0, 0, 0, 0.8),
      ),
      child: Text(label, style: const TextStyle(color: TianniColors.goldDark, fontSize: 8, letterSpacing: 1)),
    );
  }
}

// ── 水墨世界地图 Painter ──
class _InkWorldMapPainter extends CustomPainter {
  const _InkWorldMapPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;

    // 底部水墨背景
    final bgPaint = Paint()..color = const Color.fromRGBO(200, 169, 110, 0.02);
    canvas.drawOval(Rect.fromLTWH(w * 0.05, h * 0.55, w * 0.9, h * 0.45), bgPaint);

    // 主大陆轮廓
    final continentPaint = Paint()
      ..color = const Color.fromRGBO(30, 20, 8, 0.6)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.fill;
    final continentStroke = Paint()
      ..color = const Color(0xFF3A2C14)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final continentPath = Path()
      ..moveTo(w * 0.16, h * 0.69)
      ..quadraticBezierTo(w * 0.21, h * 0.54, w * 0.27, h * 0.46)
      ..quadraticBezierTo(w * 0.35, h * 0.37, w * 0.43, h * 0.38)
      ..quadraticBezierTo(w * 0.51, h * 0.40, w * 0.56, h * 0.35)
      ..quadraticBezierTo(w * 0.64, h * 0.27, w * 0.72, h * 0.33)
      ..quadraticBezierTo(w * 0.79, h * 0.37, w * 0.83, h * 0.50)
      ..quadraticBezierTo(w * 0.85, h * 0.62, w * 0.81, h * 0.71)
      ..quadraticBezierTo(w * 0.76, h * 0.81, w * 0.69, h * 0.83)
      ..quadraticBezierTo(w * 0.61, h * 0.85, w * 0.53, h * 0.81)
      ..quadraticBezierTo(w * 0.45, h * 0.77, w * 0.37, h * 0.81)
      ..quadraticBezierTo(w * 0.29, h * 0.84, w * 0.23, h * 0.79)
      ..close();
    canvas.drawPath(continentPath, continentPaint);
    canvas.drawPath(continentPath, continentStroke);

    // 内陆纹理
    final texturePaint = Paint()
      ..color = const Color(0xFF2A1C08)
      ..style = PaintingStyle.stroke;
    canvas.drawPath(Path()..moveTo(w * 0.32, h * 0.62)..quadraticBezierTo(w * 0.37, h * 0.56, w * 0.44, h * 0.60)..quadraticBezierTo(w * 0.51, h * 0.63, w * 0.53, h * 0.58)..quadraticBezierTo(w * 0.57, h * 0.52, w * 0.64, h * 0.57), texturePaint..strokeWidth = 0.8);
    canvas.drawPath(Path()..moveTo(w * 0.35, h * 0.71)..quadraticBezierTo(w * 0.41, h * 0.67, w * 0.47, h * 0.70)..quadraticBezierTo(w * 0.53, h * 0.73, w * 0.59, h * 0.68), texturePaint..strokeWidth = 0.6);

    // 山脉
    final mountainPaint = Paint()
      ..color = const Color.fromRGBO(90, 68, 32, 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawPath(Path()..moveTo(w * 0.41, h * 0.44)..lineTo(w * 0.44, h * 0.38)..lineTo(w * 0.47, h * 0.44), mountainPaint);
    canvas.drawPath(Path()..moveTo(w * 0.45, h * 0.43)..lineTo(w * 0.47, h * 0.37)..lineTo(w * 0.51, h * 0.43), mountainPaint);
    canvas.drawPath(Path()..moveTo(w * 0.49, h * 0.42)..lineTo(w * 0.52, h * 0.36)..lineTo(w * 0.55, h * 0.42), mountainPaint);

    // 湖泊
    canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.61, h * 0.65), width: w * 0.12, height: h * 0.09),
      Paint()..color = const Color.fromRGBO(40, 60, 80, 0.5)..style = PaintingStyle.fill);
    canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.61, h * 0.65), width: w * 0.12, height: h * 0.09),
      Paint()..color = const Color(0xFF2A3A4A)..strokeWidth = 0.8..style = PaintingStyle.stroke);

    // 主城 - 天元城
    final cx = w * 0.49, cy = h * 0.57;
    canvas.drawRect(Rect.fromLTWH(cx - 7, cy - 10, 26, 20),
      Paint()..color = const Color.fromRGBO(20, 14, 4, 0.8)..style = PaintingStyle.fill);
    canvas.drawRect(Rect.fromLTWH(cx - 7, cy - 10, 26, 20),
      Paint()..color = TianniColors.gold..strokeWidth = 1..style = PaintingStyle.stroke);
    canvas.drawPath(Path()..moveTo(cx - 10, cy - 10)..lineTo(cx + 6, cy - 22)..lineTo(cx + 22, cy - 10),
      Paint()..color = const Color.fromRGBO(10, 7, 2, 0.8)..style = PaintingStyle.fill);
    canvas.drawPath(Path()..moveTo(cx - 10, cy - 10)..lineTo(cx + 6, cy - 22)..lineTo(cx + 22, cy - 10),
      Paint()..color = TianniColors.gold..strokeWidth = 1..style = PaintingStyle.stroke);

    // 秘境圆环
    canvas.drawCircle(Offset(w * 0.35, h * 0.60), w * 0.032,
      Paint()..color = const Color(0xFF5A4420)..strokeWidth = 0.8..style = PaintingStyle.stroke);

    // 魔域
    canvas.drawPath(Path()
      ..moveTo(w * 0.69, h * 0.54)..lineTo(w * 0.73, h * 0.50)..lineTo(w * 0.76, h * 0.56)..lineTo(w * 0.77, h * 0.60)
      ..lineTo(w * 0.74, h * 0.62)..lineTo(w * 0.71, h * 0.65)..lineTo(w * 0.69, h * 0.61)..close(),
      Paint()..color = const Color.fromRGBO(30, 5, 5, 0.5)..style = PaintingStyle.fill);
    canvas.drawPath(Path()
      ..moveTo(w * 0.69, h * 0.54)..lineTo(w * 0.73, h * 0.50)..lineTo(w * 0.76, h * 0.56)..lineTo(w * 0.77, h * 0.60)
      ..lineTo(w * 0.74, h * 0.62)..lineTo(w * 0.71, h * 0.65)..lineTo(w * 0.69, h * 0.61)..close(),
      Paint()..color = const Color(0xFF8B1A1A)..strokeWidth = 0.8..style = PaintingStyle.stroke);

    // 当前位置标记
    canvas.drawCircle(Offset(cx + 6, cy + 14), 5,
      Paint()..color = TianniColors.goldBright..strokeWidth = 1..style = PaintingStyle.stroke);
    canvas.drawCircle(Offset(cx + 6, cy + 14), 2,
      Paint()..color = TianniColors.goldBright..style = PaintingStyle.fill);

    // 边框
    canvas.drawRect(Rect.fromLTWH(4, 4, w - 8, h - 8),
      Paint()..color = const Color(0xFF3A2C14)..strokeWidth = 0.8..style = PaintingStyle.stroke);
    canvas.drawRect(Rect.fromLTWH(8, 8, w - 16, h - 16),
      Paint()..color = const Color(0xFF1A1208)..strokeWidth = 0.4..style = PaintingStyle.stroke);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ============================================================
// 底部菜单
// ============================================================
class _BottomMenu extends StatelessWidget {
  final String active;
  final List<Map<String, String>> items;
  final void Function(String id) onSelect;

  const _BottomMenu({required this.active, required this.items, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 62,
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: TianniColors.goldDark2, width: 1)),
        color: TianniColors.bg,
      ),
      child: Row(
        children: items.asMap().entries.map((entry) {
          final idx = entry.key;
          final item = entry.value;
          final isActive = active == item['id'];
          return Expanded(
            child: GestureDetector(
              onTap: () => onSelect(item['id']!),
              child: Container(
                decoration: BoxDecoration(
                  border: idx < items.length - 1
                      ? const Border(right: BorderSide(color: TianniColors.inkLight, width: 1))
                      : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: isActive ? 30 : 0,
                      height: 2,
                      color: TianniColors.gold,
                    ),
                    const Spacer(),
                    Container(
                      width: 26, height: 26,
                      decoration: BoxDecoration(
                        border: Border.all(color: isActive ? TianniColors.gold : TianniColors.inkMid),
                        color: isActive ? const Color.fromRGBO(200, 169, 110, 0.08) : Colors.transparent,
                      ),
                      alignment: Alignment.center,
                      child: Text(item['icon']!,
                        style: TextStyle(
                          color: isActive ? TianniColors.goldBright : TianniColors.goldDark,
                          fontSize: 13,
                          height: 1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(item['label']!,
                      style: TextStyle(
                        color: isActive ? TianniColors.gold : TianniColors.goldDark,
                        fontSize: 10,
                        letterSpacing: 1,
                      ),
                    ),
                    const Spacer(),
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
class _CultivatePanel extends StatelessWidget {
  const _CultivatePanel();

  @override
  Widget build(BuildContext context) {
    final items = [
      {'name': '天逆剑诀', 'level': 'Lv.8', 'type': '剑修', 'effect': '攻击 +580', 'status': '修炼中'},
      {'name': '混沌玄功', 'level': 'Lv.5', 'type': '通用', 'effect': '修为 +30%', 'status': '未修炼'},
      {'name': '龙象伏虎功', 'level': 'Lv.3', 'type': '体修', 'effect': '气血 +2000', 'status': '未修炼'},
    ];

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        const Text('修\u3000炼', textAlign: TextAlign.center,
          style: TextStyle(color: TianniColors.gold, fontSize: 14, letterSpacing: 4),
        ),
        const SizedBox(height: 8),
        const InkDivider(thin: true),
        const SizedBox(height: 8),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: AncientBorder(
            gold: item['status'] == '修炼中',
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(item['name']!, style: const TextStyle(color: TianniColors.goldBright, fontSize: 13, letterSpacing: 2)),
                          const SizedBox(width: 6),
                          Text(item['level']!, style: const TextStyle(color: TianniColors.goldDark, fontSize: 9)),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 3),
                            decoration: BoxDecoration(border: Border.all(color: TianniColors.inkMid)),
                            child: Text(item['type']!, style: const TextStyle(color: TianniColors.goldDark2, fontSize: 9)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(item['effect']!, style: const TextStyle(color: TianniColors.goldDim, fontSize: 10)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    border: Border.all(color: item['status'] == '修炼中' ? TianniColors.gold : TianniColors.goldDark2),
                  ),
                  child: Text(item['status']!,
                    style: TextStyle(
                      color: item['status'] == '修炼中' ? TianniColors.gold : TianniColors.goldDark,
                      fontSize: 10, letterSpacing: 1,
                    ),
                  ),
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
// 征战面板
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
// 宗门面板
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
class _BagPanel extends StatelessWidget {
  const _BagPanel();

  @override
  Widget build(BuildContext context) {
    final items = [
      {'name': '天灵草', 'type': '灵草', 'count': 24, 'color': const Color(0xFF4A6741)},
      {'name': '玄铁矿', 'type': '矿石', 'count': 8, 'color': const Color(0xFF5A5A6A)},
      {'name': '筑基丹', 'type': '丹药', 'count': 3, 'color': TianniColors.gold},
      {'name': '破邪符', 'type': '符箓', 'count': 12, 'color': const Color(0xFF8B6030)},
      {'name': '寒铁剑', 'type': '法宝', 'count': 1, 'color': TianniColors.goldBright},
      {'name': '玉液', 'type': '灵液', 'count': 5, 'color': const Color(0xFF4A7A8A)},
    ];

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        const Text('储\u3000物', textAlign: TextAlign.center,
          style: TextStyle(color: TianniColors.gold, fontSize: 14, letterSpacing: 4),
        ),
        const SizedBox(height: 8),
        const InkDivider(thin: true),
        const SizedBox(height: 4),
        const Text('储物袋 · 剩余 18/30 格',
          style: TextStyle(color: TianniColors.goldDark, fontSize: 9, letterSpacing: 2),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6, runSpacing: 6,
          children: [
            ...items.map((item) => _BagItem(
              icon: (item['name'] as String)[0],
              name: item['name'] as String,
              count: item['count'] as int,
              color: item['color'] as Color,
            )),
            // 空格子
            for (int i = 0; i < 3; i++)
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(border: Border.all(color: TianniColors.inkLight)),
                alignment: Alignment.center,
                child: const Text('＋', style: TextStyle(color: TianniColors.inkLight, fontSize: 18)),
              ),
          ],
        ),
      ],
    );
  }
}

class _BagItem extends StatelessWidget {
  final String icon, name;
  final int count;
  final Color color;
  const _BagItem({required this.icon, required this.name, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80, height: 80,
      decoration: BoxDecoration(
        border: Border.all(color: TianniColors.goldDark2),
        color: const Color.fromRGBO(10, 7, 2, 0.5),
      ),
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(icon, style: TextStyle(color: color, fontSize: 18)),
                const SizedBox(height: 4),
                Text(name, style: const TextStyle(color: TianniColors.goldDim, fontSize: 9, letterSpacing: 1)),
              ],
            ),
          ),
          Positioned(
            bottom: 4, right: 5,
            child: Text('x$count', style: const TextStyle(color: TianniColors.goldDark, fontSize: 8)),
          ),
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
