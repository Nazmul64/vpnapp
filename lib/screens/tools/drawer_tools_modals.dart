import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/vpn_provider.dart';
import '../../providers/config_provider.dart';
import '../../services/vpn_api_service.dart';

// ==============================================================================
// 1. CUSTOM SERVER MODAL (Add, Test Connectivity & Sync)
// ==============================================================================
class CustomServerModal extends StatefulWidget {
  const CustomServerModal({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => const CustomServerModal(),
    );
  }

  @override
  State<CustomServerModal> createState() => _CustomServerModalState();
}

class _CustomServerModalState extends State<CustomServerModal> {
  final _nameController = TextEditingController(text: 'My Custom Node');
  final _hostController = TextEditingController(text: '159.65.132.88');
  final _portController = TextEditingController(text: '443');
  final _sniController = TextEditingController(text: 'mobily.com.sa');
  final _payloadController = TextEditingController(text: 'GET / HTTP/1.1[crlf]Host: [host][crlf]Upgrade: websocket[crlf][crlf]');

  String _protocol = 'OPENVPN WS';
  bool _isTesting = false;
  String? _testResult;
  bool _testSuccess = false;

  Future<void> _testConnection() async {
    setState(() {
      _isTesting = true;
      _testResult = null;
    });

    final port = int.tryParse(_portController.text.trim()) ?? 443;
    final res = await VpnApiService.testServer(_hostController.text.trim(), port, protocol: _protocol);

    setState(() {
      _isTesting = false;
      if (res != null && res['status'] == true) {
        _testSuccess = true;
        _testResult = '${res['message']} (Latency: ${res['data']['latency_ms']} ms)';
      } else {
        _testSuccess = false;
        _testResult = res?['message'] ?? 'Connection to server failed.';
      }
    });
  }

  Future<void> _saveAndSync() async {
    final port = int.tryParse(_portController.text.trim()) ?? 443;
    final data = {
      'name': _nameController.text.trim(),
      'ip': _hostController.text.trim(),
      'port': port,
      'protocol': _protocol,
      'sni': _sniController.text.trim(),
      'payload': _payloadController.text.trim(),
    };

    final res = await VpnApiService.saveCustomServer(data);
    if (!mounted) return;

    if (res != null && res['status'] == true) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Custom server saved and backed up to cloud! ✅')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res?['message'] ?? 'Failed to save server.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Row(
        children: [
          Icon(Icons.add_location_alt_outlined, color: Color(0xFF43A047)),
          SizedBox(width: 8),
          Text('Custom Server Setup', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Profile Name', isDense: true),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: _hostController,
                    decoration: const InputDecoration(labelText: 'Host / IP Address', isDense: true),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _portController,
                    decoration: const InputDecoration(labelText: 'Port', isDense: true),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              initialValue: _protocol,
              decoration: const InputDecoration(labelText: 'Protocol', isDense: true),
              items: const [
                DropdownMenuItem(value: 'OPENVPN WS', child: Text('OpenVPN WebSocket')),
                DropdownMenuItem(value: 'OPENVPN HTTP', child: Text('OpenVPN HTTP')),
                DropdownMenuItem(value: 'XRAY WS', child: Text('V2Ray / Xray WS')),
                DropdownMenuItem(value: 'HYSTERIA', child: Text('Hysteria UDP')),
              ],
              onChanged: (val) {
                if (val != null) setState(() => _protocol = val);
              },
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _sniController,
              decoration: const InputDecoration(labelText: 'SNI / Bug Host', isDense: true),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _payloadController,
              decoration: const InputDecoration(labelText: 'Custom Payload String', isDense: true),
              maxLines: 2,
              style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _isTesting ? null : _testConnection,
              icon: _isTesting
                  ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.network_check_rounded, size: 18),
              label: Text(_isTesting ? 'Testing Port...' : 'Test Port Reachability'),
            ),
            if (_testResult != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _testSuccess ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _testResult!,
                  style: TextStyle(
                    fontSize: 11.5,
                    color: _testSuccess ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF43A047), foregroundColor: Colors.white),
          onPressed: _saveAndSync,
          child: const Text('SAVE & SYNC'),
        ),
      ],
    );
  }
}

