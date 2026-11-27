import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/utils/formatters.dart';
import '../../models/traffic_stats.dart';
import '../common/glass_card.dart';
import '../common/live_wave_painter.dart';

class TrafficStatsCard extends StatelessWidget {
  final TrafficStats stats;

  const TrafficStatsCard({
    super.key,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassCard(
      borderRadius: 18,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        children: [
          // 3 Columns: Download, Upload, Ping + Sparkline
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Download Column
              Expanded(
                child: Column(
                  children: [
                    const Icon(
                      Icons.arrow_downward_rounded,
                      size: 16,
                      color: AppColors.neonGreen,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      Formatters.formatSpeed(stats.downloadKbps),
                      style: AppTypography.titleMedium.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Download',
                      style: AppTypography.bodySmall.copyWith(
                        color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),

              // Upload Column
              Expanded(
                child: Column(
                  children: [
                    const Icon(
                      Icons.arrow_upward_rounded,
                      size: 16,
                      color: AppColors.neonGreen,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      Formatters.formatSpeed(stats.uploadKbps),
                      style: AppTypography.titleMedium.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Upload',
                      style: AppTypography.bodySmall.copyWith(
                        color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),

              // Latency + Waveform Column
              Expanded(
                child: Column(
                  children: [
                    const Icon(
                      Icons.call_received_rounded,
                      size: 16,
                      color: AppColors.neonGreen,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${stats.pingMs} ms',
                      style: AppTypography.titleMedium.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      height: 14,
                      width: 56,
                      child: CustomPaint(
                        painter: LiveWavePainter(
                          values: stats.pingHistory,
                          color: AppColors.neonGreen,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          Divider(
            height: 1,
            thickness: 0.8,
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
          const SizedBox(height: 12),

          // Bottom Session Stats Row
          Row(
            children: [
              const Icon(
                Icons.refresh_rounded,
                size: 16,
                color: AppColors.neonGreen,
              ),
              const SizedBox(width: 8),
              Text(
                'Session',
                style: AppTypography.bodyMedium.copyWith(
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Text(
                '↓ ${Formatters.formatDataUsage(stats.sessionDownloadMb)}   ↑ ${Formatters.formatDataUsage(stats.sessionUploadMb)}',
                style: AppTypography.monospaceSmall.copyWith(
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
