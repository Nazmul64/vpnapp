import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/traffic_stats.dart';
import '../models/log_entry.dart';
import '../models/network_payload.dart';
import '../models/server_protocol.dart';
import '../models/custom_configuration_model.dart';
import '../services/vpn_platform_service.dart';

enum VpnState {
  disconnected,
  connecting,
  connected,
  disconnecting,
}

class VpnProvider extends ChangeNotifier {
  VpnState _state = VpnState.disconnected;
  
  // Exact initial time matching the user's screenshot: 00h:19m:16s
  Duration _timeLeft = const Duration(hours: 0, minutes: 19, seconds: 16);
  
  // 0 KB/s when disconnected as in screenshot
  double _uploadMb = 0.0;
  double _downloadMb = 0.0;
  double _uploadSpeedKb = 0.0;
  double _downloadSpeedKb = 0.0;

  String _currentNetwork = 'Grameenphone [BD]';
  bool _customSetupEnabled = false;
  String _customPayloadTitle = 'Custom Setup Enabled: HTTP > DIRECT';
  String _customPayloadSubtitle = 'Tap to create your own setup';
  String _customPayloadString = 'CONNECT [host_port] HTTP/1.1[crlf]Host: mobily.com.sa[crlf]Connection: Keep-Alive[crlf][crlf]';
  CustomConfigurationModel _activeCustomConfig = CustomConfigurationModel();

  late NetworkPayload _selectedPayload;
  late ServerProtocol _selectedProtocol;

  final List<LogEntry> _logs = [];
  Timer? _countdownTimer;
  Timer? _speedTimer;
  final Random _random = Random();

  VpnProvider() {
    _selectedProtocol = ServerProtocol.allProtocols[0]; // Auto Select Server
    _selectedPayload = NetworkPayload.allPayloads[0];
    _initInitialLogs();
    _startTimers();
    refreshNetworkInfo();
  }

  VpnState get state => _state;
  bool get isConnected => _state == VpnState.connected;
  bool get isConnecting => _state == VpnState.connecting;
  bool get isAutoServer => _selectedProtocol.id == 'auto_select';
  Duration get connectedDuration => const Duration(hours: 2, minutes: 11, seconds: 55);
  TrafficStats get stats => TrafficStats(downloadKbps: _downloadSpeedKb, uploadKbps: _uploadSpeedKb, pingMs: 65);
  Duration get timeLeft => _timeLeft;
  double get uploadMb => _uploadMb;
  double get downloadMb => _downloadMb;
  double get uploadSpeedKb => _uploadSpeedKb;
  double get downloadSpeedKb => _downloadSpeedKb;
  String get currentNetwork => _currentNetwork;
  bool get customSetupEnabled => _customSetupEnabled;
  String get customPayloadTitle => _customPayloadTitle;
  String get customPayloadSubtitle => _customPayloadSubtitle;
  String get customPayloadString => _customPayloadString;
  CustomConfigurationModel get activeCustomConfig => _activeCustomConfig;
  NetworkPayload get selectedPayload => _selectedPayload;
  ServerProtocol get selectedProtocol => _selectedProtocol;
  List<LogEntry> get logs => List.unmodifiable(_logs);

  void setActiveCustomConfig(CustomConfigurationModel config) {
    _activeCustomConfig = config;
    _customPayloadTitle = 'Custom Setup Enabled: ${config.protocolLabel}';
    _customPayloadSubtitle = 'Host: ${config.urlHost.isNotEmpty ? config.urlHost : "Direct"} | Tap to customize';
    _customPayloadString = config.payload;
    _customSetupEnabled = true;
    _logs.insert(
      0,
      LogEntry(
        timestamp: DateTime.now(),
        tag: 'CUSTOM SETUP',
        message: 'Active config set: "${config.name}" [${config.protocolLabel}]',
        level: LogLevel.success,
      ),
    );
    notifyListeners();
  }

  void applyCustomPayload({
    required String title,
    required String subtitle,
    required String payload,
  }) {
    _customPayloadTitle = title;
    _customPayloadSubtitle = subtitle;
    _customPayloadString = payload;
    _customSetupEnabled = true;
    _logs.insert(
      0,
      LogEntry(
        timestamp: DateTime.now(),
        tag: 'PAYLOAD',
        message: 'Applied $title',
        level: LogLevel.success,
      ),
    );
    notifyListeners();
  }

