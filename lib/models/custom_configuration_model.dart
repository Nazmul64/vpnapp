import 'dart:convert';

class CustomConfigurationModel {
  final int? id;
  String name;
  String protocol; // http_direct, http_proxy, openvpn_ws, ssh_ws, etc.
  String payloadMode; // normal, split, direct
  String payload;
  String serverDnsMode; // websocket, normal, ssl, direct, auto
  String urlHost;
  String requestMethod; // CONNECT, GET, POST, HEAD, PUT, etc.
  String injectionMethod; // normal, front_inject, back_inject, split

  // Options
  bool rotateEnabled;
  bool frontQueryEnabled;
  bool backQueryEnabled;
  bool onlineHostEnabled;
  bool forwardHostEnabled;
  bool reverseProxyEnabled;
  bool keepAliveEnabled;
  bool userAgentEnabled;
  String? userAgentValue;
  bool refererEnabled;
  String? refererValue;
  bool rawEnabled;
  bool dualConnectEnabled;
  bool isActive;

  // Optional Proxy
  String? proxyType;
  String? proxyHost;
  int? proxyPort;
  String? proxyUsername;

  CustomConfigurationModel({
    this.id,
    this.name = 'My Custom Setup',
    this.protocol = 'http_direct',
    this.payloadMode = 'normal',
    this.payload = 'CONNECT [host_port] HTTP/1.1[crlf]Host: [host][crlf]Connection: Keep-Alive[crlf][crlf]',
    this.serverDnsMode = 'websocket',
    this.urlHost = 'mobily.com.sa',
    this.requestMethod = 'CONNECT',
    this.injectionMethod = 'normal',
    this.rotateEnabled = false,
    this.frontQueryEnabled = false,
    this.backQueryEnabled = false,
    this.onlineHostEnabled = true,
    this.forwardHostEnabled = false,
    this.reverseProxyEnabled = false,
    this.keepAliveEnabled = true,
    this.userAgentEnabled = true,
    this.userAgentValue,
    this.refererEnabled = false,
    this.refererValue,
    this.rawEnabled = false,
    this.dualConnectEnabled = false,
    this.isActive = true,
    this.proxyType,
    this.proxyHost,
    this.proxyPort,
    this.proxyUsername,
  });

  String get protocolLabel {
    switch (protocol) {
      case 'http_direct':
        return 'HTTP > DIRECT';
      case 'http_proxy':
        return 'HTTP > PROXY';
      case 'openvpn_ws':
        return 'OpenVPN > WebSocket';
      case 'ssh_ws':
        return 'SSH > WebSocket';
      case 'ssl_ws':
        return 'SSL > WebSocket';
      case 'ssl_direct':
        return 'SSL/TLS > DIRECT';
      case 'openvpn_direct':
        return 'OpenVPN > DIRECT';
      default:
        return protocol.toUpperCase().replaceAll('_', ' > ');
    }
  }

