import 'dart:async';
import 'package:flutter/material.dart';
import '../models/config_item.dart';
import '../services/vpn_api_service.dart';

class ConfigProvider extends ChangeNotifier {
  bool _isOfficialTab = true;
  String _searchQuery = '';
  String _selectedConfigId = 'sa_mobily_1';
  bool _isLoading = false;
  int _configVersion = 1;
  String _appName = 'MK Tunnel VPN';
  String? _announcement;
  bool _maintenanceMode = false;
  Map<String, dynamic> _features = {};
  Map<String, dynamic> _credentials = {};
  Map<String, dynamic> _ads = {};

  String _developerName = 'Nazmul Islam';
  String _developerFacebook = 'https://facebook.com';
  String _adminWhatsapp = '+8801700000000';
  String _adminTelegram = 'https://t.me/mrtunnelvpn';
  String _adminEmail = 'support@mrtunnelvpn.com';

  String _privacyPolicyUrl = 'https://mktunnelvpn.xyz/privacy-policy';
  String _termsUrl = 'https://mktunnelvpn.xyz/terms-and-conditions';
  String _privacyPolicy = '';
  String _termsConditions = '';
  Color _primaryThemeColor = const Color(0xFF43A047); // Default green matching mobile app design
  bool _themeDarkMode = false;
  Timer? _autoSyncTimer;

  String get appName => _appName;
  String get developerName => _developerName;
  String get developerFacebook => _developerFacebook;
  String get adminWhatsapp => _adminWhatsapp;
  String get adminTelegram => _adminTelegram;
  String get adminEmail => _adminEmail;

  final List<ConfigItem> _configs = [
    const ConfigItem(
      id: 'contabo_de_1',
      name: '🇩🇪 Contabo Europe | MK Premium Node 1',
      group: 'EUROPE NODES',
      tags: ['OPENVPN', 'WS', 'Port 443'],
      iconType: ConfigIconType.custom,
      pingMs: 65,
      isOfficial: true,
      protocol: 'OPENVPN WS',
      serverAddress: '89.116.28.187',
      port: 443,
    ),
    const ConfigItem(
      id: 'sa_mobily_1',
      name: '🇸🇦 KSA | Mobily High-Speed WS',
      group: 'KSA NODES',
      tags: ['OPENVPN', 'WS', 'Port 443'],
      iconType: ConfigIconType.custom,
      pingMs: 55,
      isOfficial: true,
      protocol: 'OPENVPN WS',
      serverAddress: 'sa-mobily-1.mktunnelvpn.xyz',
      port: 443,
    ),
    const ConfigItem(
      id: 'sa_stc_1',
      name: '🇸🇦 KSA | STC Ultra Fast Xray',
      group: 'KSA NODES',
      tags: ['XRAY', 'WS', 'Port 443'],
      iconType: ConfigIconType.custom,
      pingMs: 62,
      isOfficial: true,
      protocol: 'XRAY WS',
      serverAddress: 'sa-stc-1.mktunnelvpn.xyz',
      port: 443,
    ),
    const ConfigItem(
      id: 'sg_node_1',
      name: '🇸🇬 SG | Singapore Fast Hysteria',
      group: 'ASIA NODES',
      tags: ['HYSTERIA', 'UDP', 'Port 443'],
      iconType: ConfigIconType.custom,
      pingMs: 110,
      isOfficial: true,
      protocol: 'HYSTERIA',
      serverAddress: 'sg-node-1.mktunnelvpn.xyz',
      port: 443,
    ),
    const ConfigItem(
      id: 'de_node_1',
      name: '🇩🇪 DE | Frankfurt OpenConnect',
      group: 'EUROPE NODES',
      tags: ['OCSERV', 'WS', 'Port 443'],
      iconType: ConfigIconType.custom,
      pingMs: 145,
      isOfficial: true,
      protocol: 'OPENCONNECT WS',
      serverAddress: 'de-node-1.mktunnelvpn.xyz',
      port: 443,
    ),
    const ConfigItem(
      id: 'imo_bypass_1',
      name: 'All sim Imo bypass',
      group: 'BD CONFIGS',
      tags: ['SSH', 'TCP', 'Proxy+Payload'],
      iconType: ConfigIconType.imo,
      pingMs: 245,
      isOfficial: true,
      protocol: 'SSH',
    ),
    const ConfigItem(
      id: 'robi_airtel_social',
      name: 'Robi-Airtel Social Pack Bypass',
      group: 'BD CONFIGS',
      tags: ['SSH', 'TCP', 'SNI'],
      iconType: ConfigIconType.robi,
      pingMs: 230,
      isOfficial: true,
      protocol: 'SSH',
    ),
  ];

  final List<ConfigItem> _myConfigs = [
    const ConfigItem(
      id: 'custom_ssh_1',
      name: 'Custom SSH Cloudflare Sni',
      group: 'MY CONFIGS',
      tags: ['SSH', 'TLS', 'SNI'],
      iconType: ConfigIconType.custom,
      pingMs: 180,
      isOfficial: false,
    ),
  ];

