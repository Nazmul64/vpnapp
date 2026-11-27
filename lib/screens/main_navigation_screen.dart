import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_typography.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/common/custom_bottom_nav.dart';
import 'tunnel/tunnel_screen.dart';
import 'configs/configs_screen.dart';
import 'logs/logs_screen.dart';
import 'settings/settings_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final screens = [
      TunnelScreen(
        onOpenDrawer: () => _scaffoldKey.currentState?.openDrawer(),
        onNavigateToConfigs: () => setState(() => _currentIndex = 1),
      ),
      const ConfigsScreen(),
      const LogsScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      key: _scaffoldKey,
      extendBody: true,
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      drawer: _buildDrawer(context, isDark),
      body: Stack(
        children: [
          // Background Wallpaper (Cyber Anime Aesthetic)
          if (isDark && settingsProvider.enableWallpaper)
            Positioned.fill(
              child: Opacity(
                opacity: 0.32,
                child: Image.asset(
                  AppConstants.animeBgAsset,
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(color: AppColors.darkBg);
                  },
                ),
              ),
            ),

          // Ambient Dark/Light Gradient Overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: isDark
                      ? [
                          AppColors.darkBg.withValues(alpha: 0.70),
                          AppColors.darkBg.withValues(alpha: 0.92),
                        ]
                      : [
                          AppColors.lightBg.withValues(alpha: 0.85),
                          AppColors.lightBg.withValues(alpha: 0.98),
                        ],
                ),
              ),
            ),
          ),

          // Main Screen Body
          IndexedStack(
            index: _currentIndex,
            children: screens,
          ),

          // Floating Bottom Navigation Bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: CustomBottomNav(
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, bool isDark) {
    return Drawer(
      backgroundColor: isDark ? const Color(0xFF0C1218) : Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            // Drawer Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF121B24) : const Color(0xFFF1F5F9),
                border: Border(
                  bottom: BorderSide(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [AppColors.neonGreen, AppColors.neonGreenDark],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.neonGreen.withValues(alpha: 0.4),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(Icons.shield_rounded, color: Colors.black, size: 28),
                    ),
                  ),
                  const SizedBox(height: 12),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'SENSEI ',
                          style: AppTypography.titleLarge.copyWith(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                        TextSpan(
                          text: 'TUNNEL',
                          style: AppTypography.titleLarge.copyWith(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: AppColors.neonGreen,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'High Performance VPN & SSH Proxy Client',
                    style: AppTypography.bodySmall.copyWith(
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // Drawer Items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _buildDrawerItem(
                    icon: Icons.telegram_rounded,
                    title: 'Join Telegram Channel',
                    subtitle: 'Get daily updated configs & bugs',
                    onTap: () => Navigator.pop(context),
                  ),
                  _buildDrawerItem(
                    icon: Icons.cloud_download_rounded,
                    title: 'Backup & Restore Configs',
                    subtitle: 'Export or import your configurations',
                    onTap: () => Navigator.pop(context),
                  ),
                  _buildDrawerItem(
                    icon: Icons.speed_rounded,
                    title: 'DNS Leak Test',
                    subtitle: 'Check IP leaks and DNS status',
                    onTap: () => Navigator.pop(context),
                  ),
                  _buildDrawerItem(
                    icon: Icons.info_outline_rounded,
                    title: 'About Sensei Tunnel',
                    subtitle: AppConstants.appVersion,
                    onTap: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Bottom info
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Sensei Tunnel ${AppConstants.appVersion}\nCrafted with Flutter',
                textAlign: TextAlign.center,
                style: AppTypography.caption.copyWith(
                  color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF141C24) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.neonGreen, size: 20),
      ),
      title: Text(
        title,
        style: AppTypography.titleSmall.copyWith(
          fontSize: 14,
          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppTypography.bodySmall.copyWith(
          fontSize: 11,
          color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
        ),
      ),
      onTap: onTap,
    );
  }
}
