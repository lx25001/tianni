import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/colors.dart';
import 'tianni_dialog.dart';

/// ──────────────────────────────────────────────
/// TianniToast — 轻提示（屏下方淡入上移）
/// ──────────────────────────────────────────────
class TianniToast {
  TianniToast._();

  static OverlayEntry? _entry;

  static void show(BuildContext context, String message) {
    _entry?.remove();
    _entry = null;

    final overlay = Overlay.of(context);
    late final OverlayEntry entry;
    final controller = AnimationController(
      vsync: overlay as TickerProvider,
      duration: const Duration(milliseconds: 400),
    );
    final fadeAnim = CurvedAnimation(parent: controller, curve: Curves.easeOut);
    final slideAnim = Tween(begin: const Offset(0, 0.15), end: Offset.zero)
        .animate(CurvedAnimation(parent: controller, curve: Curves.easeOut));

    entry = OverlayEntry(
      builder: (_) => Positioned(
        bottom: 120,
        left: 0,
        right: 0,
        child: IgnorePointer(
          child: FadeTransition(
            opacity: fadeAnim,
            child: SlideTransition(
              position: slideAnim,
              child: Material(
                type: MaterialType.transparency,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: TianniColors.gold.withValues(alpha: 0.05),
                      border: const Border(
                        top: BorderSide(color: TianniColors.goldDark, width: 0.5),
                        bottom: BorderSide(color: TianniColors.goldDark, width: 0.5),
                      ),
                    ),
                    child: Text(
                    '\u25c7 $message \u25c7',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: TianniColors.gold,
                      fontSize: 13,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
            ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(entry);
    _entry = entry;
    controller.forward();

    Future.delayed(const Duration(seconds: 2), () {
      controller.reverse().then((_) {
        if (_entry == entry) {
          entry.remove();
          _entry = null;
        }
        controller.dispose();
      });
    });
  }
}

/// ──────────────────────────────────────────────
/// TianniMessageBox — 确认弹窗（封装 TianniDialog）
/// ──────────────────────────────────────────────
class TianniMessageBox {
  TianniMessageBox._();

  static void show({
    required BuildContext context,
    required String title,
    required String message,
    required VoidCallback onConfirm,
    VoidCallback? onCancel,
  }) {
    TianniDialog.show(
      context,
      title: title,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: TianniColors.goldDim,
            fontSize: 14,
            letterSpacing: 2,
            height: 1.8,
          ),
        ),
      ),
      actions: [
        DialogAction(
          text: '取消',
          isPrimary: false,
          onTap: () {
            Navigator.of(context).pop();
            onCancel?.call();
          },
        ),
        DialogAction(
          text: '确认',
          onTap: () {
            Navigator.of(context).pop();
            onConfirm.call();
          },
        ),
      ],
    );
  }
}

/// ──────────────────────────────────────────────
/// TianniNotify — 传音横幅（屏顶滑入）
/// ──────────────────────────────────────────────
class TianniNotify {
  TianniNotify._();

  static OverlayEntry? _entry;

  static void show(BuildContext context, String message) {
    _entry?.remove();
    _entry = null;

    final overlay = Overlay.of(context);
    late final OverlayEntry entry;
    final controller = AnimationController(
      vsync: overlay as TickerProvider,
      duration: const Duration(milliseconds: 450),
    );
    final slideAnim = Tween(begin: const Offset(0, -1.0), end: Offset.zero)
        .animate(CurvedAnimation(parent: controller, curve: Curves.easeOutCubic));

    entry = OverlayEntry(
      builder: (_) => Positioned(
        top: 0,
        left: 0,
        right: 0,
        child: IgnorePointer(
          child: SlideTransition(
            position: slideAnim,
            child: Material(
              type: MaterialType.transparency,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 44, 24, 20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    TianniColors.bg,
                    Color(0xCC0A0804),
                    Color(0x660A0804),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: TianniColors.parchment,
                      fontSize: 14,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // 底部金色渐变消散线
                  Container(
                    height: 0.5,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          TianniColors.gold,
                          Colors.transparent,
                        ],
                        stops: [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        ),
      ),
    );

    overlay.insert(entry);
    _entry = entry;
    controller.forward();

    Future.delayed(const Duration(seconds: 3), () {
      controller.reverse().then((_) {
        if (_entry == entry) {
          entry.remove();
          _entry = null;
        }
        controller.dispose();
      });
    });
  }
}
