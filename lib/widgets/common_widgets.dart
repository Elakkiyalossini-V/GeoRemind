import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Frosted card — equivalent of `.glass` in the prototype's CSS.
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  const GlassCard({super.key, required this.child, this.padding = const EdgeInsets.all(16)});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.glassFill,
        border: Border.all(color: AppColors.glassBorder),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: child,
    );
  }
}

/// Solid card — equivalent of `.card`.
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  const AppCard({super.key, required this.child, this.padding = const EdgeInsets.all(16)});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.glassBorder),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: child,
    );
  }
}

enum AppButtonStyle { primary, secondary, ghost, danger, emerald }

class AppButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onTap;
  final AppButtonStyle style;
  const AppButton({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.style = AppButtonStyle.primary,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[Icon(icon, size: 17), const SizedBox(width: 8)],
        Text(label, style: AppText.body(size: 14.5, weight: FontWeight.w600, color: _fg())),
      ],
    );

    final radius = BorderRadius.circular(14);
    final button = InkWell(
      onTap: onTap,
      borderRadius: radius,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
        decoration: BoxDecoration(
          gradient: style == AppButtonStyle.primary ? AppColors.mainGradient : null,
          color: _bg(),
          border: style == AppButtonStyle.secondary || style == AppButtonStyle.danger
              ? Border.all(color: style == AppButtonStyle.danger ? AppColors.danger.withOpacity(0.25) : AppColors.glassBorder)
              : null,
          borderRadius: radius,
        ),
        child: content,
      ),
    );
    return button;
  }

  Color? _bg() {
    switch (style) {
      case AppButtonStyle.secondary:
        return AppColors.glassFill2;
      case AppButtonStyle.danger:
        return AppColors.danger.withOpacity(0.12);
      case AppButtonStyle.emerald:
        return null;
      case AppButtonStyle.ghost:
      case AppButtonStyle.primary:
        return null;
    }
  }

  Color _fg() {
    switch (style) {
      case AppButtonStyle.danger:
        return AppColors.danger;
      case AppButtonStyle.ghost:
        return AppColors.textMid;
      case AppButtonStyle.emerald:
        return const Color(0xFF04140D);
      case AppButtonStyle.secondary:
      case AppButtonStyle.primary:
        return AppColors.textHi;
    }
  }
}

/// Top bar with a back button — equivalent of `topbar()` helper.
class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final List<Widget>? actions;
  const AppTopBar({super.key, required this.title, this.subtitle, this.actions});

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 6, 20, 10),
        child: Row(
          children: [
            InkWell(
              onTap: () => Navigator.of(context).maybePop(),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.glassFill,
                  border: Border.all(color: AppColors.glassBorder),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.arrow_back_ios_new, size: 16, color: AppColors.textHi),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title, style: AppText.display(size: 19)),
                  if (subtitle != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 1),
                      child: Text(subtitle!, style: AppText.body(size: 12, color: AppColors.textMid)),
                    ),
                ],
              ),
            ),
            if (actions != null) ...actions!,
          ],
        ),
      ),
    );
  }
}

/// Header used on the 5 root tabs — equivalent of `tabHeader()`.
class TabHeader extends StatelessWidget {
  final String eyebrow;
  final String title;
  const TabHeader({super.key, required this.eyebrow, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(eyebrow.toUpperCase(),
              style: AppText.mono(size: 11, weight: FontWeight.w600, color: AppColors.textLow)),
          const SizedBox(height: 4),
          Text(title, style: AppText.display(size: 26)),
        ],
      ),
    );
  }
}

class SectionLabel extends StatelessWidget {
  final String text;
  const SectionLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 10),
      child: Text(text.toUpperCase(),
          style: AppText.body(size: 11, weight: FontWeight.w600, color: AppColors.textLow)),
    );
  }
}

class PinBadge extends StatelessWidget {
  final String emoji;
  final double size;
  const PinBadge({super.key, required this.emoji, this.size = 44});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(gradient: AppColors.mainGradient, borderRadius: BorderRadius.circular(size * 0.3)),
      alignment: Alignment.center,
      child: Text(emoji, style: TextStyle(fontSize: size * 0.42)),
    );
  }
}