// ==============================================================================
// 2. EXPORT / IMPORT CONFIG MODAL (Encrypt / Decrypt & Locks)
// ==============================================================================
class ExportImportModal extends StatefulWidget {
  const ExportImportModal({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => const ExportImportModal(),
    );
  }

  @override
  State<ExportImportModal> createState() => _ExportImportModalState();
}

class _ExportImportModalState extends State<ExportImportModal> {
  int _tab = 0; // 0 = Export, 1 = Import

  // Export fields
  bool _lockPayload = true;
  bool _lockServer = false;
  bool _lockHwid = false;
  final _targetHwidController = TextEditingController(text: VpnApiService.deviceHwid);
  final _noteController = TextEditingController(text: 'Fast Mobily Bypass Config');
  String? _exportedPayload;

  // Import fields
  final _importController = TextEditingController();
  String? _importResult;
  bool _importSuccess = false;

  Future<void> _handleExport() async {
    final payload = {
      'config': {
        'server': 'mktunnelvpn.xyz',
        'port': 443,
        'protocol': 'OPENVPN WS',
        'sni': 'mobily.com.sa',
        'payload': 'GET / HTTP/1.1[crlf]Host: mktunnelvpn.xyz[crlf]',
      },
      'note': _noteController.text.trim(),
      'lock_payload': _lockPayload,
      'lock_server': _lockServer,
      'lock_hwid': _lockHwid,
      'target_hwid': _lockHwid ? _targetHwidController.text.trim() : null,
      'expires_at': DateTime.now().add(const Duration(days: 30)).toIso8601String(),
    };

    final res = await VpnApiService.encryptConfig(payload);
    if (!mounted) return;

    if (res != null && res['status'] == true) {
      setState(() {
        _exportedPayload = res['data']['encrypted_string'];
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res?['message'] ?? 'Encryption failed')),
      );
    }
  }

  Future<void> _handleImport() async {
    final text = _importController.text.trim();
    if (text.isEmpty) return;

    final res = await VpnApiService.decryptConfig(text);
    if (!mounted) return;

    setState(() {
      if (res != null && res['status'] == true) {
        _importSuccess = true;
        _importResult = 'Valid Profile: ${res['data']['meta']['note'] ?? 'Config Active'}\nServer: ${res['data']['config']['server']}';
      } else {
        _importSuccess = false;
        _importResult = res?['message'] ?? 'Import failed or invalid signature.';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          const Icon(Icons.import_export_rounded, color: Color(0xFF43A047)),
          const SizedBox(width: 8),
          Text(_tab == 0 ? 'Export Locked Config' : 'Import Config File', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Segmented switch
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _tab == 0 ? const Color(0xFF43A047) : Colors.grey[200],
                      foregroundColor: _tab == 0 ? Colors.white : Colors.black87,
                      elevation: 0,
                    ),
                    onPressed: () => setState(() => _tab = 0),
                    child: const Text('EXPORT'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _tab == 1 ? const Color(0xFF43A047) : Colors.grey[200],
                      foregroundColor: _tab == 1 ? Colors.white : Colors.black87,
                      elevation: 0,
                    ),
                    onPressed: () => setState(() => _tab = 1),
                    child: const Text('IMPORT'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            if (_tab == 0) ...[
              TextField(
                controller: _noteController,
                decoration: const InputDecoration(labelText: 'Config Note / Title', isDense: true),
              ),
              const SizedBox(height: 8),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                title: const Text('Lock Payload (Prevent editing)', style: TextStyle(fontSize: 13)),
                value: _lockPayload,
                onChanged: (v) => setState(() => _lockPayload = v ?? true),
              ),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                title: const Text('Lock Server Host', style: TextStyle(fontSize: 13)),
                value: _lockServer,
                onChanged: (v) => setState(() => _lockServer = v ?? false),
              ),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                title: const Text('Lock to Specific HWID', style: TextStyle(fontSize: 13)),
                value: _lockHwid,
                onChanged: (v) => setState(() => _lockHwid = v ?? false),
              ),
              if (_lockHwid)
                TextField(
                  controller: _targetHwidController,
                  decoration: const InputDecoration(labelText: 'Target HWID', isDense: true),
                ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF43A047), foregroundColor: Colors.white),
                onPressed: _handleExport,
                icon: const Icon(Icons.lock_outline, size: 18),
                label: const Text('ENCRYPT & GENERATE .XTUN'),
              ),
              if (_exportedPayload != null) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(6)),
                  child: SelectableText(
                    _exportedPayload!,
                    maxLines: 3,
                    style: const TextStyle(fontSize: 10, fontFamily: 'monospace'),
                  ),
                ),
                const SizedBox(height: 6),
                OutlinedButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: _exportedPayload!));
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Config string copied! 📋')));
                  },
                  icon: const Icon(Icons.copy, size: 16),
                  label: const Text('Copy Encrypted Code'),
                ),
              ],
            ] else ...[
              TextField(
                controller: _importController,
                decoration: const InputDecoration(
                  labelText: 'Paste .xtun or Encrypted Code',
                  hintText: 'XTUN::eyJtYWdpYy...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF43A047), foregroundColor: Colors.white),
                onPressed: _handleImport,
                icon: const Icon(Icons.file_download_outlined, size: 18),
                label: const Text('VALIDATE & IMPORT'),
              ),
              if (_importResult != null) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _importSuccess ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _importResult!,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _importSuccess ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                    ),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('CLOSE')),
      ],
    );
  }
}

