import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../models/config_item.dart';
import '../common/glass_card.dart';
import '../common/status_badge.dart';

class ActiveTunnelCard extends StatelessWidget {
  final ConfigItem config;
  final int pingMs;
  final VoidCallback onTap;

  const ActiveTunnelCard({
    super.key,
    required this.config,
    required this.pingMs,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassCard(
      borderRadius: 18,
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Stack(
        children: [
          // Faint watermark "SENSEI TUNNEL"
          Positioned(
            right: 12,
            top: 10,
            child: Opacity(
              opacity: isDark ? 0.08 : 0.04,
              child: Text(
                'SENSEI\nTUNNEL',
                textAlign: TextAlign.right,
                style: AppTypography.titleLarge.copyWith(
                  fontWeight: FontWeight.w900,
                  height: 0.9,
                  letterSpacing: 2,
                  color: isDark ? AppColors.neonGreen : Colors.black,
                ),
              ),
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top label & Signal / Ping ms
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'ACTIVE TUNNEL',
                    style: AppTypography.caption.copyWith(
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w600,
                      fontSize: 10,
                    ),
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.network_cell_rounded,
                        size: 15,
                        color: AppColors.neonGreen,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$pingMs ms',
                        style: AppTypography.monospaceSmall.copyWith(
                          color: AppColors.neonGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Provider Icon + Title + Dropdown Chevron
              Row(
                children: [
                  _buildProviderIcon(config.iconType),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Row(
                      children: [
                        Flexible(
                          child: Text(
                            config.name,
                            style: AppTypography.titleMedium.copyWith(
                              fontSize: 15,
                              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 20,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Badges row (SSH, TCP, SNI, etc.)
              Padding(
                padding: const EdgeInsets.only(left: 48),
                child: Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: config.tags.map((tag) => StatusBadge(label: tag)).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProviderIcon(ConfigIconType type) {
    switch (type) {
      case ConfigIconType.robi:
        return Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF1E151A),
            border: Border.all(color: const Color(0xFFE11D48), width: 1.5),
          ),
          child: Center(
            child: Container(
              width: 20,
              height: 20,
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
      case ConfigIconType.imo:
        return Container(
          width: 36,
          height: 36,
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
                fontSize: 10,
              ),
            ),
          ),
        );
      case ConfigIconType.ryze:
        return Container(
          width: 36,
          height: 36,
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
          width: 36,
          height: 36,
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