  ConfigProvider() {
    // Initial sync
    syncWithBackend();
    // Auto-poll every 5 seconds so any changes made in Admin Panel reflect in running app instantly
    _autoSyncTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      syncWithBackend(silent: true);
    });
  }

  @override
  void dispose() {
    _autoSyncTimer?.cancel();
    super.dispose();
  }

  bool get isOfficialTab => _isOfficialTab;
  String get searchQuery => _searchQuery;
  String get selectedConfigId => _selectedConfigId;
  bool get isLoading => _isLoading;
  int get configVersion => _configVersion;
  String? get announcement => _announcement;
  bool get maintenanceMode => _maintenanceMode;
  Map<String, dynamic> get features => _features;
  Map<String, dynamic> get credentials => _credentials;
  Map<String, dynamic> get ads => _ads;
  Color get primaryColor => _primaryThemeColor;
  bool get themeDarkMode => _themeDarkMode;
  String get privacyPolicyUrl => _privacyPolicyUrl;
  String get termsUrl => _termsUrl;
  String get privacyPolicy => _privacyPolicy;
  String get termsConditions => _termsConditions;

  ConfigItem get selectedConfig {
    return _configs.firstWhere(
      (c) => c.id == _selectedConfigId,
      orElse: () => _myConfigs.firstWhere(
        (c) => c.id == _selectedConfigId,
        orElse: () => _configs.first,
      ),
    );
  }

  List<ConfigItem> get displayedConfigs {
    final list = _isOfficialTab ? _configs : _myConfigs;
    if (_searchQuery.trim().isEmpty) return list;
    return list.where((c) => c.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
  }

  void setOfficialTab(bool value) {
    _isOfficialTab = value;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void selectConfig(String id) {
    _selectedConfigId = id;
    notifyListeners();
  }

  void addConfig(ConfigItem item) {
    if (item.isOfficial) {
      _configs.add(item);
    } else {
      _myConfigs.add(item);
    }
    notifyListeners();
  }

  /// Synchronize remote JSON configuration from Laravel Backend
  Future<bool> syncWithBackend({bool silent = false}) async {
    if (!silent) {
      _isLoading = true;
      notifyListeners();
    }

    try {
      final res = await VpnApiService.fetchRemoteConfig();
      if (res != null && res['success'] == true && res['data'] != null) {
        final data = res['data'] as Map<String, dynamic>;

        _configVersion = data['config_version'] as int? ?? _configVersion;
        _appName = data['app_name'] as String? ?? _appName;
        _announcement = data['announcement'] as String?;
        _maintenanceMode = data['maintenance_mode'] as bool? ?? false;
        _features = (data['features'] as Map<String, dynamic>?) ?? {};
        _credentials = (data['credentials'] as Map<String, dynamic>?) ?? {};
        _ads = (data['ads'] as Map<String, dynamic>?) ?? {};

        _privacyPolicyUrl = data['privacy_policy_url'] as String? ?? _privacyPolicyUrl;
        _termsUrl = data['terms_url'] as String? ?? _termsUrl;
        _privacyPolicy = data['privacy_policy'] as String? ?? _privacyPolicy;
        _termsConditions = data['terms_conditions'] as String? ?? _termsConditions;

        if (data['theme'] != null && data['theme']['primary_color'] != null) {
          final hex = data['theme']['primary_color'].toString().replaceAll('#', '');
          if (hex.length == 6) {
            _primaryThemeColor = Color(int.parse('FF$hex', radix: 16));
          }
          _themeDarkMode = data['theme']['dark_mode'] as bool? ?? false;
        }

        if (data['developer'] != null) {
          _developerName = data['developer']['name'] as String? ?? _developerName;
          _developerFacebook = data['developer']['facebook_url'] as String? ?? _developerFacebook;
        }

        if (data['contact'] != null) {
          _adminWhatsapp = data['contact']['whatsapp'] as String? ?? _adminWhatsapp;
          _adminTelegram = data['contact']['telegram'] as String? ?? _adminTelegram;
          _adminEmail = data['contact']['email'] as String? ?? _adminEmail;
        }

        final serversList = data['servers'] as List<dynamic>?;
        if (serversList != null && serversList.isNotEmpty) {
          // Remove old remote nodes, retain custom ones
          _configs.removeWhere((c) => c.isOfficial);

          for (final s in serversList) {
            final serverMap = s as Map<String, dynamic>;
            final flag = serverMap['flag_emoji'] as String? ?? '🌐';
            final country = serverMap['country'] as String? ?? 'VPN';
            final name = serverMap['name'] as String? ?? 'Server';
            final protocol = serverMap['protocol'] as String? ?? 'OPENVPN WS';

            _configs.add(ConfigItem(
              id: 'server_${serverMap['id']}',
              name: '$flag $name',
              group: '$country NODES',
              tags: [protocol, 'Port ${serverMap['port'] ?? 443}'],
              iconType: ConfigIconType.custom,
              pingMs: serverMap['ping_ms'] as int? ?? 120,
              isOfficial: true,
              protocol: protocol,
              serverAddress: serverMap['hostname'] as String? ?? (serverMap['ip_address'] as String? ?? ''),
              port: serverMap['port'] as int? ?? 443,
            ));
          }

          if (_configs.isNotEmpty) {
            _selectedConfigId = _configs.first.id;
          }
        }

        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Sync error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }
}