class AppChip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const AppChip({super.key, required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(100),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: active ? AppColors.emerald.withOpacity(0.14) : AppColors.glassFill,
          border: Border.all(color: active ? AppColors.emerald.withOpacity(0.4) : AppColors.glassBorder),
          borderRadius: BorderRadius.circular(100),
        ),
        child: Text(label, style: AppText.body(size: 12.5, weight: FontWeight.w500, color: active ? AppColors.emerald : AppColors.textMid)),
      ),
    );
  }
}

class AppSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  const AppSwitch({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: value,
      onChanged: onChanged,
      activeColor: AppColors.emerald,
      activeTrackColor: AppColors.emeraldDim,
      inactiveTrackColor: AppColors.glassFill2,
    );
  }
}

class ListRow extends StatelessWidget {
  final Widget leading;
  final Widget title;
  final Widget? subtitle;
  final List<Widget>? trailing;
  final VoidCallback? onTap;
  const ListRow({super.key, required this.leading, required this.title, this.subtitle, this.trailing, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
        child: Row(
          children: [
            leading,
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  title,
                  if (subtitle != null) Padding(padding: const EdgeInsets.only(top: 3), child: subtitle!),
                ],
              ),
            ),
            if (trailing != null) ...trailing!,
          ],
        ),
      ),
    );
  }
}

class DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const DetailRow({super.key, required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(children: [
            Icon(icon, size: 16, color: AppColors.textMid),
            const SizedBox(width: 10),
            Text(label, style: AppText.body(size: 13, color: AppColors.textMid)),
          ]),
          Text(value, style: AppText.body(size: 13.5, weight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const EmptyState({super.key, required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
      child: Column(
        children: [
          Icon(icon, size: 32, color: AppColors.textMid.withOpacity(0.4)),
          const SizedBox(height: 8),
          Text(title, style: AppText.body(size: 14, weight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(subtitle, textAlign: TextAlign.center, style: AppText.body(size: 12.5, color: AppColors.textMid)),
        ],
      ),
    );
  }
}

/// Progress ring — equivalent of the prototype's SVG `ringSvg()`.
class ProgressRing extends StatelessWidget {
  final double percent; // 0..100
  final double size;
  const ProgressRing({super.key, required this.percent, this.size = 90});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _RingPainter(percent: percent)),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double percent;
  _RingPainter({required this.percent});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2 - 5;
    final bg = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;
    final fg = Paint()
      ..shader = const LinearGradient(colors: [AppColors.purple1, AppColors.emerald])
          .createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bg);
    final sweep = 2 * 3.14159265 * (percent / 100);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -1.5708, sweep, false, fg);
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) => oldDelegate.percent != percent;
}

/// Horizontal bar row — equivalent of `barRow()`.
class BarRow extends StatelessWidget {
  final String label;
  final int percent;
  const BarRow({super.key, required this.label, required this.percent});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppText.body(size: 12.5)),
            Text('$percent%', style: AppText.mono(size: 11.5, color: AppColors.textMid)),
          ],
        ),
        const SizedBox(height: 5),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Container(
            height: 7,
            color: Colors.white.withOpacity(0.07),
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: percent / 100,
              child: Container(decoration: const BoxDecoration(gradient: AppColors.mainGradient)),
            ),
          ),
        ),
      ],
    );
  }
}

/// Small toast — equivalent of the prototype's `toast()` helper.
void showAppToast(BuildContext context, String message) {
  final overlay = Overlay.of(context);
  final entry = OverlayEntry(
    builder: (context) => Positioned(
      left: 20,
      right: 20,
      bottom: 96,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          decoration: BoxDecoration(
            color: AppColors.surface2,
            border: Border.all(color: AppColors.glassBorder),
            borderRadius: BorderRadius.circular(14),
            boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 30, offset: Offset(0, 12))],
          ),
          child: Text(message, style: AppText.body(size: 13)),
        ),
      ),
    ),
  );
  overlay.insert(entry);
  Future.delayed(const Duration(seconds: 2), () => entry.remove());
}
