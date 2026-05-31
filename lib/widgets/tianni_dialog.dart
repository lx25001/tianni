import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/colors.dart';
import 'ancient_border.dart';

/// 弹窗按钮定义
class DialogAction {
  final String text;
  final VoidCallback? onTap;
  final bool isPrimary;

  const DialogAction({
    required this.text,
    this.onTap,
    this.isPrimary = true,
  });
}

/// 古风弹窗组件 — 宽度与登录表单一致（291px），关闭按钮由 `showClose` 控制
class TianniDialog extends StatefulWidget {
  final Widget child;
  final String? title;
  final String? subtitle;
  final EdgeInsetsGeometry contentPadding;
  final VoidCallback? onClose;
  final List<DialogAction>? actions;
  final double maxContentHeight;

  const TianniDialog({
    super.key,
    required this.child,
    this.title,
    this.subtitle,
    this.contentPadding = const EdgeInsets.fromLTRB(24, 20, 24, 16),
    this.onClose,
    this.actions,
    this.maxContentHeight = 420,
  });

  /// 显示弹窗
  /// [barrierDismissible] 控制是否可点空白处关闭，默认 true
  static Future<void> show(
    BuildContext context, {
    required Widget child,
    String? title,
    String? subtitle,
    bool barrierDismissible = true,
    VoidCallback? onClose,
    List<DialogAction>? actions,
    double maxContentHeight = 420,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor: Colors.black87,
      builder: (_) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
          SizedBox(
            width: 291,
            child: TianniDialog(
              title: title,
              subtitle: subtitle,
              onClose: onClose,
              actions: actions,
              maxContentHeight: maxContentHeight,
              child: child,
            ),
          ),
          const SizedBox(height: 14),
          Material(
            color: Colors.transparent,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Transform.rotate(
                angle: 0.785,
                child: Container(
                  width: 28, height: 28,
                  decoration: BoxDecoration(
                    border: Border.all(color: TianniColors.goldDark2, width: 0.8),
                  ),
                  child: Center(
                    child: Transform.rotate(
                      angle: -0.785,
                      child: const Text('✕',
                        style: TextStyle(color: TianniColors.goldDim, fontSize: 12),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
        ),
      ),
    );
  }

  @override
  State<TianniDialog> createState() => _TianniDialogState();
}

class _TianniDialogState extends State<TianniDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _fadeAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slideAnim = Tween(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasTitle = (widget.title != null && widget.title!.isNotEmpty) ||
        (widget.subtitle != null && widget.subtitle!.isNotEmpty);

    return Material(
      color: Colors.transparent,
      child: FadeTransition(
        opacity: _fadeAnim,
        child: SlideTransition(
          position: _slideAnim,
          child: Stack(
            children: [
              ..._starDots(),
              Center(
                child: AncientBorder(
                  gold: true,
                  cornerSet: const {
                    AncientCorner.topRight,
                    AncientCorner.bottomLeft,
                    AncientCorner.bottomRight,
                  },
                  padding: EdgeInsets.zero,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // ── 顶部装饰带 ──
                        if (hasTitle) _buildTopBar(context),

                        // ── 内容区 ──
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            maxHeight: widget.maxContentHeight,
                          ),
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            child: Padding(
                              padding: widget.contentPadding,
                              child: widget.child,
                            ),
                          ),
                        ),

                        // ── 底部装饰分隔线 ──
                        const _DialogBottomDivider(),

                        // ── 按钮区 ──
                        _buildActions(context),

                        // ── 底部装饰带 ──
                        _buildBottomBar(),
                      ],
                    ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── 顶部装饰带 ──
  Widget _buildTopBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: TianniColors.goldDark.withValues(alpha: 0.4),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          // 左装饰：小菱形
          _diamond(8, TianniColors.gold),
          const SizedBox(width: 8),

          // 标题区域（居中）
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.title != null && widget.title!.isNotEmpty)
                  Text(widget.title!,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.maShanZheng(
                      color: TianniColors.goldBright,
                      fontSize: 14,
                      letterSpacing: 4,
                    ),
                  ),
                if (widget.subtitle != null && widget.subtitle!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(widget.subtitle!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: TianniColors.goldDim,
                        fontSize: 10,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(width: 8),
          // 右装饰：小菱形（平衡）
          _diamond(8, TianniColors.gold),
        ],
      ),
    );
  }

  // ── 按钮区 ──
  Widget _buildActions(BuildContext context) {
    final acts = widget.actions;
    if (acts == null || acts.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: acts.length == 1
          ? _singleAction(acts.first)
          : _dualActions(acts),
    );
  }

  Widget _singleAction(DialogAction action) {
    return SizedBox(
      width: double.infinity,
      height: 36,
      child: _actionButton(action),
    );
  }

  Widget _dualActions(List<DialogAction> actions) {
    return Row(
      children: actions.asMap().entries.map((entry) {
        final i = entry.key;
        final a = entry.value;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(left: i > 0 ? 10 : 0),
            child: SizedBox(
              height: 36,
              child: _actionButton(a),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _actionButton(DialogAction action) {
    final Color borderColor = action.isPrimary
        ? TianniColors.gold
        : TianniColors.goldDark2;
    final Color textColor = action.isPrimary
        ? TianniColors.gold
        : TianniColors.goldDim;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: action.onTap,
        borderRadius: BorderRadius.circular(0),
        splashColor: TianniColors.gold.withValues(alpha: 0.15),
        highlightColor: TianniColors.gold.withValues(alpha: 0.08),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: borderColor, width: 1),
          ),
          child: Center(
            child: Text(
              action.text,
              style: TextStyle(
                color: textColor,
                fontSize: 13,
                letterSpacing: 4,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── 底部装饰带 ──
  Widget _buildBottomBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _diamond(4, TianniColors.goldDark),
          const SizedBox(width: 6),
          const Text('◈',
            style: TextStyle(color: TianniColors.goldDark2, fontSize: 7, letterSpacing: 2),
          ),
          const SizedBox(width: 6),
          _diamond(4, TianniColors.goldDark),
        ],
      ),
    );
  }

  // ── 菱形 ──
  static Widget _diamond(double size, Color color) {
    return Transform.rotate(
      angle: 0.785,
      child: Container(
        width: size, height: size,
        decoration: BoxDecoration(
          border: Border.all(color: color, width: size > 5 ? 1.0 : 0.5),
        ),
        child: size > 5
            ? Center(
                child: Container(
                  width: size * 0.4,
                  height: size * 0.4,
                  decoration: BoxDecoration(color: color),
                ),
              )
            : null,
      ),
    );
  }

  // ── 漂浮星点 ──
  static List<Widget> _starDots() {
    const positions = [
      [50.0, 80.0], [240.0, 50.0], [30.0, 160.0], [260.0, 140.0],
      [70.0, 240.0], [220.0, 230.0], [130.0, 180.0],
    ];
    return positions.map((p) => Positioned(
      left: p[0], top: p[1],
      child: Container(
        width: 1.5, height: 1.5,
        decoration: BoxDecoration(
          color: TianniColors.gold.withValues(alpha: 0.3),
          shape: BoxShape.circle,
        ),
      ),
    )).toList();
  }
}



/// 底部渐变分隔线
class _DialogBottomDivider extends StatelessWidget {
  const _DialogBottomDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 0.5,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            TianniColors.goldDark,
            TianniColors.gold,
            TianniColors.goldDark,
            Colors.transparent,
          ],
          stops: [0.0, 0.2, 0.5, 0.8, 1.0],
        ),
      ),
    );
  }
}
