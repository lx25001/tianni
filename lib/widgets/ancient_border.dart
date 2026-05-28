import 'package:flutter/material.dart';
import '../theme/colors.dart';

/// 古风四角位置
enum AncientCorner { topLeft, topRight, bottomLeft, bottomRight }

/// 古风双线边框组件，四角有回纹装饰
class AncientBorder extends StatelessWidget {
  final Widget child;
  final bool gold;
  final bool corners;
  final Set<AncientCorner>? cornerSet;
  final EdgeInsetsGeometry padding;

  const AncientBorder({
    super.key,
    required this.child,
    this.gold = false,
    this.corners = true,
    this.cornerSet,
    this.padding = EdgeInsets.zero,
  });

  /// 显示在哪些角落
  Set<AncientCorner> get _activeCorners {
    if (cornerSet != null) return cornerSet!;
    if (corners) {
      return AncientCorner.values.toSet();
    }
    return {};
  }

  @override
  Widget build(BuildContext context) {
    final Color borderColor = gold ? TianniColors.gold : TianniColors.goldDark2;
    final Color outerBorderColor = gold ? TianniColors.goldDark : TianniColors.inkLight;
    final Color cornerColor = gold ? TianniColors.gold : TianniColors.goldDark;
    final active = _activeCorners;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Stack(
        children: [
          // 外层装饰线
          Positioned.fill(
            child: Container(
              margin: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                border: Border.all(color: outerBorderColor, width: 1),
              ),
            ),
          ),
          // 四角回纹装饰
          if (active.contains(AncientCorner.topLeft))
            Positioned(top: -1, left: -1, child: _CornerMark(color: cornerColor, top: true, left: true)),
          if (active.contains(AncientCorner.topRight))
            Positioned(top: -1, right: -1, child: _CornerMark(color: cornerColor, top: true, right: true)),
          if (active.contains(AncientCorner.bottomLeft))
            Positioned(bottom: -1, left: -1, child: _CornerMark(color: cornerColor, bottom: true, left: true)),
          if (active.contains(AncientCorner.bottomRight))
            Positioned(bottom: -1, right: -1, child: _CornerMark(color: cornerColor, bottom: true, right: true)),
          // 内容
          Padding(
            padding: padding,
            child: child,
          ),
        ],
      ),
    );
  }
}

class _CornerMark extends StatelessWidget {
  final Color color;
  final bool top;
  final bool bottom;
  final bool left;
  final bool right;

  const _CornerMark({
    required this.color,
    this.top = false, this.bottom = false,
    this.left = false, this.right = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 14, height: 14,
      child: CustomPaint(
        painter: _CornerPainter(
          color: color,
          top: top, bottom: bottom,
          left: left, right: right,
        ),
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  final Color color;
  final bool top, bottom, left, right;

  _CornerPainter({
    required this.color,
    required this.top, required this.bottom,
    required this.left, required this.right,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    if (top && left) {
      path.moveTo(0, size.height); path.lineTo(0, 0); path.lineTo(size.width, 0);
    } else if (top && right) {
      path.moveTo(0, 0); path.lineTo(size.width, 0); path.lineTo(size.width, size.height);
    } else if (bottom && left) {
      path.moveTo(0, 0); path.lineTo(0, size.height); path.lineTo(size.width, size.height);
    } else if (bottom && right) {
      path.moveTo(size.width, 0); path.lineTo(size.width, size.height); path.lineTo(0, size.height);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _CornerPainter oldDelegate) => color != oldDelegate.color;
}
