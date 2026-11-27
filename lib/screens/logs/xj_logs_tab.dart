import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/log_entry.dart';
import '../../providers/vpn_provider.dart';

class MkLogsTab extends StatelessWidget {
  const MkLogsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final vpnProvider = context.watch<VpnProvider>();
    final logs = vpnProvider.logs;

    return Container(
      color: const Color(0xFFF9FAFB),
      child: Column(
        children: [
          // Logs Action Toolbar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${logs.length} entries',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryGreenDark,
                    ),
                  ),
                ),
                const Spacer(),

                // Copy Logs Button
                TextButton.icon(
                  icon: const Icon(Icons.copy_rounded, size: 16, color: Color(0xFF4B5563)),
                  label: const Text('Copy', style: TextStyle(color: Color(0xFF4B5563), fontSize: 13)),
                  onPressed: () {
                    final logText = logs
                        .map((l) => '[${l.formattedTime}] [${l.tag}] ${l.message}')
                        .join('\n');
                    Clipboard.setData(ClipboardData(text: logText));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Logs copied to clipboard!')),
                    );
                  },
                ),

                const SizedBox(width: 8),

                // Clear Logs Button
                TextButton.icon(
                  icon: const Icon(Icons.delete_outline_rounded, size: 16, color: Color(0xFFEF4444)),
                  label: const Text('Clear', style: TextStyle(color: Color(0xFFEF4444), fontSize: 13)),
                  onPressed: () {
                    vpnProvider.clearLogs();
                  },
                ),
              ],
            ),
          ),

          // Logs Content List
          Expanded(
            child: logs.isEmpty
                ? const Center(
                    child: Text(
                      'No logs yet.',
                      style: TextStyle(color: Color(0xFF9E9E9E)),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    itemCount: logs.length,
                    itemBuilder: (context, index) {
                      final entry = logs[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFF1F5F9)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.02),
                              blurRadius: 3,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Timestamp
                            Text(
                              entry.formattedTime,
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 11,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                            const SizedBox(width: 8),

                            // Tag
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: _getTagBgColor(entry.tag),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                entry.tag,
                                style: TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: _getTagTextColor(entry.tag),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),

                            // Message
                            Expanded(
                              child: Text(
                                entry.message,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: _getMessageColor(entry.level),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Color _getTagBgColor(String tag) {
    switch (tag) {
      case 'TUNNEL':
        return const Color(0xFFDCFCE7);
      case 'OVPN':
        return const Color(0xFFE0F2FE);
      case 'ROUTE':
        return const Color(0xFFFEF3C7);
      case 'PAYLOAD':
        return const Color(0xFFF3E8FF);
      case 'REWARD':
        return const Color(0xFFECFDF5);
      default:
        return const Color(0xFFF1F5F9);
    }
  }

  Color _getTagTextColor(String tag) {
    switch (tag) {
      case 'TUNNEL':
        return const Color(0xFF15803D);
      case 'OVPN':
        return const Color(0xFF0369A1);
      case 'ROUTE':
        return const Color(0xFFB45309);
      case 'PAYLOAD':
        return const Color(0xFF7E22CE);
      case 'REWARD':
        return const Color(0xFF047857);
      default:
        return const Color(0xFF475569);
    }
  }

  Color _getMessageColor(LogLevel level) {
    switch (level) {
      case LogLevel.success:
        return const Color(0xFF16A34A);
      case LogLevel.error:
        return const Color(0xFFDC2626);
      case LogLevel.warning:
        return const Color(0xFFD97706);
      case LogLevel.info:
        return const Color(0xFF1F2937);
    }
  }
}

/// Backward compatibility alias
typedef XjLogsTab = MkLogsTab;
typedef MkTunnelLogsTab = MkLogsTab;