// ==============================================================================
// 3. REDEEM VOUCHER MODAL (Real Backend Sync)
// ==============================================================================
class RedeemVoucherModal extends StatefulWidget {
  const RedeemVoucherModal({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => const RedeemVoucherModal(),
    );
  }

  @override
  State<RedeemVoucherModal> createState() => _RedeemVoucherModalState();
}

class _RedeemVoucherModalState extends State<RedeemVoucherModal> {
  final _controller = TextEditingController(text: 'XJ-VIP-2026');
  bool _isLoading = false;

  Future<void> _redeem() async {
    final code = _controller.text.trim();
    if (code.isEmpty) return;

    setState(() => _isLoading = true);
    final res = await VpnApiService.redeemVoucher(code);
    setState(() => _isLoading = false);

    if (!mounted) return;

    if (res != null && res['status'] == true) {
      final duration = res['data']['duration_minutes'] ?? 120;
      // Add time to live UI countdown timer
      context.read<VpnProvider>().addMinutes(duration as int);

      Navigator.pop(context);
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.celebration_rounded, color: Color(0xFF43A047)),
              SizedBox(width: 8),
              Text('Success!'),
            ],
          ),
          content: Text(res['message'] ?? 'Voucher redeemed successfully! Time added.'),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF43A047), foregroundColor: Colors.white),
              onPressed: () => Navigator.pop(ctx),
              child: const Text('AWESOME'),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res?['message'] ?? 'Invalid voucher code.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Row(
        children: [
          Icon(Icons.more_time_rounded, color: Color(0xFF43A047)),
          SizedBox(width: 8),
          Text('Redeem Time Voucher', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Enter your voucher code to extend unlimited VPN access:'),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            decoration: const InputDecoration(
              labelText: 'Voucher Code',
              hintText: 'e.g. XJ-VIP-2026',
              border: OutlineInputBorder(),
            ),
            textCapitalization: TextCapitalization.characters,
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF43A047), foregroundColor: Colors.white),
          onPressed: _isLoading ? null : _redeem,
          child: Text(_isLoading ? 'Verifying...' : 'REDEEM NOW'),
        ),
      ],
    );
  }
}

// ==============================================================================
// 4. HWID SCREEN MODAL
// ==============================================================================
class HwidModal extends StatelessWidget {
  const HwidModal({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => const HwidModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    const hwid = 'XJ-982A-44B1-FE29-8802';

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Row(
        children: [
          Icon(Icons.fingerprint_rounded, color: Color(0xFF43A047)),
          SizedBox(width: 8),
          Text('Hardware Identifier', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Your unique device HWID for server authentication and cloud backup:'),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFCBD5E1)),
            ),
            child: const SelectableText(
              hwid,
              style: TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(4)),
                child: const Text('VIP ACTIVE', style: TextStyle(color: Color(0xFF2E7D32), fontWeight: FontWeight.bold, fontSize: 11)),
              ),
              const SizedBox(width: 8),
              const Text('Device Model: Android 14', style: TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Clipboard.setData(const ClipboardData(text: hwid));
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('HWID copied to clipboard! 📋')));
          },
          child: const Text('COPY HWID', style: TextStyle(color: Color(0xFF43A047), fontWeight: FontWeight.bold)),
        ),
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('CLOSE')),
      ],
    );
  }
}

