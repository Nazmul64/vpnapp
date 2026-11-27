import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class VpnApiService {
  // Common backend hosts (Primary Live Production API Server & local fallbacks)
  static const List<String> candidateBaseUrls = [
    'https://mktunnelvpn.xyz',   // Official Live Production API Server
    'http://127.0.0.1:8000',     // Local machine / Desktop / Chrome Web test
    'http://localhost:8000',     // Localhost fallback
    'http://10.0.2.2:8000',      // Android Emulator host loopback
  ];

  static String activeBaseUrl = candidateBaseUrls[0];
  static String deviceHwid = 'MK-982A-44B1-FE29-8802';
  static String apiKey = 'mk_vpn_live_api_key_2026';

  /// Set custom API host
  static void setBaseUrl(String url) {
    if (url.endsWith('/')) {
      activeBaseUrl = url.substring(0, url.length - 1);
    } else {
      activeBaseUrl = url;
    }
  }

  /// Generic GET request with timeout and candidate fallbacks
  static Future<Map<String, dynamic>?> get(String path) async {
    final urlsToTry = [
      activeBaseUrl,
      ...candidateBaseUrls.where((u) => u != activeBaseUrl),
    ];

    for (final baseUrl in urlsToTry) {
      try {
        final uri = Uri.parse('$baseUrl$path');
        final response = await http.get(
          uri,
          headers: {
            'Accept': 'application/json',
            'X-API-KEY': apiKey,
            'X-HWID': deviceHwid,
          },
        ).timeout(const Duration(seconds: 4));

        if (response.statusCode >= 200 && response.statusCode < 300) {
          activeBaseUrl = baseUrl;
          return jsonDecode(response.body) as Map<String, dynamic>;
        }
      } catch (_) {
        continue;
      }
    }

    return null;
  }

  /// Generic POST request with headers
  static Future<Map<String, dynamic>?> post(String path, Map<String, dynamic> data) async {
    final urlsToTry = [
      activeBaseUrl,
      ...candidateBaseUrls.where((u) => u != activeBaseUrl),
    ];

    for (final baseUrl in urlsToTry) {
      try {
        final uri = Uri.parse('$baseUrl$path');
        final response = await http.post(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'X-API-KEY': apiKey,
            'X-HWID': deviceHwid,
          },
          body: jsonEncode(data),
        ).timeout(const Duration(seconds: 5));

        if (response.body.isNotEmpty) {
          activeBaseUrl = baseUrl;
          return jsonDecode(response.body) as Map<String, dynamic>;
        }
      } catch (_) {
        continue;
      }
    }

    return null;
  }

  // --- CORE SYSTEM CALLS ---
  static Future<Map<String, dynamic>?> fetchRemoteConfig() async => get('/api/v1/mobile/config');
  static Future<List<Map<String, dynamic>>?> fetchServers() async {
    final res = await get('/api/v1/mobile/servers');
    if (res != null && res['success'] == true && res['servers'] != null) {
      return List<Map<String, dynamic>>.from(res['servers']);
    }
    return null;
  }

  // --- DRAWER FEATURES & TOOLS APIs ---

  /// 1. Test Server Connectivity (POST /api/v1/tools/test-server)
  static Future<Map<String, dynamic>?> testServer(String ip, int port, {String protocol = 'TCP'}) async {
    return await post('/api/v1/tools/test-server', {
      'ip': ip,
      'port': port,
      'protocol': protocol,
    });
  }

  /// 1. Custom Servers Sync (POST & GET /api/v1/user/custom-servers)
  static Future<Map<String, dynamic>?> saveCustomServer(Map<String, dynamic> serverData) async {
    serverData['hwid'] = deviceHwid;
    return await post('/api/v1/user/custom-servers', serverData);
  }

  static Future<List<Map<String, dynamic>>> fetchCustomServers() async {
    final res = await get('/api/v1/user/custom-servers?hwid=$deviceHwid');
    if (res != null && res['status'] == true && res['data'] != null) {
      return List<Map<String, dynamic>>.from(res['data']);
    }
    return [];
  }

  /// 2. Config Encrypt & Decrypt (POST /api/v1/config/encrypt & decrypt)
  static Future<Map<String, dynamic>?> encryptConfig(Map<String, dynamic> payload) async {
    return await post('/api/v1/config/encrypt', payload);
  }

  static Future<Map<String, dynamic>?> decryptConfig(String encryptedData) async {
    return await post('/api/v1/config/decrypt', {
      'encrypted_data': encryptedData,
      'hwid': deviceHwid,
    });
  }

  /// 3. Redeem Time Voucher (POST /api/v1/voucher/redeem)
  static Future<Map<String, dynamic>?> redeemVoucher(String voucherCode) async {
    return await post('/api/v1/voucher/redeem', {
      'hwid': deviceHwid,
      'voucher_code': voucherCode.trim(),
    });
  }

  /// 3. Add Rewarded Ad Time (POST /api/v1/voucher/add-ad-time)
  static Future<Map<String, dynamic>?> addAdTime({int minutes = 120}) async {
    return await post('/api/v1/voucher/add-ad-time', {
      'hwid': deviceHwid,
      'minutes': minutes,
    });
  }

  /// 4. Register Device & Verify Status (POST /api/v1/device/register)
  static Future<Map<String, dynamic>?> registerDevice({String model = 'Android Phone', String os = 'Android 14'}) async {
    return await post('/api/v1/device/register', {
      'hwid': deviceHwid,
      'model': model,
      'os': os,
    });
  }

  /// 5. Beginner Tutorials (GET /api/v1/tutorials)
  static Future<List<Map<String, dynamic>>> fetchTutorials() async {
    final res = await get('/api/v1/tutorials');
    if (res != null && res['status'] == true && res['data'] != null) {
      return List<Map<String, dynamic>>.from(res['data']);
    }
    return [];
  }

  /// 6. IP Address Checker (GET /api/v1/tools/ip-info)
  static Future<Map<String, dynamic>?> fetchIpInfo() async {
    final res = await get('/api/v1/tools/ip-info');
    if (res != null && res['status'] == true && res['data'] != null) {
      return Map<String, dynamic>.from(res['data']);
    }
    return null;
  }

  /// 7. HostName Finder (POST /api/v1/tools/hostname-lookup)
  static Future<Map<String, dynamic>?> lookupHostname(String domainOrIp) async {
    return await post('/api/v1/tools/hostname-lookup', {
      'domain_or_ip': domainOrIp.trim(),
    });
  }

  /// 8. SlowDNS Resolvers (GET /api/v1/tools/slowdns-list)
  static Future<List<Map<String, dynamic>>> fetchSlowDnsList() async {
    final res = await get('/api/v1/tools/slowdns-list');
    if (res != null && res['status'] == true && res['data'] != null) {
      return List<Map<String, dynamic>>.from(res['data']);
    }
    return [];
  }

  /// 9. Mobile IP Hunter Presets (GET /api/v1/tools/ip-hunter-presets)
  static Future<List<Map<String, dynamic>>> fetchIpHunterPresets() async {
    final res = await get('/api/v1/tools/ip-hunter-presets');
    if (res != null && res['status'] == true && res['data'] != null) {
      return List<Map<String, dynamic>>.from(res['data']);
    }
    return [];
  }

  /// 10. Protocols & V2Ray/OpenVPN Settings (GET /api/v1/settings/protocols)
  static Future<Map<String, dynamic>?> fetchProtocolSettings() async {
    final res = await get('/api/v1/settings/protocols');
    if (res != null && res['status'] == true && res['data'] != null) {
      return Map<String, dynamic>.from(res['data']);
    }
    return null;
  }

  /// 13. Theme Settings (GET /api/v1/settings/theme)
  static Future<Map<String, dynamic>?> fetchThemeSettings() async {
    final res = await get('/api/v1/settings/theme');
    if (res != null && res['status'] == true && res['data'] != null) {
      return Map<String, dynamic>.from(res['data']);
    }
    return null;
  }
}
