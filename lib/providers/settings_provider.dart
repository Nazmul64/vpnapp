import 'package:flutter/material.dart';

class SettingsProvider extends ChangeNotifier {
  // Connection Toggles
  bool _wakeLock = true;
  bool _autoReconnect = true;
  bool _killSwitch = false;
  bool _bypassLan = true;

  // Appearance
  bool _isDarkMode = true;
  bool _enableWallpaper = true;
  String _wallpaperMode = 'Grills';

  // Engine Settings
  int _mtu = 1500;
  String _dnsServer = '1.1.1.1';
  String _pingTarget = 'Default';
  String _keepalive = 'Balanced';
  String _splitTunnel = 'Off';
  String _directBlock = 'None';
  String _tlsMux = 'Tuned';

  // Getters
  bool get wakeLock => _wakeLock;
  bool get autoReconnect => _autoReconnect;
  bool get killSwitch => _killSwitch;
  bool get bypassLan => _bypassLan;
  bool get isDarkMode => _isDarkMode;
  bool get enableWallpaper => _enableWallpaper;
  String get wallpaperMode => _wallpaperMode;
  int get mtu => _mtu;
  String get dnsServer => _dnsServer;
  String get pingTarget => _pingTarget;
  String get keepalive => _keepalive;
  String get splitTunnel => _splitTunnel;
  String get directBlock => _directBlock;
  String get tlsMux => _tlsMux;

  // Setters
  void toggleWakeLock() {
    _wakeLock = !_wakeLock;
    notifyListeners();
  }

  void toggleAutoReconnect() {
    _autoReconnect = !_autoReconnect;
    notifyListeners();
  }

  void toggleKillSwitch() {
    _killSwitch = !_killSwitch;
    notifyListeners();
  }

  void toggleBypassLan() {
    _bypassLan = !_bypassLan;
    notifyListeners();
  }

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  void setDarkMode(bool value) {
    _isDarkMode = value;
    notifyListeners();
  }

  void toggleWallpaperMode() {
    _enableWallpaper = !_enableWallpaper;
    _wallpaperMode = _enableWallpaper ? 'Grills' : 'Off';
    notifyListeners();
  }

  void setMtu(int value) {
    _mtu = value;
    notifyListeners();
  }

  void setDnsServer(String value) {
    _dnsServer = value;
    notifyListeners();
  }

  void setKeepalive(String value) {
    _keepalive = value;
    notifyListeners();
  }

  void setTlsMux(String value) {
    _tlsMux = value;
    notifyListeners();
  }

  void setPingTarget(String value) {
    _pingTarget = value;
    notifyListeners();
  }

  void setSplitTunnel(String value) {
    _splitTunnel = value;
    notifyListeners();
  }

  void setDirectBlock(String value) {
    _directBlock = value;
    notifyListeners();
  }
}
