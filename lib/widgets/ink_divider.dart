import 'package:flutter/material.dart';
import '../theme/colors.dart';

/// 古风分隔线，可选中间文字
class InkDivider extends StatelessWidget {
  final String? text;
  final bool thin;

  const InkDivider({
    super.key,
    this.text,
    this.thin = false,
  });

  @override
  Widget build(BuildContext context) {
    if (text != null && text!.isNotEmpty) {
      return Row(
        children: [
          Expanded(child: _Line(thin: thin)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              text!,
              style: const TextStyle(
                color: TianniColors.goldDim,
                fontSize: 11,
                letterSpacing: 3,
              ),
            ),
          ),
          Expanded(child: _Line(thin: thin)),
        ],
      );
    }
    return _Line(thin: thin);
  }
}

class _Line extends StatelessWidget {
  final bool thin;
  const _Line({required this.thin});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 0.5,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: thin
              ? [Colors.transparent, TianniColors.goldDark2, TianniColors.goldDark, TianniColors.goldDark2, Colors.transparent]
              : [Colors.transparent, TianniColors.goldDark, TianniColors.gold, TianniColors.goldDark, Colors.transparent],
          stops: thin
              ? const [0.0, 0.3, 0.5, 0.7, 1.0]
              : const [0.0, 0.2, 0.5, 0.8, 1.0],
        ),
      ),
    );
  }
}
