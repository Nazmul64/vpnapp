import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../models/log_entry.dart';
import '../../providers/vpn_provider.dart';

class LogsScreen extends StatelessWidget {
  const LogsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vpnProvider = context.watch<VpnProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Live Terminal Logs',
          style: AppTypography.titleLarge.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              final text = vpnProvider.logs
                  .map((l) => '[${l.formattedTime}] [${l.tag}] ${l.message}')
                  .join('\n');
              Clipboard.setData(ClipboardData(text: text));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Logs copied to clipboard'),
                  duration: Duration(seconds: 1),
                  backgroundColor: Color(0xFF1E293B),
                ),
              );
            },
            icon: const Icon(Icons.copy_rounded, color: AppColors.neonGreen, size: 20),
          ),
          IconButton(
            onPressed: () => vpnProvider.clearLogs(),
            icon: const Icon(Icons.delete_outline_rounded, color: AppColors.neonGreen, size: 22),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              // Terminal Container
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF080D11) : const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? const Color(0xFF1B2631) : const Color(0xFF334155),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: vpnProvider.logs.isEmpty
                      ? Center(
                          child: Text(
                            '>_ No logs recorded yet.',
                            style: AppTypography.monospaceSmall.copyWith(
                              color: AppColors.darkTextMuted,
                            ),
                          ),
                        )
                      : ListView.separated(
                          physics: const BouncingScrollPhysics(),
                          itemCount: vpnProvider.logs.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final log = vpnProvider.logs[index];
                            return _buildLogItem(log);
                          },
                        ),
                ),
              ),

              const SizedBox(height: 90), // Bottom padding for navigation bar
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogItem(LogEntry log) {
    Color tagColor;
    Color msgColor;

    switch (log.level) {
      case LogLevel.success:
        tagColor = AppColors.neonGreen;
        msgColor = const Color(0xFFE2E8F0);
        break;
      case LogLevel.warning:
        tagColor = AppColors.warningOrange;
        msgColor = const Color(0xFFFDE68A);
        break;
      case LogLevel.error:
        tagColor = AppColors.offlineRed;
        msgColor = const Color(0xFFFCA5A5);
        break;
      default:
        tagColor = const Color(0xFF38BDF8);
        msgColor = const Color(0xFFCBD5E1);
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Time
        Text(
          log.formattedTime,
          style: AppTypography.monospaceSmall.copyWith(
            color: const Color(0xFF64748B),
            fontSize: 10,
          ),
        ),
        const SizedBox(width: 8),

        // Tag badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
          decoration: BoxDecoration(
            color: tagColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: tagColor.withValues(alpha: 0.4), width: 0.8),
          ),
          child: Text(
            log.tag,
            style: AppTypography.monospaceSmall.copyWith(
              color: tagColor,
              fontSize: 9,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 8),

        // Message
        Expanded(
          child: Text(
            log.message,
            style: AppTypography.monospaceSmall.copyWith(
              color: msgColor,
              fontSize: 11,
              height: 1.25,
            ),
          ),
        ),
      ],
    );
  }
}