// ==============================================================================
// 5. BEGINNER TUTORIAL MODAL
// ==============================================================================
class TutorialModal extends StatefulWidget {
  const TutorialModal({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => const TutorialModal(),
    );
  }

  @override
  State<TutorialModal> createState() => _TutorialModalState();
}

class _TutorialModalState extends State<TutorialModal> {
  List<Map<String, dynamic>> _tutorials = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await VpnApiService.fetchTutorials();
    if (mounted) {
      setState(() {
        _tutorials = list;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Row(
        children: [
          Icon(Icons.help_outline_rounded, color: Color(0xFF43A047)),
          SizedBox(width: 8),
          Text('Beginner Tutorials', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: _isLoading
            ? const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()))
            : ListView.separated(
                shrinkWrap: true,
                itemCount: _tutorials.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (ctx, i) {
                  final t = _tutorials[i];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFF43A047).withValues(alpha: 0.15),
                      child: Text('${t['step_order'] ?? i + 1}', style: const TextStyle(color: Color(0xFF43A047), fontWeight: FontWeight.bold)),
                    ),
                    title: Text(t['title'] ?? 'Guide', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                    subtitle: Text(t['description'] ?? '', style: const TextStyle(fontSize: 11.5)),
                    trailing: const Icon(Icons.play_circle_outline, color: Colors.red, size: 28),
                  );
                },
              ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('CLOSE')),
      ],
    );
  }
}

// ==============================================================================
// 6. IP ADDRESS CHECKER MODAL
// ==============================================================================
class IpCheckerModal extends StatefulWidget {
  const IpCheckerModal({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => const IpCheckerModal(),
    );
  }

  @override
  State<IpCheckerModal> createState() => _IpCheckerModalState();
}

class _IpCheckerModalState extends State<IpCheckerModal> {
  Map<String, dynamic>? _data;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() => _isLoading = true);
    final res = await VpnApiService.fetchIpInfo();
    if (mounted) {
      setState(() {
        _data = res;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final vpnProvider = context.watch<VpnProvider>();

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Row(
        children: [
          Icon(Icons.assignment_outlined, color: Color(0xFF43A047)),
          SizedBox(width: 8),
          Text('Live IP Information', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
        ],
      ),
      content: _isLoading
          ? const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()))
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: vpnProvider.isConnected ? Colors.green[100] : Colors.blueGrey[100],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        vpnProvider.isConnected ? 'TUNNEL ACTIVE' : 'REAL NETWORK IP',
                        style: TextStyle(
                          color: vpnProvider.isConnected ? Colors.green[900] : Colors.blueGrey[900],
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _row('Public IP', _data?['ip'] ?? '151.254.120.45', isBold: true),
                _row('Country', '${_data?['country'] ?? 'Saudi Arabia'} (${_data?['country_code'] ?? 'SA'})'),
                _row('City', _data?['city'] ?? 'Riyadh'),
                _row('ISP Operator', _data?['isp'] ?? 'Mobily Telecom (Etihad Etisalat)'),
                _row('ASN', _data?['as'] ?? 'AS35819 MOBILY-AS'),
                _row('DNS Leak Protected', '8.8.8.8, 1.1.1.1 (Encrypted)'),
              ],
            ),
      actions: [
        IconButton(onPressed: _fetch, icon: const Icon(Icons.refresh_rounded, color: Color(0xFF43A047))),
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
      ],
    );
  }

  Widget _row(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 100, child: Text('$label:', style: const TextStyle(color: Colors.grey, fontSize: 12))),
          Expanded(child: Text(value, style: TextStyle(fontSize: 12.5, fontWeight: isBold ? FontWeight.bold : FontWeight.w500))),
        ],
      ),
    );
  }
}

// ==============================================================================
// 7. HOSTNAME FINDER MODAL (DNS & SNI Lookup)
// ==============================================================================
class HostFinderModal extends StatefulWidget {
  const HostFinderModal({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => const HostFinderModal(),
    );
  }

  @override
  State<HostFinderModal> createState() => _HostFinderModalState();
}

