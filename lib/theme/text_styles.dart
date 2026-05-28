import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

/// 天逆古风字体系统
class TianniFonts {
  TianniFonts._();

  // ── 主字体 ──
  static TextStyle get body => GoogleFonts.notoSerifSc(
    color: TianniColors.parchment,
    fontSize: 13,
    letterSpacing: 2,
    height: 1.6,
  );

  static TextStyle get bodySmall => GoogleFonts.notoSerifSc(
    color: TianniColors.goldDark,
    fontSize: 10,
    letterSpacing: 1,
  );

  static TextStyle get bodyDim => GoogleFonts.notoSerifSc(
    color: TianniColors.goldDim,
    fontSize: 11,
    letterSpacing: 3,
  );

  static TextStyle get button => GoogleFonts.notoSerifSc(
    color: TianniColors.gold,
    fontSize: 15,
    letterSpacing: 6,
  );

  static TextStyle get buttonSmall => GoogleFonts.notoSerifSc(
    color: TianniColors.gold,
    fontSize: 11,
    letterSpacing: 3,
  );

  // ── 标题字体 ──
  static TextStyle get titleLarge => GoogleFonts.maShanZheng(
    color: TianniColors.gold,
    fontSize: 52,
    letterSpacing: 16,
    height: 1,
  );

  static TextStyle get titleMedium => GoogleFonts.maShanZheng(
    color: TianniColors.gold,
    fontSize: 26,
    letterSpacing: 8,
  );

  static TextStyle get titleSmall => GoogleFonts.maShanZheng(
    color: TianniColors.gold,
    fontSize: 20,
    letterSpacing: 6,
  );

  static TextStyle get titleDialog => GoogleFonts.maShanZheng(
    color: TianniColors.goldBright,
    fontSize: 14,
    letterSpacing: 4,
  );

  // ── 装饰字体 ──
  static TextStyle get ornament => GoogleFonts.liuJianMaoCao(
    color: TianniColors.goldDark2,
    fontSize: 10,
    letterSpacing: 2,
  );

  static TextStyle get ornamentGold => GoogleFonts.liuJianMaoCao(
    color: TianniColors.goldDark2,
    fontSize: 10,
    letterSpacing: 3,
  );

  // ── 输入框 ──
  static TextStyle get input => GoogleFonts.notoSerifSc(
    color: TianniColors.parchment,
    fontSize: 15,
    letterSpacing: 2,
  );

  static TextStyle get inputHint => GoogleFonts.notoSerifSc(
    color: TianniColors.goldDark,
    fontSize: 15,
    letterSpacing: 2,
  );

  // ── 辅助函数：构建 ThemeData 的 TextTheme ──
  static TextTheme get textTheme => GoogleFonts.notoSerifScTextTheme().copyWith(
    displayLarge: titleLarge,
    displayMedium: titleMedium,
    displaySmall: titleSmall,
    bodyLarge: body,
    bodyMedium: body,
    bodySmall: bodySmall,
    labelLarge: button,
    labelSmall: buttonSmall,
  );
}
