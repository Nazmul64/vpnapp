import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../models/config_item.dart';
import '../common/glass_card.dart';
import '../common/status_badge.dart';

class ConfigCard extends StatelessWidget {
  final ConfigItem config;
  final bool isSelected;
  final VoidCallback onTap;

  const ConfigCard({
    super.key,
    required this.config,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassCard(
      borderRadius: 14,
      hasGlowBorder: isSelected,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      onTap: onTap,
      child: Row(
        children: [
          _buildIcon(config.iconType),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  config.name,
                  style: AppTypography.titleMedium.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: config.tags.map((t) => StatusBadge(label: t)).toList(),
                ),
              ],
            ),
          ),
          if (isSelected)
            const Padding(
              padding: EdgeInsets.only(left: 8),
              child: Icon(
                Icons.check_circle_rounded,
                size: 20,
                color: AppColors.neonGreen,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildIcon(ConfigIconType type) {
    switch (type) {
      case ConfigIconType.imo:
        return Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF0284C7),
            border: Border.all(color: Colors.white, width: 1.5),
          ),
          child: const Center(
            child: Text(
              'imo',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 11,
              ),
            ),
          ),
        );
      case ConfigIconType.robi:
        return Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF1E151A),
            border: Border.all(color: const Color(0xFFE11D48), width: 1.5),
          ),
          child: Center(
            child: Container(
              width: 22,
              height: 22,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [Color(0xFFFF3366), Color(0xFFBE123C)],
                ),
              ),
              child: const Center(
                child: Text(
                  '●',
                  style: TextStyle(color: Colors.white, fontSize: 10),
                ),
              ),
            ),
          ),
        );
      case ConfigIconType.ryze:
        return Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF0F172A),
            border: Border.all(color: const Color(0xFF6366F1), width: 1.5),
          ),
          child: const Center(
            child: Text(
              '∞',
              style: TextStyle(
                color: Color(0xFF818CF8),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        );
      case ConfigIconType.custom:
        return Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.darkCardElevated,
            border: Border.all(color: AppColors.neonGreen, width: 1.5),
          ),
          child: const Center(
            child: Icon(
              Icons.vpn_key_rounded,
              size: 18,
              color: AppColors.neonGreen,
            ),
          ),
        );
    }
  }
}