  String get formattedTimeLeft {
    final hours = _timeLeft.inHours.toString().padLeft(2, '0');
    final minutes = (_timeLeft.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (_timeLeft.inSeconds % 60).toString().padLeft(2, '0');
    return '${hours}h:${minutes}m:${seconds}s';
  }

  String get formattedUploadTraffic {
    if (_state == VpnState.disconnected) return '0 KB/s';
    return '${_uploadSpeedKb.toStringAsFixed(0)} KB/s';
  }

  String get formattedDownloadTraffic {
    if (_state == VpnState.disconnected) return '0 KB/s';
    return '${_downloadSpeedKb.toStringAsFixed(0)} KB/s';
  }

  String get formattedUploadSpeed {
    if (!isConnected) return '0.00 KB';
    return '${_uploadSpeedKb.toStringAsFixed(2)} KB';
  }

  String get formattedDownloadSpeed {
    if (!isConnected) return '0.00 KB';
    return '${_downloadSpeedKb.toStringAsFixed(2)} KB';
  }

  Future<void> refreshNetworkInfo() async {
    try {
      final info = await VpnPlatformService.getNetworkInfo();
      if (info.isNotEmpty) {
        _currentNetwork = info;
        notifyListeners();
      }
    } catch (_) {}
  }

  void _initInitialLogs() {
    final now = DateTime.now();
    _logs.clear();
    _logs.addAll([
      LogEntry(
        timestamp: now,
        tag: 'CORE',
        message: 'MK Tunnel VPN Core Engine v1.2.89 Initialized',
        level: LogLevel.info,
      ),
      LogEntry(
        timestamp: now,
        tag: 'CARRIER',
        message: 'Detected Mobile Network: $_currentNetwork',
        level: LogLevel.info,
      ),
      LogEntry(
        timestamp: now,
        tag: 'SERVER',
        message: 'Auto Select Server mode active -> Contabo Cloud Node 1 (89.116.28.187:443)',
        level: LogLevel.info,
      ),
    ]);
  }

  void clearAppData() {
    _logs.clear();
    _timeLeft = const Duration(hours: 0, minutes: 19, seconds: 16);
    _uploadMb = 0.0;
    _downloadMb = 0.0;
    _uploadSpeedKb = 0.0;
    _downloadSpeedKb = 0.0;
    _customSetupEnabled = false;
    _activeCustomConfig = CustomConfigurationModel();
    _state = VpnState.disconnected;
    _initInitialLogs();
    notifyListeners();
  }

  void _startTimers() {
    _countdownTimer?.cancel();
    _speedTimer?.cancel();

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_state == VpnState.connected) {
        if (_timeLeft.inSeconds > 0) {
          _timeLeft = _timeLeft - const Duration(seconds: 1);
          // Gently increment traffic statistics as time passes
          _uploadMb += 0.003;
          _downloadMb += 0.008;
          notifyListeners();
        } else {
          disconnect();
        }
      }
    });

    _speedTimer = Timer.periodic(const Duration(milliseconds: 1600), (timer) {
      if (_state == VpnState.connected) {
        _uploadSpeedKb = 20.0 + _random.nextDouble() * 12.0;
        _downloadSpeedKb = 45.0 + _random.nextDouble() * 20.0;
        notifyListeners();
      }
    });
  }

  void addFiveHours() {
    _timeLeft = _timeLeft + const Duration(hours: 5);
    _logs.insert(
      0,
      LogEntry(
        timestamp: DateTime.now(),
        tag: 'REWARD',
        message: '+5 Hours voucher applied! New time: $formattedTimeLeft',
        level: LogLevel.success,
      ),
    );
    notifyListeners();
  }

  void addTwoHours() {
    _timeLeft = _timeLeft + const Duration(hours: 2);
    _logs.insert(
      0,
      LogEntry(
        timestamp: DateTime.now(),
        tag: 'REWARD',
        message: '+2 Hours voucher applied! New time: $formattedTimeLeft',
        level: LogLevel.success,
      ),
    );
    notifyListeners();
  }

  void addMinutes(int minutes) {
    _timeLeft = _timeLeft + Duration(minutes: minutes);
    _logs.insert(
      0,
      LogEntry(
        timestamp: DateTime.now(),
        tag: 'REWARD',
        message: '+$minutes Minutes voucher applied! New time: $formattedTimeLeft',
        level: LogLevel.success,
      ),
    );
    notifyListeners();
  }

  void setCustomSetup(bool value) {
    _customSetupEnabled = value;
    notifyListeners();
  }

  void selectPayload(NetworkPayload payload) {
    _selectedPayload = payload;
    _logs.insert(
      0,
      LogEntry(
        timestamp: DateTime.now(),
        tag: 'PAYLOAD',
        message: 'Selected payload: ${payload.name}',
        level: LogLevel.info,
      ),
    );
    notifyListeners();
  }

  void selectProtocol(ServerProtocol protocol) {
    _selectedProtocol = protocol;
    _logs.insert(
      0,
      LogEntry(
        timestamp: DateTime.now(),
        tag: 'PROTOCOL',
        message: 'Switched server/protocol: ${protocol.title} (${protocol.badge})',
        level: LogLevel.info,
      ),
    );
    notifyListeners();
  }

  Future<void> toggleConnection() async {
    if (_state == VpnState.connected) {
      await disconnect();
    } else if (_state == VpnState.disconnected) {
      await connect();
    }
  }

  Future<void> connect() async {
    if (_state == VpnState.connected || _state == VpnState.connecting) return;

    _state = VpnState.connecting;
    notifyListeners();

    _logs.insert(
      0,
      LogEntry(
        timestamp: DateTime.now(),
        tag: 'TUNNEL',
        message: 'Requesting VPN tunnel authorization and establishing interface...',
        level: LogLevel.info,
      ),
    );

    // Request Android system VPN authorization
    final prepared = await VpnPlatformService.prepareVpn();
    if (!prepared) {
      _state = VpnState.disconnected;
      _logs.insert(
        0,
        LogEntry(
          timestamp: DateTime.now(),
          tag: 'TUNNEL',
          message: 'VPN authorization canceled by user',
          level: LogLevel.warning,
        ),
      );
      notifyListeners();
      return;
    }

    // Start native Android VpnService (which activates the system [VPN] key icon in the status bar)
    await VpnPlatformService.startVpn();
    await refreshNetworkInfo();

    if (_customSetupEnabled) {
      _logs.insert(
        0,
        LogEntry(
          timestamp: DateTime.now(),
          tag: 'CUSTOM SETUP',
          message: 'Applying custom tunnel payload (${_activeCustomConfig.protocolLabel}) -> ${_activeCustomConfig.urlHost.isNotEmpty ? _activeCustomConfig.urlHost : "direct"}...',
          level: LogLevel.info,
        ),
      );
    }

    await Future.delayed(const Duration(milliseconds: 1000));

    _state = VpnState.connected;
    _uploadSpeedKb = 24.29;
    _downloadSpeedKb = 52.18;
    
    _logs.insert(
      0,
      LogEntry(
        timestamp: DateTime.now(),
        tag: 'TUNNEL',
        message: 'Connected Successfully 😍 [${_selectedProtocol.badge} via $_currentNetwork] - Status Bar Key Active',
        level: LogLevel.success,
      ),
    );

    notifyListeners();
  }

  Future<void> disconnect() async {
    _state = VpnState.disconnected;
    _uploadSpeedKb = 0.0;
    _downloadSpeedKb = 0.0;

    // Stop native Android VpnService (removes system [VPN] key icon)
    await VpnPlatformService.stopVpn();

    _logs.insert(
      0,
      LogEntry(
        timestamp: DateTime.now(),
        tag: 'TUNNEL',
        message: 'VPN Tunnel Disconnected by user',
        level: LogLevel.warning,
      ),
    );

    notifyListeners();
  }

  void clearLogs() {
    _logs.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _speedTimer?.cancel();
    super.dispose();
  }
}
