import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../widgets/ink_divider.dart';
import '../widgets/ancient_input.dart';
import '../widgets/ancient_button.dart';
import '../widgets/tianni_feedback.dart';
import '../models/character_data.dart';
import '../models/inventory.dart';
import '../services/character_storage.dart';
import '../services/inventory_dao.dart';

class CreateCharacterPage extends StatefulWidget {
  const CreateCharacterPage({super.key});

  @override
  State<CreateCharacterPage> createState() => _CreateCharacterPageState();
}

class _CreateCharacterPageState extends State<CreateCharacterPage> {
  final TextEditingController _surnameCtrl = TextEditingController(text: '');
  final TextEditingController _nameCtrl = TextEditingController(text: '');
  final Random _rng = Random();

  late int _con, _spi, _qi, _dao, _ins, _bon;
  late String _rootElement;
  late String _rootPurity;
  int _rerolls = 10;

  static const _fiveElements = ['金', '木', '水', '火', '土'];
  static const _variantElements = ['风', '雷', '冰', '毒', '光', '暗', '磁', '虚空'];
  static const _purityLevels = [
    {'label': '下品', 'weight': 55, 'rate': 1.0},
    {'label': '中品', 'weight': 25, 'rate': 1.3},
    {'label': '上品', 'weight': 12, 'rate': 1.6},
    {'label': '极品', 'weight': 6, 'rate': 2.0},
    {'label': '天品', 'weight': 2, 'rate': 3.0},
  ];
  static const _counter = {'金': '木', '木': '土', '土': '水', '水': '火', '火': '金'};
  static const _generated = {'金': '水', '水': '木', '木': '火', '火': '土', '土': '金'};

  @override
  void initState() {
    super.initState();
    _rollAttributes();
  }

  void _rollAttributes() {
    _con = _rng.nextInt(14) + 5;
    _spi = _rng.nextInt(14) + 5;
    _qi = _rng.nextInt(14) + 5;
    _ins = _rng.nextInt(14) + 5;
    _bon = _rng.nextInt(14) + 5;
    _dao = _rng.nextInt(41) + 30;
    if (_rng.nextInt(100) < 5) {
      _rootElement = _variantElements[_rng.nextInt(_variantElements.length)];
    } else {
      _rootElement = _fiveElements[_rng.nextInt(_fiveElements.length)];
    }
    final purityRoll = _rng.nextInt(100);
    int cumulative = 0;
    _rootPurity = '下品';
    for (final p in _purityLevels) {
      cumulative += p['weight'] as int;
      if (purityRoll < cumulative) { _rootPurity = p['label'] as String; break; }
    }
  }

  void _reroll() {
    if (_rerolls > 0) {
      setState(() { _rollAttributes(); _rerolls--; });
    } else {
      TianniToast.show(context, '天机已尽，请珍惜此次天命');
    }
  }

  void _onCreate() {
    final surname = _surnameCtrl.text.trim();
    final givenName = _nameCtrl.text.trim();

    if (surname.isEmpty || givenName.isEmpty) {
      TianniToast.show(context, '姓名不可为空');
      return;
    }

    // XSS 过滤
    final xssPattern = RegExp(r"""[<>{}()\[\]"'`;]|script|javascript|onerror|onload|href|src""", caseSensitive: false);
    if (xssPattern.hasMatch(surname) || xssPattern.hasMatch(givenName)) {
      TianniToast.show(context, '名讳包含非法字符');
      return;
    }

    // 仅允许中文、英文、数字、空格、英文标点
    final allowed = RegExp(r'^[\u4e00-\u9fff\u3400-\u4dbfa-zA-Z0-9 .,!?\-:·]+$');
    if (!allowed.hasMatch(surname) || !allowed.hasMatch(givenName)) {
      TianniToast.show(context, '名讳仅支持中文、英文、数字');
      return;
    }

    // 字数计算：中文=1，英文/数字=0.5，合计上限6
    double countChar(String s) {
      double n = 0;
      for (final c in s.runes) {
        final ch = String.fromCharCode(c);
        if (RegExp(r'[\u4e00-\u9fff\u3400-\u4dbf]').hasMatch(ch)) {
          n += 1;
        } else if (ch.trim().isNotEmpty) {
          n += 0.5;
        }
      }
      return n;
    }

    final total = countChar(surname) + countChar(givenName);
    if (total > 6) {
      TianniToast.show(context, '名讳过长，至多六字');
      return;
    }

    _saveAndContinue();
  }