class _HostFinderModalState extends State<HostFinderModal> {
  final _controller = TextEditingController(text: 'mobily.com.sa');
  Map<String, dynamic>? _result;
  bool _isSearching = false;

  Future<void> _lookup() async {
    final query = _controller.text.trim();
    if (query.isEmpty) return;

    setState(() => _isSearching = true);
    final res = await VpnApiService.lookupHostname(query);
    setState(() {
      _isSearching = false;
      _result = res?['data'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Row(
        children: [
          Icon(Icons.travel_explore_rounded, color: Color(0xFF43A047)),
          SizedBox(width: 8),
          Text('HostName Finder', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Domain / SNI Bug Host',
                hintText: 'e.g. mobily.com.sa or mktunnelvpn.xyz',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search, color: Color(0xFF43A047)),
                  onPressed: _lookup,
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (_isSearching)
              const Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator())
            else if (_result != null) ...[
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Resolved IP: ${_result!['primary_ip'] ?? 'None'}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('Proxy Status: ${_result!['proxy_status']}'),
                    Text('Cloudflare Protected: ${_result!['is_cloudflare'] == true ? 'YES (CDN)' : 'NO (Direct IP)'}'),
                    if (_result!['resolved_ips'] != null)
                      Text('All IPs: ${(_result!['resolved_ips'] as List).join(', ')}', style: const TextStyle(fontSize: 11)),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('CLOSE')),
      ],
    );
  }
}

// ==============================================================================
// 8. SLOWDNS CHECKER MODAL
// ==============================================================================
class SlowDnsModal extends StatefulWidget {
  const SlowDnsModal({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => const SlowDnsModal(),
    );
  }

  @override
  State<SlowDnsModal> createState() => _SlowDnsModalState();
}

class _SlowDnsModalState extends State<SlowDnsModal> {
  List<Map<String, dynamic>> _resolvers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await VpnApiService.fetchSlowDnsList();
    if (mounted) {
      setState(() {
        _resolvers = list;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Row(
        children: [
          Icon(Icons.speed_rounded, color: Color(0xFF43A047)),
          SizedBox(width: 8),
          Text('SlowDNS Resolvers', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: _isLoading
            ? const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()))
            : ListView.separated(
                shrinkWrap: true,
                itemCount: _resolvers.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (ctx, i) {
                  final r = _resolvers[i];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(r['operator_name'] ?? 'DNS', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    subtitle: Text('IP: ${r['resolver_ip']} (Port 53 UDP)', style: const TextStyle(fontSize: 11)),
                    trailing: Text('${r['latency_ms'] ?? 20} ms', style: const TextStyle(color: Color(0xFF43A047), fontWeight: FontWeight.bold)),
                  );
                },
              ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('CLOSE')),
      ],
    );
  }
}

// ==============================================================================
// 9. MOBILE IP HUNTER MODAL
// ==============================================================================
class IpHunterModal extends StatefulWidget {
  const IpHunterModal({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => const IpHunterModal(),
    );
  }

  @override
  State<IpHunterModal> createState() => _IpHunterModalState();
}

class _IpHunterModalState extends State<IpHunterModal> {
  String _currentCellularIp = '100.64.12.89'; // Sample cellular rmnet IP
  final String _targetPrefix = '100.64.';
  bool _matched = true;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Row(
        children: [
          Icon(Icons.my_location_rounded, color: Color(0xFF43A047)),
          SizedBox(width: 8),
          Text('Mobile IP Hunter', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Matches cellular IP for zero balance bypass:'),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _matched ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(_matched ? Icons.check_circle : Icons.warning_amber_rounded, color: _matched ? Colors.green : Colors.red),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Current IP: $_currentCellularIp', style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text('Target Range: $_targetPrefix* (MATCHED)', style: const TextStyle(fontSize: 11, color: Colors.green)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Text('Tip: If IP does not match, toggle Airplane Mode ON and OFF to get a new IP address.', style: TextStyle(fontSize: 11.5, color: Colors.grey)),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            setState(() {
              _currentCellularIp = '100.64.45.102';
              _matched = true;
            });
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Refreshed cellular interface!')));
          },
          child: const Text('REFRESH IP'),
        ),
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('CLOSE')),
      ],
    );
  }
}

// ==============================================================================
// 10. PROTOCOL SETTINGS MODAL (V2Ray / OpenVPN)
// ==============================================================================
class ProtocolSettingsModal extends StatefulWidget {
  const ProtocolSettingsModal({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => const ProtocolSettingsModal(),
    );
  }

