import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../models/game_models.dart';
import '../services/mock_data.dart';

/// 交互式地图组件
class GameMapWidget extends StatefulWidget {
  const GameMapWidget({super.key});

  @override
  State<GameMapWidget> createState() => _GameMapWidgetState();
}

class _GameMapWidgetState extends State<GameMapWidget> {
  final GlobalKey _mapPaintKey = GlobalKey();
  late PositionData _posData;
  String _moveLog = '';

  @override
  void initState() {
    super.initState();
    _posData = MockData.mockPosition(MockData.currentRoom);
  }

  void _move(String dir) {
    try {
      final newPos = MockData.mockMove(_posData.current.roomId, dir);
      final exit = _posData.exits.firstWhere((e) => e.dir == dir);
      setState(() {
        _posData = newPos;
        _moveLog = '向${exit.label}而行，抵达${newPos.current.roomName}';
      });
    } catch (_) {
      setState(() => _moveLog = '此路不通');
    }
  }

  void _onTapUp(TapUpDetails details) {
    final paintBox = _mapPaintKey.currentContext?.findRenderObject() as RenderBox?;
    if (paintBox == null) return;

    final localPos = paintBox.globalToLocal(details.globalPosition);
    final center = Offset(paintBox.size.width / 2, paintBox.size.height / 2);

    for (final exit in _posData.exits) {
      final nodeCenter = _nodeCenter(exit.dir, center);
      final rect = Rect.fromCenter(
        center: nodeCenter,
        width: ExitMapPainter.nodeW + 16,
        height: ExitMapPainter.nodeH + 16,
      );
      if (rect.contains(localPos)) {
        _move(exit.dir);
        return;
      }
    }
  }

  Offset _nodeCenter(String dir, Offset center) {
    const s = ExitMapPainter.step;
    return switch (dir) {
      'n' => Offset(center.dx, center.dy - s),
      's' => Offset(center.dx, center.dy + s),
      'e' => Offset(center.dx + s, center.dy),
      'w' => Offset(center.dx - s, center.dy),
      'ne' => Offset(center.dx + s, center.dy - s),
      'nw' => Offset(center.dx - s, center.dy - s),
      'se' => Offset(center.dx + s, center.dy + s),
      'sw' => Offset(center.dx - s, center.dy + s),
      _ => center,
    };
  }

