import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_typography.dart';
import '../../providers/vpn_provider.dart';
import '../../providers/config_provider.dart';
import '../../services/vpn_ad_service.dart';
import '../../widgets/common/saudi_flag_widget.dart';
import '../../widgets/common/stopwatch_icon_widget.dart';
import '../../widgets/common/xj_logo_widget.dart';
import '../../widgets/common/operator_logo_widget.dart';
import '../../widgets/modals/custom_setup_dialog.dart';
import '../../widgets/modals/network_selection_modal.dart';
import '../../widgets/modals/custom_config_qr_modal.dart';
import '../../widgets/modals/protocol_selection_modal.dart';
import '../logs/xj_logs_tab.dart';
import '../../widgets/drawer/xj_navigation_drawer.dart';

class MkMainScreen extends StatefulWidget {
  const MkMainScreen({super.key});

  @override
  State<MkMainScreen> createState() => _MkMainScreenState();
}

class _MkMainScreenState extends State<MkMainScreen> {
  int _selectedTab = 0; // 0 for HOME, 1 for LOGS
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _showConnectedBadge = false;
  Timer? _connectedBadgeTimer;
  bool _wasConnected = false;

  @override
  void dispose() {
    _connectedBadgeTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      drawer: const XjNavigationDrawer(),
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          // Top Tabs: HOME | LOGS
          _buildTabBar(),

          // Main View (Home or Logs)
          Expanded(
            child: _selectedTab == 0
                ? _buildHomeBody(context)
                : const XjLogsTab(),
          ),

          // Banner Ad Widget (Configured dynamically from Admin Panel)
          const VpnBannerAdWidget(),

          // Bottom Bar Decoration
          Container(
            height: 24,
            color: context.watch<ConfigProvider>().primaryColor,
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final primaryColor = context.watch<ConfigProvider>().primaryColor;

    return AppBar(
      backgroundColor: primaryColor,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.menu_rounded, color: Colors.white, size: 26),
        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
      ),
      titleSpacing: 0,
      title: Text(
        context.watch<ConfigProvider>().appName,
        style: AppTypography.appBarTitle,
      ),
      actions: [
        // Refresh / Check config
        IconButton(
          icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 24),
          onPressed: () async {
            final configProv = context.read<ConfigProvider>();
            final vpnProv = context.read<VpnProvider>();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Checking configuration updates from backend...'), duration: Duration(seconds: 1)),
            );
            final ok = await configProv.syncWithBackend();
            await vpnProv.refreshNetworkInfo();
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(ok
                      ? 'Configuration synchronized: v${configProv.configVersion} (${configProv.displayedConfigs.length} servers active)'
                      : 'Using cached configuration (v${configProv.configVersion})'),
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          },
        ),
        // Notifications
        IconButton(
          icon: const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 24),
          onPressed: () {
            _showNotificationDialog(context);
          },
        ),
        // 3-dots Menu (Import/Export, Clear App Data, Exit matching reference screenshot)
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert_rounded, color: Colors.white, size: 24),
          color: Colors.white,
          elevation: 6,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          onSelected: (value) {
            if (value == 'import_export') {
              _showImportExportDialog(context);
            } else if (value == 'import_config') {
              CustomConfigQrModal.show(context, initialTab: 1);
            } else if (value == 'export_config') {
              final activeConfig = context.read<VpnProvider>().activeCustomConfig;
              CustomConfigQrModal.show(context, config: activeConfig, initialTab: 0);
            } else if (value == 'clear_data') {
              context.read<VpnProvider>().clearAppData();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('App data and cache cleared successfully.'),
                  duration: Duration(seconds: 2),
                ),
              );
            } else if (value == 'exit') {
              SystemNavigator.pop();
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'import_export',
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Import/Export',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  Icon(
                    Icons.arrow_right_rounded,
                    color: Color(0xFF6B7280),
                    size: 24,
                  ),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'clear_data',
              child: Text(
                'Clear App Data',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1F2937),
                ),
              ),
            ),
            const PopupMenuItem(
              value: 'exit',
              child: Text(
                'Exit',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1F2937),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    final primaryColor = context.watch<ConfigProvider>().primaryColor;

    return Container(
      color: Colors.white,
      child: Row(
        children: [
          // HOME TAB
          Expanded(
            child: InkWell(
              onTap: () {
                if (_selectedTab != 0) {
                  setState(() => _selectedTab = 0);
                }
              },
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      'HOME',
                      style: _selectedTab == 0
                          ? AppTypography.tabActive.copyWith(color: primaryColor)
                          : AppTypography.tabInactive,
                    ),
                  ),
                  Container(
                    height: 2.5,
                    color: _selectedTab == 0
                        ? primaryColor
                        : Colors.transparent,
                  ),
                ],
              ),
            ),
          ),

          // LOGS TAB
          Expanded(
            child: InkWell(
              onTap: () {
                if (_selectedTab != 1) {
                  setState(() => _selectedTab = 1);
                }
              },
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      'LOGS',
                      style: _selectedTab == 1
                          ? AppTypography.tabActive.copyWith(color: primaryColor)
                          : AppTypography.tabInactive,
                    ),
                  ),
                  Container(
                    height: 2.5,
                    color: _selectedTab == 1
                        ? primaryColor
                        : Colors.transparent,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHomeBody(BuildContext context) {
    final vpnProvider = context.watch<VpnProvider>();
    final isConnected = vpnProvider.isConnected;
    final primaryColor = context.watch<ConfigProvider>().primaryColor;

    if (isConnected && !_wasConnected) {
      _wasConnected = true;
      _showConnectedBadge = true;
      _connectedBadgeTimer?.cancel();
      _connectedBadgeTimer = Timer(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _showConnectedBadge = false;
          });
        }
      });
    } else if (!isConnected && _wasConnected) {
      _wasConnected = false;
      _showConnectedBadge = false;
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Column(
        children: [
          // Main VPN Card
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFE5E7EB),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Info Row: Network on left (e.g. Grameenphone [BD]), Traffic MB on right
                Row(
                  children: [
                    // Dynamic Carrier & Country Network Label
                    Expanded(
                      child: Text(
                        'Network: ${vpnProvider.currentNetwork}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1F2937),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    // Upload Traffic Badge
                    _buildTrafficBadge(
                      icon: Icons.arrow_upward_rounded,
                      label: vpnProvider.formattedUploadTraffic,
                    ),
                    const SizedBox(width: 8),

                    // Download Traffic Badge
                    _buildTrafficBadge(
                      icon: Icons.arrow_downward_rounded,
                      label: vpnProvider.formattedDownloadTraffic,
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Selector 1: Server Selector Box (Auto Select Server / Random Server / Auto)
                InkWell(
                  onTap: () => ProtocolSelectionModal.show(context),
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    constraints: const BoxConstraints(minHeight: 58),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: const Color(0xFF374151),
                        width: 1.2,
                      ),
                    ),
                    child: Row(
                      children: [
                        // Icon: Globe for Auto Select Server, or Flag for specific nodes
                        vpnProvider.isAutoServer
                            ? Container(
                                width: 36,
                                height: 36,
                                alignment: Alignment.center,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFFE0F2FE),
                                ),
                                child: const Icon(
                                  Icons.language_rounded,
                                  color: Color(0xFF0284C7),
                                  size: 24,
                                ),
                              )
                            : (vpnProvider.selectedProtocol.countryCode == 'SA'
                                ? const SaudiFlagWidget(width: 38, height: 26)
                                : Container(
                                    width: 38,
                                    height: 26,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF3F4F6),
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(color: const Color(0xFFE5E7EB)),
                                    ),
                                    child: Text(
                                      vpnProvider.selectedProtocol.flagEmoji,
                                      style: const TextStyle(fontSize: 20),
                                    ),
                                  )),
                        const SizedBox(width: 12),

                        // Server details (Responsive & no-overflow)
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                vpnProvider.selectedProtocol.title,
                                style: const TextStyle(
                                  fontSize: 13.8,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF111827),
                                  height: 1.15,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                vpnProvider.selectedProtocol.subtitle,
                                style: const TextStyle(
                                  fontSize: 10.8,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFF6B7280),
                                  height: 1.15,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 8),

                        // Green Pill Badge (Auto or Server Tag)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 11,
                            vertical: 5,
                          ),
                          constraints: const BoxConstraints(maxWidth: 90),
                          decoration: BoxDecoration(
                            color: const Color(0xFF43A047),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            vpnProvider.selectedProtocol.badge,
                            style: AppTypography.badgeText.copyWith(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Middle Row: Status & Custom Setup Toggle
                Row(
                  children: [
                    // Status
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF1F2937),
                        ),
                        children: [
                          const TextSpan(text: 'Status: '),
                          TextSpan(
                            text: isConnected
                                ? 'Connected'
                                : (vpnProvider.isConnecting
                                    ? 'Connecting...'
                                    : 'Disconnected'),
                            style: TextStyle(
                              color: isConnected
                                  ? const Color(0xFF43A047)
                                  : (vpnProvider.isConnecting
                                      ? Colors.orange
                                      : const Color(0xFFEF4444)),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    // Custom Setup
                    const Text(
                      'Custom Setup',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6B7280),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Transform.scale(
                      scale: 0.8,
                      child: Switch(
                        value: vpnProvider.customSetupEnabled,
                        activeTrackColor: primaryColor,
                        activeThumbColor: Colors.white,
                        inactiveThumbColor: Colors.white,
                        inactiveTrackColor: const Color(0xFFCBD5E1),
                        onChanged: (val) {
                          vpnProvider.setCustomSetup(val);
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Selector 2: Network Offer Box (When Custom Setup is OFF) OR Custom Setup Box (When Custom Setup is ON)
                InkWell(
                  onTap: () {
                    if (vpnProvider.customSetupEnabled) {
                      CustomSetupDialog.show(context);
                    } else {
                      NetworkSelectionModal.show(context);
                    }
                  },
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    constraints: const BoxConstraints(minHeight: 58),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: const Color(0xFF374151),
                        width: 1.2,
                      ),
                    ),
                    child: Row(
                      children: [
                        // Left Icon:
                        // If Custom Setup is ON: Green Gear Settings Icon
                        // If Custom Setup is OFF: Selected SIM/Network Icon (5G SIM / Airtel / Mobily / Globe)
                        if (vpnProvider.customSetupEnabled)
                          Container(
                            width: 36,
                            height: 36,
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFFDCFCE7),
                            ),
                            child: const Icon(
                              Icons.settings_rounded,
                              color: Color(0xFF43A047),
                              size: 24,
                            ),
                          )
                        else
                          OperatorLogoWidget(
                            iconType: vpnProvider.selectedPayload.iconType,
                            size: 36,
                          ),
                        const SizedBox(width: 12),

                        // Title & Subtitle:
                        // If Custom Setup is ON: Custom Setup Enabled / Tap to create your own setup
                        // If Custom Setup is OFF: Selected Network Offer name / Subtitle
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                vpnProvider.customSetupEnabled
                                    ? vpnProvider.customPayloadTitle
                                    : vpnProvider.selectedPayload.name,
                                style: const TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF111827),
                                  height: 1.15,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                vpnProvider.customSetupEnabled
                                    ? vpnProvider.customPayloadSubtitle
                                    : vpnProvider.selectedPayload.subtitle,
                                style: const TextStyle(
                                  fontSize: 10.8,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFF6B7280),
                                  height: 1.15,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Big Gradient Button: STOP / START
                InkWell(
                  onTap: () {
                    if (!isConnected) {
                      VpnAdService.showConnectAd(context, onDone: () {
                        vpnProvider.toggleConnection();
                      });
                    } else {
                      vpnProvider.toggleConnection();
                    }
                  },
                  borderRadius: BorderRadius.circular(26),
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          primaryColor,
                          Color.lerp(primaryColor, Colors.black, 0.25) ?? primaryColor,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(26),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withValues(alpha: 0.35),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      isConnected ? 'STOP' : 'START',
                      style: AppTypography.buttonText,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Bottom Row: Time Left & Add 5hrs
                Row(
                  children: [
                    // Stopwatch icon
                    const StopwatchIconWidget(size: 34),
                    const SizedBox(width: 8),

                    // Countdown text
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Time Left :',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF4B5563),
                          ),
                        ),
                        Text(
                          vpnProvider.formattedTimeLeft,
                          style: AppTypography.timerCountdown,
                        ),
                      ],
                    ),

                    const Spacer(),

                    // Add 5hrs Button (Rewarded Video Ad)
                    InkWell(
                      onTap: () {
                        VpnAdService.showRewardedAd(context, onReward: (bonusMinutes) {
                          vpnProvider.addFiveHours();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('+5 Hours Added! 🎉 Free time extended'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        });
                      },
                      borderRadius: BorderRadius.circular(22),
                      child: Container(
                        height: 44,
                        padding: const EdgeInsets.symmetric(horizontal: 22),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              primaryColor,
                              Color.lerp(primaryColor, Colors.black, 0.2) ?? primaryColor,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withValues(alpha: 0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          'Add 5hrs',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Floating Status Toast: Connected Successfully 😍 (Auto-hides after 2 seconds)
          if (_showConnectedBadge) ...[
            const SizedBox(height: 30),
            AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: _showConnectedBadge ? 1.0 : 0.0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 12,
                      spreadRadius: 1,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    XjLogoWidget(size: 26),
                    SizedBox(width: 10),
                    Text(
                      'Connected Successfully😍',
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          const SizedBox(height: 24),

          // Config Version at the bottom matching reference screenshot
          const Text(
            'Config Version: 1.2.89',
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),

          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildTrafficBadge({
    required IconData icon,
    required String label,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFF43A047),
          ),
          child: Center(
            child: Icon(
              icon,
              size: 11,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w500,
            color: Color(0xFF374151),
          ),
        ),
      ],
    );
  }

  void _showNotificationDialog(BuildContext context) {
    final ann = context.read<ConfigProvider>().announcement;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.notifications_active_rounded, color: Color(0xFF43A047)),
            SizedBox(width: 8),
            Text('Announcements', style: TextStyle(fontSize: 18)),
          ],
        ),
        content: Text(
          ann != null && ann.isNotEmpty
              ? ann
              : '🔥 MK Tunnel VPN Updates:\n\n'
                '• High-speed Contabo Europe Node 1 (89.116.28.187) operational.\n'
                '• Auto Select Server enabled by default.\n'
                '• Native Android VPN tunnel active with status bar badge.\n'
                '• Mobile carrier detection active.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK', style: TextStyle(color: Color(0xFF43A047))),
          ),
        ],
      ),
    );
  }

  void _showImportExportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.import_export_rounded, color: Color(0xFF43A047), size: 26),
            SizedBox(width: 8),
            Text(
              'Import / Export Config',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.file_download_outlined, color: Color(0xFF43A047)),
              ),
              title: const Text(
                'Import Config',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.5),
              ),
              subtitle: const Text(
                'Import from QR Code or MKCONFIG string',
                style: TextStyle(fontSize: 12),
              ),
              onTap: () {
                Navigator.pop(ctx);
                CustomConfigQrModal.show(context, initialTab: 1);
              },
            ),
            const Divider(height: 16),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.file_upload_outlined, color: Color(0xFF43A047)),
              ),
              title: const Text(
                'Export Config',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.5),
              ),
              subtitle: const Text(
                'Share or export active configuration',
                style: TextStyle(fontSize: 12),
              ),
              onTap: () {
                Navigator.pop(ctx);
                final activeConfig = context.read<VpnProvider>().activeCustomConfig;
                CustomConfigQrModal.show(context, config: activeConfig, initialTab: 0);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF43A047))),
          ),
        ],
      ),
    );
  }
}

/// Backward compatibility aliases
typedef XjMainScreen = MkMainScreen;
typedef MkTunnelMainScreen = MkMainScreen;
