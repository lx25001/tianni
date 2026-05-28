import 'package:flutter/material.dart';
import '../theme/colors.dart';

/// 古风按钮（含按压水波纹）
class AncientButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final double fontSize;
  final double letterSpacing;
  final EdgeInsetsGeometry padding;
  final bool isPrimary;

  const AncientButton({
    super.key,
    required this.text,
    this.onTap,
    this.fontSize = 15,
    this.letterSpacing = 6,
    this.padding = const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
    this.isPrimary = true,
  });

  @override
  Widget build(BuildContext context) {
    final Color borderColor = isPrimary ? TianniColors.gold : TianniColors.goldDark2;
    final Color textColor = isPrimary ? TianniColors.gold : TianniColors.goldDim;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(0),
        splashColor: TianniColors.gold.withValues(alpha: 0.15),
        highlightColor: TianniColors.gold.withValues(alpha: 0.08),
        child: Container(
          width: double.infinity,
          padding: padding,
          decoration: BoxDecoration(
            border: Border.all(color: borderColor, width: 1),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textColor,
              fontSize: fontSize,
              letterSpacing: letterSpacing,
            ),
          ),
        ),
      ),
    );
  }
}