  @override
  Widget build(BuildContext context) {
    final npcs = MockData.getNPCs(_posData.current.roomId);
    final resources = MockData.getResources(_posData.current.roomId);

    return Column(
      children: [
        // 位置信息
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 6, 12, 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Transform.rotate(angle: 0.785, child: Container(width: 6, height: 6, decoration: BoxDecoration(border: Border.all(color: TianniColors.gold)))),
                  const SizedBox(width: 6),
                  Text(_posData.current.region, style: const TextStyle(color: TianniColors.gold, fontSize: 11, letterSpacing: 2)),
                ],
              ),
              Text('◈ ${_posData.current.roomName} ◈', style: const TextStyle(color: TianniColors.goldBright, fontSize: 10)),
            ],
          ),
        ),
        // 移动日志
        if (_moveLog.isNotEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(12, 3, 12, 3),
            color: TianniColors.inkLight,
            child: Text(_moveLog, textAlign: TextAlign.center, style: const TextStyle(color: TianniColors.goldBright, fontSize: 10, letterSpacing: 1)),
          ),
        // 地图 + 交互区（70:30）
        Expanded(
          child: Column(
            children: [
              Expanded(
                flex: 7,
                child: Stack(
                  children: [
                    GestureDetector(
                      onTapUp: _onTapUp,
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        color: TianniColors.bg,
                        child: CustomPaint(
                          key: _mapPaintKey,
                          painter: ExitMapPainter(exits: _posData.exits, currentName: _posData.current.roomName, nodes: _posData.mapNodes),
                          child: const SizedBox.expand(),
                        ),
                      ),
                    ),
                    const Positioned(top: 6, left: 0, right: 0, child: _DirLabel('北')),
                    const Positioned(bottom: 6, left: 0, right: 0, child: _DirLabel('南')),
                    const Positioned(left: 6, top: 0, bottom: 0, child: Center(child: _DirLabel('西'))),
                    const Positioned(right: 6, top: 0, bottom: 0, child: Center(child: _DirLabel('东'))),
                  ],
                ),
              ),
              Container(height: 0.5, color: TianniColors.inkMid),
              // 此地人物
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 2),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionTitle(title: '此地人物', icon: '◈'),
                      const SizedBox(height: 4),
                      if (npcs.isEmpty)
                        const Padding(
                          padding: EdgeInsets.only(top: 4),
                          child: Text('此处杳无人迹', style: TextStyle(color: TianniColors.goldDark2, fontSize: 10)),
                        )
                      else
                        Expanded(
                          child: ListView(
                            padding: EdgeInsets.zero,
                            children: npcs.map((n) => GestureDetector(
                              onTap: () {},
                              behavior: HitTestBehavior.opaque,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                margin: const EdgeInsets.only(bottom: 2),
                                decoration: BoxDecoration(
                                  border: Border.all(color: TianniColors.inkLight),
                                ),
                                child: Row(children: [
                                  Container(width: 5, height: 5, decoration: const BoxDecoration(color: TianniColors.goldDim, shape: BoxShape.circle)),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(n['name']!, style: const TextStyle(color: TianniColors.goldBright, fontSize: 12, letterSpacing: 1)),
                                        const SizedBox(height: 1),
                                        Text(n['desc']!, style: const TextStyle(color: TianniColors.goldDim, fontSize: 9)),
                                      ],
                                    ),
                                  ),
                                ]),
                              ),
                            )).toList(),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Container(height: 0.5, color: TianniColors.inkMid),
              ),
              // 此地资源
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionTitle(title: '此地资源', icon: '◆'),
                      const SizedBox(height: 4),
                      if (resources.isEmpty)
                        const Text('此处了无资源', style: TextStyle(color: TianniColors.goldDark2, fontSize: 10))
                      else
                        Expanded(
                          child: SingleChildScrollView(
                            child: Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              children: resources.map((r) {
                                final color = _hexColor(r['color'] ?? '#B8860B');
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(border: Border.all(color: color.withValues(alpha: 0.5)), color: color.withValues(alpha: 0.1)),
                                  child: Text(r['name']!, style: TextStyle(color: color, fontSize: 10, letterSpacing: 1)),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _hexColor(String hex) {
    hex = hex.replaceFirst('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    return Color(int.parse(hex, radix: 16));
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String icon;
  const _SectionTitle({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Text(icon, style: const TextStyle(color: TianniColors.gold, fontSize: 10)),
      const SizedBox(width: 6),
      Text(title, style: const TextStyle(color: TianniColors.goldBright, fontSize: 11, letterSpacing: 2)),
      const Spacer(),
      Container(height: 0.5, width: 120, color: TianniColors.goldDark2),
    ]);
  }
}

class _DirLabel extends StatelessWidget {
  final String text;
  const _DirLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text, textAlign: TextAlign.center, style: const TextStyle(color: TianniColors.gold, fontSize: 10, letterSpacing: 3));
  }
}

/// 8方向地图 Painter
class ExitMapPainter extends CustomPainter {
  final List<Exit> exits;
  final String currentName;
  final List<MapNode> nodes;

  static const double nodeW = 90.0;
  static const double nodeH = 44.0;
  static const double step = 110.0;

  const ExitMapPainter({required this.exits, required this.currentName, required this.nodes});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    for (final exit in exits) {
      final neighborCenter = _nc(exit.dir, center);
      final fromEdge = _rectEdge(center, neighborCenter);
      final toEdge = _rectEdge(neighborCenter, center);
      final paint = Paint()
        ..color = exit.crossRegion ? const Color(0xFFFF8C00) : const Color(0xFFB8860B)
        ..strokeWidth = exit.crossRegion ? 1.5 : 1.0
        ..style = PaintingStyle.stroke;
      canvas.drawLine(fromEdge, toEdge, paint);
      if (exit.crossRegion) _drawDashed(canvas, fromEdge, toEdge, paint);
    }

    for (final exit in exits) {
      final nodeCenter = _nc(exit.dir, center);
      final isCross = exit.crossRegion;
      final borderColor = isCross ? const Color(0xFFFF8C00) : const Color(0xFFB8860B);
      final textColor = isCross ? const Color(0xFFFFD700) : TianniColors.goldBright;
      _drawNode(canvas, nodeCenter, exit.toName, borderColor, textColor);
    }

    _drawNode(canvas, center, currentName, TianniColors.gold, const Color(0xFFFF3333));
  }

  void _drawNode(Canvas canvas, Offset center, String name, Color borderColor, Color textColor) {
    final rect = Rect.fromCenter(center: center, width: nodeW, height: nodeH);
    canvas.drawRect(rect, Paint()..color = const Color.fromRGBO(10, 8, 4, 0.9)..style = PaintingStyle.fill);
    canvas.drawRect(rect, Paint()..color = borderColor..strokeWidth = 1.5..style = PaintingStyle.stroke);
    final textSpan = TextSpan(text: name, style: TextStyle(color: textColor, fontSize: 12, letterSpacing: 2, fontWeight: FontWeight.bold));
    final tp = TextPainter(text: textSpan, textDirection: TextDirection.ltr);
    tp.layout(maxWidth: nodeW - 8);
    tp.paint(canvas, Offset(center.dx - tp.width / 2, center.dy - tp.height / 2));
  }

  Offset _nc(String dir, Offset center) {
    return switch (dir) {
      'n' => Offset(center.dx, center.dy - step),
      's' => Offset(center.dx, center.dy + step),
      'e' => Offset(center.dx + step, center.dy),
      'w' => Offset(center.dx - step, center.dy),
      'ne' => Offset(center.dx + step, center.dy - step),
      'nw' => Offset(center.dx - step, center.dy - step),
      'se' => Offset(center.dx + step, center.dy + step),
      'sw' => Offset(center.dx - step, center.dy + step),
      _ => center,
    };
  }

  Offset _rectEdge(Offset rectCenter, Offset toward) {
    final dx = toward.dx - rectCenter.dx;
    final dy = toward.dy - rectCenter.dy;
    final hw = nodeW / 2;
    final hh = nodeH / 2;
    double tx = dx != 0 ? hw / dx.abs() : double.infinity;
    double ty = dy != 0 ? hh / dy.abs() : double.infinity;
    final t = tx < ty ? tx : ty;
    return Offset(rectCenter.dx + dx * t, rectCenter.dy + dy * t);
  }

  void _drawDashed(Canvas canvas, Offset from, Offset to, Paint paint) {
    final dx = to.dx - from.dx;
    final dy = to.dy - from.dy;
    const steps = 12;
    for (int i = 0; i < steps; i += 2) {
      final t1 = i / steps;
      final t2 = ((i + 1) / steps).clamp(0.0, 1.0);
      canvas.drawLine(Offset(from.dx + dx * t1, from.dy + dy * t1), Offset(from.dx + dx * t2, from.dy + dy * t2), paint);
    }
  }

  @override
  bool shouldRepaint(covariant ExitMapPainter oldDelegate) =>
      oldDelegate.exits != exits || oldDelegate.currentName != currentName;
}