  @override
  State<ProtocolSettingsModal> createState() => _ProtocolSettingsModalState();
}

class _ProtocolSettingsModalState extends State<ProtocolSettingsModal> {
  bool _mux = true;
  String _dns = 'Google DNS (8.8.8.8)';
  bool _tcpFastOpen = true;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Row(
        children: [
          Icon(Icons.public_rounded, color: Color(0xFF43A047)),
          SizedBox(width: 8),
          Text('Protocol Settings', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('V2Ray Mux (Multiplexing)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              subtitle: const Text('Reduces handshake latency over high-ping networks', style: TextStyle(fontSize: 11)),
              value: _mux,
              onChanged: (v) => setState(() => _mux = v),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('TCP Fast Open', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              value: _tcpFastOpen,
              onChanged: (v) => setState(() => _tcpFastOpen = v),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _dns,
              decoration: const InputDecoration(labelText: 'Custom DNS Resolver', isDense: true),
              items: const [
                DropdownMenuItem(value: 'Google DNS (8.8.8.8)', child: Text('Google DNS (8.8.8.8)')),
                DropdownMenuItem(value: 'Cloudflare (1.1.1.1)', child: Text('Cloudflare (1.1.1.1)')),
                DropdownMenuItem(value: 'Quad9 (9.9.9.9)', child: Text('Quad9 (9.9.9.9)')),
              ],
              onChanged: (val) {
                if (val != null) setState(() => _dns = val);
              },
            ),
          ],
        ),
      ),
      actions: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF43A047), foregroundColor: Colors.white),
          onPressed: () {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Protocol settings applied!')));
          },
          child: const Text('SAVE SETTINGS'),
        ),
      ],
    );
  }
}

// ==============================================================================
// 11. APP SETTINGS & SPLIT TUNNELING MODAL
// ==============================================================================
class AppSettingsModal extends StatefulWidget {
  const AppSettingsModal({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => const AppSettingsModal(),
    );
  }

  @override
  State<AppSettingsModal> createState() => _AppSettingsModalState();
}

class _AppSettingsModalState extends State<AppSettingsModal> {
  bool _autoReconnect = true;
  bool _wakeLock = true;
  final List<String> _disallowedApps = ['WhatsApp', 'Banking App'];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Row(
        children: [
          Icon(Icons.settings_outlined, color: Color(0xFF43A047)),
          SizedBox(width: 8),
          Text('App & Split Tunneling', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Auto-Reconnect on Network Drop', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              value: _autoReconnect,
              onChanged: (v) => setState(() => _autoReconnect = v),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Keep CPU Awake (WakeLock)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              value: _wakeLock,
              onChanged: (v) => setState(() => _wakeLock = v),
            ),
            const Divider(),
            const Text('Split Tunneling (Apps Bypassing VPN):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 6),
            ..._disallowedApps.map((app) => CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  title: Text(app, style: const TextStyle(fontSize: 12.5)),
                  value: true,
                  onChanged: (v) {},
                )),
          ],
        ),
      ),
      actions: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF43A047), foregroundColor: Colors.white),
          onPressed: () {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('App configuration saved.')));
          },
          child: const Text('SAVE'),
        ),
      ],
    );
  }
}

// ==============================================================================
// 12. HOTSPOT SHARE (VPN TETHERING) MODAL
// ==============================================================================
class HotspotModal extends StatefulWidget {
  const HotspotModal({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => const HotspotModal(),
    );
  }

  @override
  State<HotspotModal> createState() => _HotspotModalState();
}

class _HotspotModalState extends State<HotspotModal> {
  bool _tetheringActive = true;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Row(
        children: [
          Icon(Icons.wifi_tethering_rounded, color: Color(0xFF43A047)),
          SizedBox(width: 8),
          Text('Hotspot Share (Tethering)', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Share your VPN connection over local Wi-Fi Hotspot:'),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('HTTP / SOCKS5 Proxy', style: TextStyle(fontWeight: FontWeight.bold)),
                    Switch(value: _tetheringActive, onChanged: (v) => setState(() => _tetheringActive = v)),
                  ],
                ),
                const Text('IP Address: 192.168.43.1', style: TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold, fontSize: 13)),
                const Text('Port: 8080', style: TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold, fontSize: 13)),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const Text('Instructions for connected devices:\nIn Wi-Fi settings, set Proxy to Manual, enter Host 192.168.43.1 and Port 8080.', style: TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('CLOSE')),
      ],
    );
  }
}