  Future<void> _saveAndContinue() async {
    final data = CharacterData(
      surname: _surnameCtrl.text.trim(),
      givenName: _nameCtrl.text.trim(),
      rootElement: _rootElement,
      rootPurity: _rootPurity,
      purityRate: double.parse(_purityRate.replaceAll('×', '')),
      con: _con, spi: _spi, qi: _qi,
      dao: _dao, ins: _ins, bon: _bon,
    );

    // 找第一个空槽位
    for (int i = 0; i < CharacterStorage.maxSlots; i++) {
      final existing = await CharacterStorage.load(i);
      if (existing == null) {
        await CharacterStorage.save(i, data);
        // 赠送初始物品
        final inv = Inventory();
        inv.addItem('pill_qi_01', 3);     // 聚气丹×3
        inv.addItem('equip_sword_01', 1);  // 铁剑×1
        inv.addItem('equip_robe_01', 1);   // 粗布道袍×1
        await InventoryDao.saveAll(i, inv);
        if (mounted) {
          TianniToast.show(context, '道身已成');
          Navigator.of(context).pushNamedAndRemoveUntil('/characters', (route) => false);
        }
        return;
      }
    }
    // 所有槽位满
    if (mounted) {
      TianniToast.show(context, '道身槽位已满，请先舍弃一具');
    }
  }

  int get _hp => _con * 10;
  int get _maxQi => _qi * 8;
  int get _atk => (_con * 1.5).round();
  int get _def => (_con * 0.8).round();
  int get _speed => 10 + (_con * 0.2).round() + (_spi * 0.1).round();

  String get _purityRate {
    for (final p in _purityLevels) { if (p['label'] == _rootPurity) return '${p['rate']}×'; }
    return '1.0×';
  }

  Color _elemColor(String e) => switch (e) {
    '金' => const Color(0xFFD4AF37), '木' => const Color(0xFF5B9A3F),
    '水' => const Color(0xFF4A90D9), '火' => const Color(0xFFCC3333),
    '土' => const Color(0xFFB8860B), '风' => const Color(0xFF7EC8A0),
    '雷' => const Color(0xFF9B6FD4), '冰' => const Color(0xFF7EC8E3),
    '毒' => const Color(0xFF8FBC3F), '光' => const Color(0xFFFFD700),
    '暗' => const Color(0xFF6A0DAD), '磁' => const Color(0xFF5A5A5A),
    '虚空' => const Color(0xFF8B8B8B), _ => TianniColors.gold,
  };

  Color get _purityColor => switch (_rootPurity) {
    '天品' => const Color(0xFFFF4444), '极品' => const Color(0xFFD4AF37),
    '上品' => const Color(0xFF4A90D9), '中品' => const Color(0xFF5B9A3F),
    _ => TianniColors.goldDark,
  };

  bool get _isVariant => _variantElements.contains(_rootElement);

