import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/config_provider.dart';
import '../common/xj_logo_widget.dart';
import '../../screens/tools/drawer_tools_modals.dart';

class MkNavigationDrawer extends StatelessWidget {
  const MkNavigationDrawer({super.key});

  static Future<void> _launchExternalUrl(BuildContext context, String urlString) async {
    if (urlString.trim().isEmpty) return;
    try {
      String target = urlString.trim();
      // Auto-format WhatsApp phone numbers or emails
      if (!target.startsWith('http://') && !target.startsWith('https://') && !target.startsWith('mailto:')) {
        if (target.contains('@')) {
          target = 'mailto:$target';
        } else {
          final cleanPhone = target.replaceAll(RegExp(r'[^0-9]'), '');
          target = 'https://wa.me/$cleanPhone';
        }
      }

      final uri = Uri.parse(target);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(uri);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open link: $urlString'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final configProvider = context.watch<ConfigProvider>();
    final primaryColor = configProvider.primaryColor;

    return Drawer(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(0)),
      ),
      child: Column(
        children: [
          // Drawer Header with Developer Info & Facebook
          _buildDrawerHeader(context, configProvider, primaryColor),

          // Drawer Menu Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _buildDrawerItem(
                  context,
                  icon: Icons.add_location_alt_outlined,
                  title: 'Custom Server',
                  primaryColor: primaryColor,
                  onTap: () => CustomServerModal.show(context),
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.wb_sunny_outlined,
                  title: 'Theme Settings',
                  primaryColor: primaryColor,
                  onTap: () => ThemeSettingsModal.show(context),
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.settings_outlined,
                  title: 'App Settings',
                  primaryColor: primaryColor,
                  onTap: () => AppSettingsModal.show(context),
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.public_rounded,
                  title: 'V2ray Settings',
                  primaryColor: primaryColor,
                  onTap: () => ProtocolSettingsModal.show(context),
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.vpn_key_outlined,
                  title: 'OpenVPN Settings',
                  primaryColor: primaryColor,
                  onTap: () => ProtocolSettingsModal.show(context),
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.my_location_rounded,
                  title: 'Mobile IP Hunter',
                  primaryColor: primaryColor,
                  onTap: () => IpHunterModal.show(context),
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Divider(height: 1, thickness: 0.8, color: Color(0xFFE5E7EB)),
                ),

                _buildDrawerItem(
                  context,
                  icon: Icons.speed_rounded,
                  title: 'SlowDns Checker',
                  primaryColor: primaryColor,
                  onTap: () => SlowDnsModal.show(context),
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.more_time_rounded,
                  title: 'RedeemTime Voucher',
                  primaryColor: primaryColor,
                  onTap: () => RedeemVoucherModal.show(context),
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.help_outline_rounded,
                  title: 'Beginner Tutorial',
                  primaryColor: primaryColor,
                  onTap: () => TutorialModal.show(context),
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.wifi_tethering_rounded,
                  title: 'Hotspot Share',
                  primaryColor: primaryColor,
                  onTap: () => HotspotModal.show(context),
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.assignment_outlined,
                  title: 'IP Address Checker',
                  primaryColor: primaryColor,
                  onTap: () => IpCheckerModal.show(context),
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.search_rounded,
                  title: 'HostName Finder',
                  primaryColor: primaryColor,
                  onTap: () => HostFinderModal.show(context),
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.fingerprint_rounded,
                  title: 'Hardware ID (HWID)',
                  primaryColor: primaryColor,
                  onTap: () => HwidModal.show(context),
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.import_export_rounded,
                  title: 'Export / Import Config',
                  primaryColor: primaryColor,
                  onTap: () => ExportImportModal.show(context),
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Divider(height: 1, thickness: 0.8, color: Color(0xFFE5E7EB)),
                ),

                // Contact Admin & Support Item
                _buildDrawerItem(
                  context,
                  icon: Icons.headset_mic_outlined,
                  title: 'Contact Support & Admin',
                  primaryColor: primaryColor,
                  onTap: () => _showContactSupportModal(context, configProvider),
                ),

                // Privacy Policy Item
                _buildDrawerItem(
                  context,
                  icon: Icons.privacy_tip_outlined,
                  title: 'Privacy Policy',
                  primaryColor: primaryColor,
                  onTap: () => PrivacyPolicyModal.show(context),
                ),
              ],
            ),
          ),

          // Bottom Bar decoration matching theme
          Container(
            height: 20,
            color: primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader(
    BuildContext context,
    ConfigProvider config,
    Color primaryColor,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 40, 16, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            primaryColor,
            primaryColor.withValues(alpha: 0.9),
            Color.lerp(primaryColor, Colors.black, 0.4) ?? primaryColor,
          ],
        ),
      ),
      child: Column(
        children: [
          // Row with Logo & App Title
          Row(
            children: [
              const XjLogoWidget(
                size: 48,
                withGlow: true,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      config.appName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const Text(
                      AppConstants.buildInfo,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Developer Name & Facebook Profile Card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
            ),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(Icons.code_rounded, color: Colors.white, size: 20),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'DEVELOPER',
                        style: TextStyle(
                          color: Color(0xFF86EFAC),
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                        ),
                      ),
                      Text(
                        config.developerName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                // Clickable Facebook Button
                Material(
                  color: const Color(0xFF1877F2),
                  borderRadius: BorderRadius.circular(20),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => _launchExternalUrl(context, config.developerFacebook),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.facebook, color: Colors.white, size: 16),
                          SizedBox(width: 4),
                          Text(
                            'Facebook',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Quick Admin Support Buttons (WhatsApp & Telegram)
          Row(
            children: [
              Expanded(
                child: Material(
                  color: const Color(0xFF25D366),
                  borderRadius: BorderRadius.circular(8),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () => _launchExternalUrl(context, config.adminWhatsapp),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.chat_bubble_outline_rounded, color: Colors.white, size: 14),
                          SizedBox(width: 5),
                          Text(
                            'WhatsApp',
                            style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Material(
                  color: const Color(0xFF0088CC),
                  borderRadius: BorderRadius.circular(8),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () => _launchExternalUrl(context, config.adminTelegram),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.send_rounded, color: Colors.white, size: 13),
                          SizedBox(width: 5),
                          Text(
                            'Telegram',
                            style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static void _showContactSupportModal(BuildContext context, ConfigProvider config) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.support_agent_rounded, color: Color(0xFF2E7D32), size: 28),
                const SizedBox(width: 12),
                const Text(
                  'Support & Developer Info',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const Divider(height: 24),

            // Developer Row
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(
                backgroundColor: Color(0xFF1877F2),
                child: Icon(Icons.facebook, color: Colors.white),
              ),
              title: Text('Developer: ${config.developerName}', style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Open official developer profile on Facebook'),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
              onTap: () {
                Navigator.pop(ctx);
                _launchExternalUrl(context, config.developerFacebook);
              },
            ),

            // WhatsApp Row
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(
                backgroundColor: Color(0xFF25D366),
                child: Icon(Icons.chat_rounded, color: Colors.white),
              ),
              title: const Text('WhatsApp Admin Support', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(config.adminWhatsapp),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
              onTap: () {
                Navigator.pop(ctx);
                _launchExternalUrl(context, config.adminWhatsapp);
              },
            ),

            // Telegram Row
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(
                backgroundColor: Color(0xFF0088CC),
                child: Icon(Icons.send_rounded, color: Colors.white),
              ),
              title: const Text('Telegram Official Channel', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(config.adminTelegram),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
              onTap: () {
                Navigator.pop(ctx);
                _launchExternalUrl(context, config.adminTelegram);
              },
            ),

            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color primaryColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      dense: true,
      visualDensity: const VisualDensity(horizontal: 0, vertical: -2),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
      leading: Icon(
        icon,
        color: primaryColor,
        size: 22,
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF212121),
          fontSize: 14.2,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: () {
        Navigator.of(context).pop();
        onTap();
      },
    );
  }
}

/// Backward compatibility alias
typedef XjNavigationDrawer = MkNavigationDrawer;
typedef MkTunnelNavigationDrawer = MkNavigationDrawer;
