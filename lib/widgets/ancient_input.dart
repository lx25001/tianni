import 'package:flutter/material.dart';
import '../theme/colors.dart';

/// 古风输入框
class AncientInput extends StatelessWidget {
  final String? hintText;
  final bool obscureText;
  final TextEditingController? controller;

  const AncientInput({
    super.key,
    this.hintText,
    this.obscureText = false,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      cursorColor: TianniColors.gold,
      style: const TextStyle(
        color: TianniColors.parchment,
        fontSize: 15,
        letterSpacing: 2,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(
          color: TianniColors.goldDark,
          fontSize: 15,
          letterSpacing: 2,
        ),
        filled: false,
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: TianniColors.goldDark, width: 1),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: TianniColors.gold, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        isCollapsed: true,
      ),
    );
  }
}
