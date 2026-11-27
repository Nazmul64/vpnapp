import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark
        ? const Color(0xFF0F151C)
        : const Color(0xFFF1F5F9);

    final borderColor = isDark
        ? const Color(0xFF1B242D)
        : const Color(0xFFE2E8F0);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            index: 0,
            icon: Icons.shield,
            label: 'Tunnel',
            isDark: isDark,
          ),
          _buildNavItem(
            index: 1,
            icon: Icons.dns_rounded,
            label: 'Configs',
            isDark: isDark,
          ),
          _buildNavItem(
            index: 2,
            icon: Icons.terminal_rounded,
            label: 'Logs',
            isDark: isDark,
          ),
          _buildNavItem(
            index: 3,
            icon: Icons.tune_rounded,
            label: 'Settings',
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
    required bool isDark,
  }) {
    final isSelected = currentIndex == index;

    if (isSelected) {
      return AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.neonGreen,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            if (isDark)
              BoxShadow(
                color: AppColors.neonGreen.withValues(alpha: 0.35),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: Colors.black,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTypography.titleSmall.copyWith(
                color: Colors.black,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      );
    }

    return IconButton(
      onPressed: () => onTap(index),
      splashRadius: 24,
      icon: Icon(
        icon,
        size: 22,
        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
      ),
    );
  }
}
