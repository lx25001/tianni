import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../widgets/ancient_border.dart';
import '../widgets/ink_divider.dart';
import '../widgets/ancient_input.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/ancient_button.dart';

/// 创建角色页面 (React CreateCharacterPage.tsx)
class CreateCharacterPage extends StatefulWidget {
  const CreateCharacterPage({super.key});

  @override
  State<CreateCharacterPage> createState() => _CreateCharacterPageState();
}

class _CreateCharacterPageState extends State<CreateCharacterPage> {
  final TextEditingController _nameController = TextEditingController(text: '');
  int _selectedPreset = 1;

  // 静态假数据
  static const _serverName = '太虚仙域';
  static const _presets = [
    {'id': 1, 'name': '剑修', 'desc': '以剑入道，锋芒毕露', 'trait': '攻击+20%'},
    {'id': 2, 'name': '丹修', 'desc': '炼丹问道，百草皆药', 'trait': '炼丹+30%'},
    {'id': 3, 'name': '阵修', 'desc': '布阵为术，困敌制胜', 'trait': '防御+25%'},
    {'id': 4, 'name': '体修', 'desc': '炼体为本，金刚不坏', 'trait': '生命+40%'},
  ];

  final List<List<double>> _starPositions = const [
    [40, 60], [320, 100], [80, 250], [310, 350], [60, 500], [340, 600], [160, 700],
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TianniColors.bg,
      body: Center(
        child: SizedBox(
          width: 375,
          height: 812,
          child: Stack(
            children: [
              // ── 星点 ──
              ..._starPositions.map((pos) => Positioned(
                left: pos[0], top: pos[1],
                child: Container(
                  width: 1, height: 1,
                  decoration: BoxDecoration(
                    color: TianniColors.gold.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                ),
              )),

              // ── 返回 ──
              Positioned(
                top: 18, left: 18,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: const Row(
                    children: [
                      Icon(Icons.chevron_left, size: 14, color: TianniColors.goldDim),
                      SizedBox(width: 4),
                      Text('界域', style: TextStyle(color: TianniColors.goldDim, fontSize: 12, letterSpacing: 2)),
                    ],
                  ),
                ),
              ),

              // ── 主内容 ──
              Positioned.fill(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      const SizedBox(height: 50),

                      // 标题
                      Text(_serverName,
                        style: const TextStyle(color: TianniColors.goldDark, fontSize: 10, letterSpacing: 3),
                      ),
                      const SizedBox(height: 4),
                      const Text('铸造道身',
                        style: TextStyle(color: TianniColors.gold, fontSize: 26, letterSpacing: 8),
                      ),
                      const SizedBox(height: 4),
                      const Text('选择根骨，确立修行之路',
                        style: TextStyle(color: TianniColors.goldDark, fontSize: 10, letterSpacing: 3),
                      ),
                      const SizedBox(height: 14),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 57),
                        child: InkDivider(text: '根骨初现'),
                      ),

                      const SizedBox(height: 14),

                      // ── 根骨选择 ──
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 27),
                        child: Wrap(
                          spacing: 8, runSpacing: 8,
                          alignment: WrapAlignment.center,
                          children: _presets.map((preset) {
                            final isSelected = _selectedPreset == preset['id'];
                            return GestureDetector(
                              onTap: () => setState(() => _selectedPreset = preset['id'] as int),
                              child: SizedBox(
                                width: 142,
                                child: AncientBorder(
                                  gold: isSelected,
                                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Transform.rotate(
                                            angle: 0.785,
                                            child: Container(
                                              width: 6, height: 6,
                                              decoration: BoxDecoration(
                                                color: isSelected ? TianniColors.gold : Colors.transparent,
                                                border: Border.all(
                                                  color: isSelected ? TianniColors.gold : TianniColors.goldDark2,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(preset['name'] as String,
                                            style: TextStyle(
                                              color: isSelected ? TianniColors.goldBright : TianniColors.goldDim,
                                              fontSize: 14, letterSpacing: 2,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(preset['desc'] as String,
                                        style: const TextStyle(color: TianniColors.goldDark, fontSize: 10, height: 1.5),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(preset['trait'] as String,
                                        style: TextStyle(
                                          color: isSelected ? TianniColors.gold : TianniColors.goldDark2,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),

                      const SizedBox(height: 18),

                      // ── 角色名 ──
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 37),
                        child: AncientBorder(
                          gold: true,
                          padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('道身名讳',
                                style: TextStyle(color: TianniColors.goldDim, fontSize: 11, letterSpacing: 3),
                              ),
                              const SizedBox(height: 8),
                              AncientInput(
                                hintText: '赐予您的修仙名讳',
                                controller: _nameController,
                              ),
                              const SizedBox(height: 6),
                              const Text('名讳将伴您走遍三千仙界，慎重选择',
                                style: TextStyle(color: TianniColors.goldDark2, fontSize: 10, letterSpacing: 1),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ── 创建按钮 ──
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 37),
                        child: AncientButton(
                          text: '铸身入道',
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          onTap: () => Navigator.of(context).pushNamed('/game'),
                        ),
                      ),

                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),

              // ── 底部文字 ──
              Positioned(
                bottom: 20, left: 0, right: 0,
                child: Text('◆ 道身既铸，万劫不磨 ◆',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.liuJianMaoCao(color: TianniColors.goldDark2, fontSize: 10, letterSpacing: 2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
