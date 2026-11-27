import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/utils/formatters.dart';
import '../../providers/vpn_provider.dart';
import '../../providers/config_provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/tunnel/power_button_gauge.dart';
import '../../widgets/tunnel/active_tunnel_card.dart';
import '../../widgets/tunnel/traffic_stats_card.dart';
import '../../widgets/tunnel/quick_action_card.dart';

class TunnelScreen extends StatelessWidget {
  final VoidCallback onOpenDrawer;
  final VoidCallback onNavigateToConfigs;

  const TunnelScreen({
    super.key,
    required this.onOpenDrawer,
    required this.onNavigateToConfigs,
  });

  @override
  Widget build(BuildContext context) {
    final vpnProvider = context.watch<VpnProvider>();
    final configProvider = context.watch<ConfigProvider>();
    final settingsProvider = context.watch<SettingsProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final activeConfig = configProvider.selectedConfig;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 16,
        title: Row(
          children: [
            // Menu / Drawer Button
            InkWell(
              onTap: onOpenDrawer,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF141C24) : const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.menu_rounded,
                    size: 20,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),

            // App Title & Status
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'SENSEI ',
                        style: AppTypography.titleLarge.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                      TextSpan(
                        text: 'TUNNEL',
                        style: AppTypography.titleLarge.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: isDark ? AppColors.neonGreen : AppColors.neonGreenDark,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: vpnProvider.isConnected
                            ? AppColors.neonGreen
                            : (vpnProvider.isConnecting
                                ? AppColors.warningOrange
                                : AppColors.darkTextMuted),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      vpnProvider.isConnected
                          ? 'Secured • ${activeConfig.protocol}'
                          : (vpnProvider.isConnecting ? 'Connecting...' : 'Not Connected'),
                      style: AppTypography.caption.copyWith(
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        actions: [
          // Theme Toggle Button (Sun in Dark, Moon in Light)
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: InkWell(
              onTap: () => settingsProvider.toggleTheme(),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF141C24) : const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
                child: Center(
                  child: Icon(
                    isDark ? Icons.wb_sunny_rounded : Icons.nightlight_round,
                    size: 19,
                    color: isDark ? AppColors.neonGreen : const Color(0xFF065F46),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              const SizedBox(height: 12),

              // Large Speedometer Gauge & Glowing Power Button
              PowerButtonGauge(
                isConnected: vpnProvider.isConnected,
                isConnecting: vpnProvider.isConnecting,
                onTap: () => vpnProvider.toggleConnection(),
              ),

              const SizedBox(height: 18),

              // Status Text (CONNECTED / DISCONNECTED)
              Text(
                vpnProvider.isConnected
                    ? 'CONNECTED'
                    : (vpnProvider.isConnecting ? 'CONNECTING...' : 'DISCONNECTED'),
                style: AppTypography.titleSmall.copyWith(
                  color: vpnProvider.isConnected
                      ? (isDark ? AppColors.neonGreen : AppColors.neonGreenDark)
                      : (isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
                  letterSpacing: 3.5,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),

              const SizedBox(height: 6),

              // Connection Timer
              Text(
                Formatters.formatDuration(vpnProvider.connectedDuration),
                style: AppTypography.monospaceLarge.copyWith(
                  fontSize: 34,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),

              const SizedBox(height: 4),

              // Current Config Subtitle
              Text(
                activeConfig.name,
                style: AppTypography.bodySmall.copyWith(
                  color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                  fontSize: 12,
                ),
              ),

              const SizedBox(height: 22),

              // Active Tunnel Card
              ActiveTunnelCard(
                config: activeConfig,
                pingMs: vpnProvider.stats.pingMs,
                onTap: onNavigateToConfigs,
              ),

              const SizedBox(height: 12),

              // Traffic Stats Card (Download, Upload, Ping + Sparkline, Session)
              TrafficStatsCard(
                stats: vpnProvider.stats,
              ),

              const SizedBox(height: 12),

              // Quick Action Cards (Split Tunnel, Speed Test)
              Row(
                children: [
                  QuickActionCard(
                    icon: Icons.alt_route_rounded,
                    title: 'SPLIT TUNNEL',
                    value: settingsProvider.splitTunnel,
                    onTap: () {
                      _showSplitTunnelDialog(context, settingsProvider);
                    },
                  ),
                  const SizedBox(width: 12),
                  QuickActionCard(
                    icon: Icons.speed_rounded,
                    title: 'SPEED TEST',
                    value: 'Live',
                    onTap: () {
                      _showSpeedTestSheet(context, vpnProvider);
                    },
                  ),
                ],
              ),

              const SizedBox(height: 90), // Bottom padding for floating nav bar
            ],
          ),
        ),
      ),
    );
  }

  void _showSplitTunnelDialog(BuildContext context, SettingsProvider settings) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Split Tunneling', style: AppTypography.titleMedium),
              const SizedBox(height: 8),
              Text(
                'Route only selected apps through the VPN tunnel, or bypass specific streaming/banking apps.',
                style: AppTypography.bodySmall,
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Bypass All (Off)'),
                leading: const Icon(Icons.block_rounded),
                trailing: const Icon(Icons.check, color: AppColors.neonGreen),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSpeedTestSheet(BuildContext context, VpnProvider vpn) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Speed Test Live Probe', style: AppTypography.titleMedium),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      const Text('Download', style: TextStyle(color: Colors.grey)),
                      const SizedBox(height: 4),
                      Text(
                        Formatters.formatSpeed(vpn.stats.downloadKbps),
                        style: AppTypography.titleLarge.copyWith(color: AppColors.neonGreen),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      const Text('Upload', style: TextStyle(color: Colors.grey)),
                      const SizedBox(height: 4),
                      Text(
                        Formatters.formatSpeed(vpn.stats.uploadKbps),
                        style: AppTypography.titleLarge.copyWith(color: AppColors.neonGreen),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      const Text('Latency', style: TextStyle(color: Colors.grey)),
                      const SizedBox(height: 4),
                      Text(
                        '${vpn.stats.pingMs} ms',
                        style: AppTypography.titleLarge.copyWith(color: AppColors.neonGreen),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}