  factory CustomConfigurationModel.fromJson(Map<String, dynamic> json) {
    final opts = json['options'] as Map<String, dynamic>? ?? {};
    final proxy = json['proxy'] as Map<String, dynamic>?;

    return CustomConfigurationModel(
      id: json['id'] as int?,
      name: json['name'] as String? ?? 'Custom Setup',
      protocol: json['protocol'] as String? ?? 'http_direct',
      payloadMode: json['payload_mode'] as String? ?? 'normal',
      payload: json['payload'] as String? ?? '',
      serverDnsMode: json['server_dns_mode'] as String? ?? 'websocket',
      urlHost: json['url_host'] as String? ?? 'mobily.com.sa',
      requestMethod: json['request_method'] as String? ?? 'CONNECT',
      injectionMethod: json['injection_method'] as String? ?? 'normal',
      rotateEnabled: (opts['rotate_enabled'] ?? json['rotate_enabled']) as bool? ?? false,
      frontQueryEnabled: (opts['front_query_enabled'] ?? json['front_query_enabled']) as bool? ?? false,
      backQueryEnabled: (opts['back_query_enabled'] ?? json['back_query_enabled']) as bool? ?? false,
      onlineHostEnabled: (opts['online_host_enabled'] ?? json['online_host_enabled']) as bool? ?? true,
      forwardHostEnabled: (opts['forward_host_enabled'] ?? json['forward_host_enabled']) as bool? ?? false,
      reverseProxyEnabled: (opts['reverse_proxy_enabled'] ?? json['reverse_proxy_enabled']) as bool? ?? false,
      keepAliveEnabled: (opts['keep_alive_enabled'] ?? json['keep_alive_enabled']) as bool? ?? true,
      userAgentEnabled: (opts['user_agent_enabled'] ?? json['user_agent_enabled']) as bool? ?? true,
      userAgentValue: (opts['user_agent_value'] ?? json['user_agent_value']) as String?,
      refererEnabled: (opts['referer_enabled'] ?? json['referer_enabled']) as bool? ?? false,
      refererValue: (opts['referer_value'] ?? json['referer_value']) as String?,
      rawEnabled: (opts['raw_enabled'] ?? json['raw_enabled']) as bool? ?? false,
      dualConnectEnabled: (opts['dual_connect_enabled'] ?? json['dual_connect_enabled']) as bool? ?? false,
      isActive: json['is_active'] as bool? ?? false,
      proxyType: proxy?['proxy_type'] as String?,
      proxyHost: proxy?['proxy_host'] as String?,
      proxyPort: proxy?['proxy_port'] as int?,
      proxyUsername: proxy?['username'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'protocol': protocol,
      'payload_mode': payloadMode,
      'payload': payload,
      'server_dns_mode': serverDnsMode,
      'url_host': urlHost,
      'request_method': requestMethod,
      'injection_method': injectionMethod,
      'rotate_enabled': rotateEnabled,
      'front_query_enabled': frontQueryEnabled,
      'back_query_enabled': backQueryEnabled,
      'online_host_enabled': onlineHostEnabled,
      'forward_host_enabled': forwardHostEnabled,
      'reverse_proxy_enabled': reverseProxyEnabled,
      'keep_alive_enabled': keepAliveEnabled,
      'user_agent_enabled': userAgentEnabled,
      'user_agent_value': userAgentValue,
      'referer_enabled': refererEnabled,
      'referer_value': refererValue,
      'raw_enabled': rawEnabled,
      'dual_connect_enabled': dualConnectEnabled,
      'is_active': isActive,
      if (proxyHost != null && proxyHost!.isNotEmpty)
        'proxy': {
          'proxy_type': proxyType ?? 'http',
          'proxy_host': proxyHost,
          'proxy_port': proxyPort ?? 8080,
          'username': proxyUsername,
        },
    };
  }

  /// Exports sanitized JSON for QR code sharing (no credentials)
  String toShareString() {
    final map = {
      'version': 1,
      'type': 'custom_vpn_config',
      'name': name,
      'protocol': protocol,
      'payload_mode': payloadMode,
      'request_method': requestMethod,
      'injection_method': injectionMethod,
      'url_host': urlHost,
      'payload': payload,
      'server_dns_mode': serverDnsMode,
      'proxy': proxyHost != null && proxyHost!.isNotEmpty
          ? {
              'proxy_type': proxyType ?? 'http',
              'proxy_host': proxyHost,
              'proxy_port': proxyPort ?? 8080,
            }
          : null,
      'options': {
        'rotate': rotateEnabled,
        'front_query': frontQueryEnabled,
        'back_query': backQueryEnabled,
        'online_host': onlineHostEnabled,
        'forward_host': forwardHostEnabled,
        'reverse_proxy': reverseProxyEnabled,
        'keep_alive': keepAliveEnabled,
        'user_agent': userAgentEnabled,
        'referer': refererEnabled,
        'raw': rawEnabled,
        'dual_connect': dualConnectEnabled,
      },
    };

    return 'MKCONFIG::${base64Encode(utf8.encode(jsonEncode(map)))}';
  }

  /// Parses sanitized QR code or JSON string
  static CustomConfigurationModel? fromShareString(String raw) {
    try {
      var cleaned = raw.trim();
      if (cleaned.startsWith('MKCONFIG::')) {
        cleaned = cleaned.substring(10);
      }

      String jsonString;
      try {
        jsonString = utf8.decode(base64Decode(cleaned));
      } catch (_) {
        jsonString = cleaned;
      }

      final map = jsonDecode(jsonString) as Map<String, dynamic>;
      if (map['type'] != 'custom_vpn_config') return null;

      final opts = map['options'] as Map<String, dynamic>? ?? {};
      final proxy = map['proxy'] as Map<String, dynamic>?;

      return CustomConfigurationModel(
        name: '${map['name'] ?? 'Imported Setup'} (Imported)',
        protocol: map['protocol'] as String? ?? 'http_direct',
        payloadMode: map['payload_mode'] as String? ?? 'normal',
        payload: map['payload'] as String? ?? '',
        serverDnsMode: map['server_dns_mode'] as String? ?? 'websocket',
        urlHost: map['url_host'] as String? ?? 'mobily.com.sa',
        requestMethod: map['request_method'] as String? ?? 'CONNECT',
        injectionMethod: map['injection_method'] as String? ?? 'normal',
        rotateEnabled: opts['rotate'] as bool? ?? false,
        frontQueryEnabled: opts['front_query'] as bool? ?? false,
        backQueryEnabled: opts['back_query'] as bool? ?? false,
        onlineHostEnabled: opts['online_host'] as bool? ?? true,
        forwardHostEnabled: opts['forward_host'] as bool? ?? false,
        reverseProxyEnabled: opts['reverse_proxy'] as bool? ?? false,
        keepAliveEnabled: opts['keep_alive'] as bool? ?? true,
        userAgentEnabled: opts['user_agent'] as bool? ?? true,
        refererEnabled: opts['referer'] as bool? ?? false,
        rawEnabled: opts['raw'] as bool? ?? false,
        dualConnectEnabled: opts['dual_connect'] as bool? ?? false,
        isActive: true,
        proxyType: proxy?['proxy_type'] as String?,
        proxyHost: proxy?['proxy_host'] as String?,
        proxyPort: proxy?['proxy_port'] as int?,
      );
    } catch (_) {
      return null;
    }
  }
}
