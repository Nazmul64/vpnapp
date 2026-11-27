import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/settings/setting_toggle_card.dart';
import '../../widgets/settings/setting_tile.dart';
import '../../widgets/common/glass_card.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Settings',
          style: AppTypography.titleLarge.copyWith(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              // SECTION 1: CONNECTION
              _buildSectionHeader(
                icon: Icons.link_rounded,
                title: 'CONNECTION',
                isDark: isDark,
              ),
              const SizedBox(height: 12),

              // 2x2 Grid for Connection Toggles
              Row(
                children: [
                  Expanded(
                    child: SettingToggleCard(
                      icon: Icons.bolt_rounded,
                      title: 'Wake Lock',
                      description: 'Keep the CPU awake while connected',
                      value: settingsProvider.wakeLock,
                      onChanged: (_) => settingsProvider.toggleWakeLock(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SettingToggleCard(
                      icon: Icons.sync_rounded,
                      title: 'Auto Reconnect',
                      description: 'Reconnect automatically if the tunnel drops',
                      value: settingsProvider.autoReconnect,
                      onChanged: (_) => settingsProvider.toggleAutoReconnect(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: SettingToggleCard(
                      icon: Icons.block_flipped,
                      title: 'Kill Switch',
                      description: 'Block all traffic if the VPN drops',
                      value: settingsProvider.killSwitch,
                      onChanged: (_) => settingsProvider.toggleKillSwitch(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SettingToggleCard(
                      icon: Icons.hub_rounded,
                      title: 'Bypass LAN',
                      description: 'Keep local network traffic outside the tunnel',
                      value: settingsProvider.bypassLan,
                      onChanged: (_) => settingsProvider.toggleBypassLan(),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // SECTION 2: APPEARANCE
              _buildSectionHeader(
                icon: Icons.palette_outlined,
                title: 'APPEARANCE',
                isDark: isDark,
              ),
              const SizedBox(height: 12),

              // Theme Card
              Row(
                children: [
                  Expanded(
                    child: GlassCard(
                      borderRadius: 14,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.nightlight_round,
                                    size: 18,
                                    color: AppColors.neonGreen,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Theme',
                                    style: AppTypography.titleSmall.copyWith(
                                      fontSize: 14,
                                      color: isDark
                                          ? AppColors.darkTextPrimary
                                          : AppColors.lightTextPrimary,
                                    ),
                                  ),
                                ],
                              ),
                              // Segmented Moon / Sun pill
                              Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? const Color(0xFF1E293B)
                                      : const Color(0xFFCBD5E1),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () => settingsProvider.setDarkMode(true),
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: isDark
                                              ? AppColors.neonGreen
                                              : Colors.transparent,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.nightlight_round,
                                          size: 14,
                                          color: isDark ? Colors.black : Colors.grey,
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () => settingsProvider.setDarkMode(false),
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: !isDark
                                              ? AppColors.neonGreenDark
                                              : Colors.transparent,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.wb_sunny_rounded,
                                          size: 14,
                                          color: !isDark ? Colors.white : Colors.grey,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Switch between the dark and light palettes',
                            style: AppTypography.bodySmall.copyWith(
                              fontSize: 11,
                              color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Wallpaper Mode Card
                  Expanded(
                    child: GlassCard(
                      borderRadius: 14,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      onTap: () => settingsProvider.toggleWallpaperMode(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.crop_free_rounded,
                                    size: 18,
                                    color: AppColors.neonGreen,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Wallpaper Mode',
                                    style: AppTypography.titleSmall.copyWith(
                                      fontSize: 13,
                                      color: isDark
                                          ? AppColors.darkTextPrimary
                                          : AppColors.lightTextPrimary,
                                    ),
                                  ),
                                ],
                              ),
                              Icon(
                                Icons.chevron_right_rounded,
                                size: 18,
                                color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            settingsProvider.wallpaperMode,
                            style: AppTypography.titleSmall.copyWith(
                              fontSize: 13,
                              color: AppColors.neonGreen,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Device wallpaper behind a glass UI',
                            style: AppTypography.bodySmall.copyWith(
                              fontSize: 10,
                              color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // SECTION 3: ENGINE
              _buildSectionHeader(
                icon: Icons.memory_rounded,
                title: 'ENGINE',
                isDark: isDark,
              ),
              const SizedBox(height: 12),

              SettingTile(
                icon: Icons.code_rounded,
                title: 'MTU',
                description: 'Lower it if pages stall on mobile data',
                value: '${settingsProvider.mtu}',
                onTap: () {},
              ),
              SettingTile(
                icon: Icons.dns_rounded,
                title: 'DNS Servers',
                description: 'Resolvers used inside the tunnel',
                value: settingsProvider.dnsServer,
                onTap: () {},
              ),
              SettingTile(
                icon: Icons.speed_rounded,
                title: 'Ping Target',
                description: 'What the latency probe actually requests',
                value: settingsProvider.pingTarget,
                onTap: () {},
              ),
              SettingTile(
                icon: Icons.shield_outlined,
                title: 'Keepalive',
                description: 'Balance battery drain and idle tunnel drops',
                value: settingsProvider.keepalive,
                onTap: () {},
              ),
              SettingTile(
                icon: Icons.alt_route_rounded,
                title: 'Split Tunnel',
                description: 'Choose which apps use the tunnel',
                value: settingsProvider.splitTunnel,
                onTap: () {},
              ),
              SettingTile(
                icon: Icons.fork_right_rounded,
                title: 'Direct / Block',
                description: 'Send domains around the tunnel or drop them',
                value: settingsProvider.directBlock,
                onTap: () {},
              ),
              SettingTile(
                icon: Icons.terminal_rounded,
                title: 'TLS & Mux',
                description: 'Fragment the ClientHello, reuse connections',
                value: settingsProvider.tlsMux,
                onTap: () {},
              ),

              const SizedBox(height: 90), // Bottom padding for navigation bar
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required bool isDark,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.neonGreen),
        const SizedBox(width: 8),
        Text(
          title,
          style: AppTypography.caption.copyWith(
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }
}
