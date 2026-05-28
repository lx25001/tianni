import 'package:flutter/material.dart';

/// 天逆古风色彩体系
class TianniColors {
  TianniColors._();

  // ── 背景 ──
  static const Color bg = Color(0xFF000000);
  static const Color bgCard = Color(0xFF0A0804);
  static const Color bgDark = Color(0xFF050300);
  static const Color bgMap = Color.fromRGBO(5, 3, 1, 0.95);

  // ── 金色系 (primary) ──
  static const Color gold = Color(0xFFC8A96E); // 主金色
  static const Color goldBright = Color(0xFFE8C87A); // 亮金色
  static const Color goldDim = Color(0xFF7A6030); // 暗金色
  static const Color goldDark = Color(0xFF5A4420); // 深暗金色
  static const Color goldDark2 = Color(0xFF3A2C14); // 更深暗金色

  // ── 暗色 ──
  static const Color ink = Color(0xFF0A0804);
  static const Color inkLight = Color(0xFF1A1208);
  static const Color inkMid = Color(0xFF2A1C08);

  // ── 文字色 ──
  static const Color parchment = Color(0xFFE8D9B8); // 羊皮纸色
  static const Color muted = Color(0xFF7A6840);

  // ── 赤色 ──
  static const Color crimson = Color(0xFF8B1A1A);

  // ── 其他 ──
  static const Color hpRed = Color(0xFF8B1A1A);
  static const Color mpBlue = Color(0xFF2A4A8B);
  static const Color onlineGreen = Color(0xFF4A6741);
  static const Color lakeBlue = Color(0xFF3A5060);

  // ── 境界色 (realm colors) ──
  static const Map<String, Color> realmColors = {
    '炼气期': Color(0xFF7A6030),
    '筑基期': Color(0xFFA08040),
    '金丹期': Color(0xFFC8A96E),
    '元婴期': Color(0xFFE8C87A),
    '化神期': Color(0xFF9B6FD4),
    '渡劫期': Color(0xFF8B1A1A),
    '大乘期': Color(0xFFCC3333),
    '飞升期': Color(0xFFFFFFFF),
  };
}