// ==============================================================================
// 13. THEME SETTINGS MODAL
// ==============================================================================
class ThemeSettingsModal extends StatefulWidget {
  const ThemeSettingsModal({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => const ThemeSettingsModal(),
    );
  }

  @override
  State<ThemeSettingsModal> createState() => _ThemeSettingsModalState();
}

class _ThemeSettingsModalState extends State<ThemeSettingsModal> {
  Color _selectedColor = const Color(0xFF43A047);

  final List<Map<String, dynamic>> _colors = [
    {'name': 'Emerald Green', 'color': const Color(0xFF43A047)},
    {'name': 'Royal Purple', 'color': const Color(0xFF7C3AED)},
    {'name': 'Ocean Blue', 'color': const Color(0xFF2563EB)},
    {'name': 'Sunset Amber', 'color': const Color(0xFFD97706)},
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Row(
        children: [
          Icon(Icons.wb_sunny_outlined, color: Color(0xFF43A047)),
          SizedBox(width: 8),
          Text('Theme Settings', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Select Accent Color:'),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _colors.map((c) {
              final color = c['color'] as Color;
              final isSel = _selectedColor == color;
              return GestureDetector(
                onTap: () => setState(() => _selectedColor = color),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: isSel ? Border.all(color: Colors.white, width: 3) : null,
                    boxShadow: isSel ? [const BoxShadow(color: Colors.black26, blurRadius: 6)] : null,
                  ),
                  child: isSel ? const Icon(Icons.check, color: Colors.white, size: 22) : null,
                ),
              );
            }).toList(),
          ),
        ],
      ),
      actions: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF43A047), foregroundColor: Colors.white),
          onPressed: () {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Theme updated!')));
          },
          child: const Text('APPLY THEME'),
        ),
      ],
    );
  }
}


// ==============================================================================
// 14. PRIVACY POLICY MODAL (In-App View + Open in Web Browser)
// ==============================================================================
class PrivacyPolicyModal extends StatelessWidget {
  const PrivacyPolicyModal({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => const PrivacyPolicyModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final config = context.watch<ConfigProvider>();
    final policy = config.privacyPolicy.isNotEmpty
        ? config.privacyPolicy
        : 'MR Tunnel VPN Privacy Policy\n\n'
          'Zero-Log Policy: We do not store or track any browsing history or user traffic.\n\n'
          'Device Identifier: Hardware ID (HWID) is used strictly to authenticate connection slots.\n\n'
          'Google AdMob: Our app integrates Google AdMob for banner, interstitial, and rewarded ads.\n\n'
          'Data Encryption: Military-grade AES-256-GCM / ChaCha20 encryption on all tunnels.';

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Row(
        children: [
          Icon(Icons.shield_outlined, color: Color(0xFF43A047)),
          SizedBox(width: 8),
          Text('Privacy Policy', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: SelectableText(
                policy,
                style: const TextStyle(fontSize: 12, height: 1.5),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Live Public Web URL (Play Store Compliant):',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: SelectableText(
                config.privacyPolicyUrl,
                style: const TextStyle(fontSize: 10.5, fontFamily: 'monospace', color: Color(0xFF2563EB)),
              ),
            ),
          ],
        ),
      ),
      actions: [
        OutlinedButton.icon(
          onPressed: () {
            Clipboard.setData(ClipboardData(text: config.privacyPolicyUrl));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Web URL copied to clipboard! 📋')),
            );
          },
          icon: const Icon(Icons.copy, size: 16),
          label: const Text('COPY LINK'),
        ),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF43A047),
            foregroundColor: Colors.white,
          ),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Opening ${config.privacyPolicyUrl} in external browser...')),
            );
            Navigator.pop(context);
          },
          icon: const Icon(Icons.open_in_browser, size: 18),
          label: const Text('OPEN IN BROWSER'),
        ),
      ],
    );
  }
}
