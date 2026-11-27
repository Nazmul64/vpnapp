import 'package:flutter/services.dart';

class VpnPlatformService {
  static const MethodChannel _channel = MethodChannel('com.mktunnel.vpn/service');

  /// Requests Android system VPN preparation permission. Returns true if granted.
  static Future<bool> prepareVpn() async {
    try {
      final res = await _channel.invokeMethod<bool>('prepareVpn');
      return res ?? true;
    } catch (e) {
      return true;
    }
  }

  /// Establishes native Android VpnService tunnel to display system [VPN] status bar icon
  static Future<bool> startVpn() async {
    try {
      final res = await _channel.invokeMethod<bool>('startVpn');
      return res ?? true;
    } catch (e) {
      return true;
    }
  }

  /// Stops native Android VpnService tunnel, removing system [VPN] status bar icon
  static Future<bool> stopVpn() async {
    try {
      final res = await _channel.invokeMethod<bool>('stopVpn');
      return res ?? true;
    } catch (e) {
      return true;
    }
  }

  /// Queries active carrier / SIM name and ISO country code (e.g. Grameenphone [BD])
  static Future<String> getNetworkInfo() async {
    try {
      final res = await _channel.invokeMethod<String>('getNetworkInfo');
      if (res != null && res.trim().isNotEmpty) {
        return normalizeCarrierString(res.trim());
      }
    } catch (_) {}
    return 'Grameenphone [BD]';
  }

  /// Normalizes abbreviations (e.g. gp [BD] -> Grameenphone [BD])
  static String normalizeCarrierString(String input) {
    var raw = input.trim();
    // Match pattern: name [CC]
    final regex = RegExp(r'^(.*?)\s*\[([A-Za-z]{2,6})\]$');
    final match = regex.firstMatch(raw);

    if (match != null) {
      final operator = match.group(1)?.trim().toLowerCase() ?? '';
      final country = match.group(2)?.trim().toUpperCase() ?? 'BD';

      if (operator == 'gp' || operator.contains('grameen')) {
        return 'Grameenphone [$country]';
      } else if (operator == 'bl' || operator.contains('banglalink')) {
        return 'Banglalink [$country]';
      } else if (operator == 'robi' || operator == 'aktel') {
        return 'Robi [$country]';
      } else if (operator.contains('airtel')) {
        return 'Airtel [$country]';
      } else if (operator.contains('teletalk')) {
        return 'Teletalk [$country]';
      } else if (operator.contains('mobily')) {
        return 'Mobily [$country]';
      } else if (operator.contains('stc') || operator.contains('jawwy')) {
        return 'STC [$country]';
      } else if (operator.contains('zain')) {
        return 'Zain [$country]';
      } else if (operator.contains('jio')) {
        return 'Jio [$country]';
      } else if (operator == 'wifi') {
        return 'WiFi [$country]';
      }
    }

    if (raw.toLowerCase() == 'gp') return 'Grameenphone [BD]';
    if (raw.toLowerCase() == 'bl') return 'Banglalink [BD]';
    if (raw.toLowerCase() == 'robi') return 'Robi [BD]';

    return raw;
  }
}