  @override
  void dispose() {
    _surnameCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TianniColors.bg,
      resizeToAvoidBottomInset: false,
      body: Center(
        child: SizedBox(
          width: 375, height: 812,
          child: Stack(
            children: [
                ...List.generate(16, (i) => Positioned(
                  left: _rng.nextDouble() * 375,
                  top: _rng.nextDouble() * 812,
                  child: Container(
                    width: 1, height: 1,
                    decoration: BoxDecoration(
                      color: TianniColors.gold.withValues(alpha: 0.25),
                      shape: BoxShape.circle,
                    ),
                  ),
                )),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    children: [
                      const SizedBox(height: 34),
                      const Text('入\u3000道',
                        style: TextStyle(color: TianniColors.gold, fontSize: 28, letterSpacing: 12),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('天机莫测 · 先天注定',
                            style: TextStyle(color: TianniColors.goldDark, fontSize: 10, letterSpacing: 2),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(
                              border: Border.all(color: _rerolls > 3 ? TianniColors.goldDim : const Color(0xFFCC3333), width: 0.7),
                            ),
                            child: Text('剩余 $_rerolls 次',
                              style: TextStyle(color: _rerolls > 3 ? TianniColors.goldDim : const Color(0xFFCC3333), fontSize: 9, letterSpacing: 1),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 50),
                        child: InkDivider(thin: true),
                      ),
                      const SizedBox(height: 14),

                      // 姓名
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('姓', style: TextStyle(color: TianniColors.goldDim, fontSize: 11, letterSpacing: 2)),
                                const SizedBox(height: 3),
                                AncientInput(hintText: '姓', controller: _surnameCtrl),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            flex: 5,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('名', style: TextStyle(color: TianniColors.goldDim, fontSize: 11, letterSpacing: 2)),
                                const SizedBox(height: 3),
                                AncientInput(hintText: '赐予修仙名讳', controller: _nameCtrl),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // 灵根
                      Row(
                        children: [
                          Container(
                            width: 36, height: 36,
                            decoration: BoxDecoration(
                              border: Border.all(color: _elemColor(_rootElement), width: 1.5),
                              color: _elemColor(_rootElement).withValues(alpha: 0.08),
                            ),
                            child: Center(
                              child: Text(_rootElement, style: TextStyle(color: _elemColor(_rootElement), fontSize: 16, fontWeight: FontWeight.bold)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${_rootElement}灵根', style: TextStyle(color: _elemColor(_rootElement), fontSize: 15, letterSpacing: 3)),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                    decoration: BoxDecoration(border: Border.all(color: _purityColor, width: 0.7)),
                                    child: Text('$_rootPurity · $_purityRate', style: TextStyle(color: _purityColor, fontSize: 10, letterSpacing: 1)),
                                  ),
                                  if (!_isVariant) ...[
                                    const SizedBox(width: 4),
                                    Text('克${_counter[_rootElement]} · 生${_generated[_rootElement]}',
                                      style: const TextStyle(color: TianniColors.goldDark2, fontSize: 9)),
                                  ],
                                ],
                              ),
                            ],
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: _reroll,
                            child: Column(
                              children: [
                                Transform.rotate(
                                  angle: 0.785,
                                  child: Container(
                                    width: 10, height: 10,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: _rerolls > 0 ? TianniColors.goldDark : TianniColors.inkMid),
                                      color: _rerolls > 0 ? TianniColors.gold.withValues(alpha: 0.15) : null,
                                    ),
                                    child: _rerolls > 0 ? Center(child: Container(width: 3, height: 3, color: TianniColors.goldDark)) : null,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text('重鉴', style: TextStyle(color: _rerolls > 0 ? TianniColors.goldDark : TianniColors.inkMid, fontSize: 9)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Padding(padding: EdgeInsets.symmetric(horizontal: 50), child: InkDivider(thin: true)),
                      const SizedBox(height: 10),

                      // 六维
                      const Align(alignment: Alignment.centerLeft, child: Text('先天根骨', style: TextStyle(color: TianniColors.gold, fontSize: 11, letterSpacing: 3))),
                      const SizedBox(height: 10),
                      _bar('体魄', _con, 5, 18, const Color(0xFFCC3333)),
                      _bar('神识', _spi, 5, 18, const Color(0xFF9B6FD4)),
                      _bar('气海', _qi, 5, 18, const Color(0xFF4A90D9)),
                      _bar('道心', _dao, 30, 70, TianniColors.goldBright),
                      _bar('悟性', _ins, 5, 18, const Color(0xFF5B9A3F)),
                      _bar('根骨', _bon, 5, 18, const Color(0xFFC8A96E)),
                      const SizedBox(height: 10),
                      const Padding(padding: EdgeInsets.symmetric(horizontal: 50), child: InkDivider(thin: true)),
                      const SizedBox(height: 8),

                      // 战斗属性
                      const Align(alignment: Alignment.centerLeft, child: Text('战斗属性', style: TextStyle(color: TianniColors.gold, fontSize: 11, letterSpacing: 3))),
                      const SizedBox(height: 6),
                      _combatRow('气血', '$_hp', const Color(0xFFCC3333)),
                      _combatRow('灵气', '$_maxQi', const Color(0xFF4A90D9)),
                      _combatRow('攻击', '$_atk', const Color(0xFFD4AF37)),
                      _combatRow('防御', '$_def', TianniColors.goldDim),
                      _combatRow('速度', '$_speed', const Color(0xFF5B9A3F)),

                      const Spacer(),
                      AncientButton(
                        text: '铸身入道',
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        onTap: _onCreate,
                      ),
                      const SizedBox(height: 20),
                      Text('◆ 道身既铸 · 万劫不磨 ◆',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: TianniColors.goldDark2, fontSize: 10, letterSpacing: 2),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ],
            ),
        ),
      ),
    );
  }

  Widget _bar(String label, int value, int min, int max, Color color) {
    final double factor = ((value - min) / (max - min)).clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        children: [
          SizedBox(width: 32, child: Text(label, style: TextStyle(color: color, fontSize: 13, letterSpacing: 1))),
          const SizedBox(width: 4),
          SizedBox(width: 18, child: Text('$value', textAlign: TextAlign.right, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold))),
          const SizedBox(width: 4),
          Expanded(
            child: Container(
              height: 6,
              decoration: BoxDecoration(color: TianniColors.inkLight, border: Border.all(color: TianniColors.inkMid, width: 0.4)),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: factor,
                child: Container(decoration: BoxDecoration(color: color.withValues(alpha: 0.6), border: Border(right: BorderSide(color: color, width: 1)))),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _combatRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          const SizedBox(width: 4),
          const Text('◆', style: TextStyle(color: TianniColors.goldDark2, fontSize: 6)),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(color: TianniColors.goldDim, fontSize: 11, letterSpacing: 2)),
          const Spacer(),
          Text(value, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
          const SizedBox(width: 4),
        ],
      ),
    );
  }
}
