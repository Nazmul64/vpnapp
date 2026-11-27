import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../models/config_item.dart';
import '../../providers/config_provider.dart';
import '../../widgets/configs/config_card.dart';
import '../../widgets/configs/config_group_header.dart';

class ConfigsScreen extends StatefulWidget {
  const ConfigsScreen({super.key});

  @override
  State<ConfigsScreen> createState() => _ConfigsScreenState();
}

class _ConfigsScreenState extends State<ConfigsScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isBdExpanded = true;
  bool _isSaudiExpanded = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final configProvider = context.watch<ConfigProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final displayedConfigs = configProvider.displayedConfigs;
    final bdConfigs = displayedConfigs.where((c) => c.group == 'BD CONFIGS').toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Configs',
          style: AppTypography.titleLarge.copyWith(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
        actions: [
          // Add Config Button (+)
          IconButton(
            onPressed: () => _showAddConfigSheet(context, configProvider),
            icon: const Icon(
              Icons.add_circle_outline_rounded,
              color: AppColors.neonGreen,
              size: 22,
            ),
          ),
          // Refresh Button
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Configs updated from server.'),
                  duration: Duration(seconds: 1),
                  backgroundColor: Color(0xFF1E293B),
                ),
              );
            },
            icon: const Icon(
              Icons.refresh_rounded,
              color: AppColors.neonGreen,
              size: 22,
            ),
          ),
          // Sort / Swap Button
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.swap_vert_rounded,
              color: AppColors.neonGreen,
              size: 22,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),

              // Search Bar
              Container(
                height: 48,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF111720) : const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDark ? const Color(0xFF1B242E) : const Color(0xFFCBD5E1),
                  ),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) => configProvider.setSearchQuery(val),
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search configs...',
                    hintStyle: AppTypography.bodyMedium.copyWith(
                      color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                      fontSize: 14,
                    ),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      size: 20,
                      color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Segmented Tabs: "My Configs" vs "Official"
              Container(
                height: 46,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF111720) : const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    // My Configs
                    Expanded(
                      child: GestureDetector(
                        onTap: () => configProvider.setOfficialTab(false),
                        child: Container(
                          decoration: BoxDecoration(
                            color: !configProvider.isOfficialTab
                                ? AppColors.neonGreen
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.person_rounded,
                                size: 18,
                                color: !configProvider.isOfficialTab
                                    ? Colors.black
                                    : (isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'My Configs',
                                style: AppTypography.titleSmall.copyWith(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: !configProvider.isOfficialTab
                                      ? Colors.black
                                      : (isDark
                                          ? AppColors.darkTextSecondary
                                          : AppColors.lightTextSecondary),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Official
                    Expanded(
                      child: GestureDetector(
                        onTap: () => configProvider.setOfficialTab(true),
                        child: Container(
                          decoration: BoxDecoration(
                            color: configProvider.isOfficialTab
                                ? AppColors.neonGreen
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.verified_rounded,
                                size: 18,
                                color: configProvider.isOfficialTab
                                    ? Colors.black
                                    : (isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Official',
                                style: AppTypography.titleSmall.copyWith(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: configProvider.isOfficialTab
                                      ? Colors.black
                                      : (isDark
                                          ? AppColors.darkTextSecondary
                                          : AppColors.lightTextSecondary),
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

              const SizedBox(height: 20),

              // Group 1: BD CONFIGS ( 6 )
              ConfigGroupHeader(
                flag: '🇧🇩',
                title: 'BD CONFIGS',
                count: bdConfigs.length,
                isExpanded: _isBdExpanded,
                onTap: () => setState(() => _isBdExpanded = !_isBdExpanded),
              ),

              const SizedBox(height: 8),

              if (_isBdExpanded)
                Column(
                  children: bdConfigs.map((config) {
                    final isSelected = config.id == configProvider.selectedConfigId;
                    return ConfigCard(
                      config: config,
                      isSelected: isSelected,
                      onTap: () {
                        configProvider.selectConfig(config.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Switched to ${config.name}'),
                            duration: const Duration(seconds: 1),
                            backgroundColor: const Color(0xFF1E293B),
                          ),
                        );
                      },
                    );
                  }).toList(),
                ),

              const SizedBox(height: 16),

              // Group 2: SAUDI ( 0 )
              ConfigGroupHeader(
                flag: '🇸🇦',
                title: 'SAUDI',
                count: 0,
                isExpanded: _isSaudiExpanded,
                onTap: () => setState(() => _isSaudiExpanded = !_isSaudiExpanded),
              ),

              if (_isSaudiExpanded)
                Padding(
                  padding: const EdgeInsets.only(left: 12, top: 8),
                  child: Text(
                    'No configs in this group',
                    style: AppTypography.bodySmall.copyWith(
                      color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.only(left: 8, top: 4),
                  child: Text(
                    'No configs in this group',
                    style: AppTypography.bodySmall.copyWith(
                      color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
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

  void _showAddConfigSheet(BuildContext context, ConfigProvider provider) {
    final nameCtrl = TextEditingController();
    final sniCtrl = TextEditingController(text: 'cdn.whatsapp.net');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Import / Add Custom Config', style: AppTypography.titleMedium),
              const SizedBox(height: 14),
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Config Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: sniCtrl,
                decoration: const InputDecoration(
                  labelText: 'SNI Host / Bug Host',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.neonGreen,
                  foregroundColor: Colors.black,
                  minimumSize: const Size.fromHeight(46),
                ),
                onPressed: () {
                  if (nameCtrl.text.isNotEmpty) {
                    provider.addConfig(
                      ConfigItem(
                        id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
                        name: nameCtrl.text,
                        group: 'MY CONFIGS',
                        tags: const ['SSH', 'TCP', 'SNI'],
                        iconType: ConfigIconType.custom,
                        isOfficial: false,
                        sniHost: sniCtrl.text,
                      ),
                    );
                    Navigator.pop(context);
                  }
                },
                child: const Text('Save Config', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      },
    );
  }
}
