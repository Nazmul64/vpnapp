enum ConfigIconType {
  imo,
  robi,
  ryze,
  custom,
}

class ConfigItem {
  final String id;
  final String name;
  final String group;
  final List<String> tags;
  final ConfigIconType iconType;
  final int pingMs;
  final bool isOfficial;
  final String serverAddress;
  final int port;
  final String protocol;
  final String payload;
  final String sniHost;

  const ConfigItem({
    required this.id,
    required this.name,
    required this.group,
    required this.tags,
    required this.iconType,
    this.pingMs = 230,
    this.isOfficial = true,
    this.serverAddress = 'sg-1.senseitunnel.net',
    this.port = 443,
    this.protocol = 'SSH',
    this.payload = 'GET / HTTP/1.1[crlf]Host: [host][crlf]Upgrade: websocket[crlf][crlf]',
    this.sniHost = 'm.facebook.com',
  });

  ConfigItem copyWith({
    String? id,
    String? name,
    String? group,
    List<String>? tags,
    ConfigIconType? iconType,
    int? pingMs,
    bool? isOfficial,
    String? serverAddress,
    int? port,
    String? protocol,
    String? payload,
    String? sniHost,
  }) {
    return ConfigItem(
      id: id ?? this.id,
      name: name ?? this.name,
      group: group ?? this.group,
      tags: tags ?? this.tags,
      iconType: iconType ?? this.iconType,
      pingMs: pingMs ?? this.pingMs,
      isOfficial: isOfficial ?? this.isOfficial,
      serverAddress: serverAddress ?? this.serverAddress,
      port: port ?? this.port,
      protocol: protocol ?? this.protocol,
      payload: payload ?? this.payload,
      sniHost: sniHost ?? this.sniHost,
    );
  }
}
