import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final bool hasGlowBorder;
  final Color? borderColor;
  final Color? backgroundColor;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.borderRadius = 16,
    this.hasGlowBorder = false,
    this.borderColor,
    this.backgroundColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final defaultBg = isDark
        ? AppColors.darkCard.withValues(alpha: 0.82)
        : AppColors.lightCard.withValues(alpha: 0.95);

    final defaultBorder = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    final effectiveBorderColor = borderColor ??
        (hasGlowBorder
            ? (isDark ? AppColors.neonGreen : AppColors.neonGreenDark)
            : defaultBorder);

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor ?? defaultBg,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: effectiveBorderColor,
          width: hasGlowBorder ? 1.5 : 1.0,
        ),
        boxShadow: [
          if (hasGlowBorder && isDark)
            BoxShadow(
              color: AppColors.neonGreen.withValues(alpha: 0.25),
              blurRadius: 10,
              spreadRadius: 1,
            )
          else if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(borderRadius),
        child: InkWell(
          borderRadius: BorderRadius.circular(borderRadius),
          onTap: onTap,
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}
