import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/custom_configuration_model.dart';
import '../../providers/vpn_provider.dart';
import '../../services/custom_setup_api_service.dart';
import 'payload_generator_modal.dart';
import 'custom_config_qr_modal.dart';

class CustomSetupDialog extends StatefulWidget {
  const CustomSetupDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      builder: (context) => const CustomSetupDialog(),
    );
  }

  @override
  State<CustomSetupDialog> createState() => _CustomSetupDialogState();
}

class _CustomSetupDialogState extends State<CustomSetupDialog> {
  late CustomConfigurationModel _config;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _payloadController = TextEditingController();
  final TextEditingController _hostController = TextEditingController();
  final TextEditingController _proxyHostController = TextEditingController();
  final TextEditingController _proxyPortController = TextEditingController(text: '8080');

  String _protocol = 'http_direct';
  String _dnsMode = 'websocket';
  String _proxyType = 'http';

  bool _isTesting = false;
  String? _testMessage;
  bool _testSuccess = false;

  final List<Map<String, String>> _protocolOptions = const [
    {'value': 'http_direct', 'label': 'HTTP > DIRECT', 'badge': 'DIRECT'},
    {'value': 'http_proxy', 'label': 'HTTP > PROXY', 'badge': 'PROXY'},
    {'value': 'openvpn_ws', 'label': 'OpenVPN > WebSocket', 'badge': 'OVPN WS'},
    {'value': 'ssh_ws', 'label': 'SSH > WebSocket', 'badge': 'SSH WS'},
    {'value': 'ssl_ws', 'label': 'SSL > WebSocket', 'badge': 'SSL WS'},
    {'value': 'ssl_direct', 'label': 'SSL/TLS > DIRECT', 'badge': 'SSL'},
    {'value': 'openvpn_direct', 'label': 'OpenVPN > DIRECT', 'badge': 'OVPN'},
  ];

  final List<Map<String, String>> _dnsModeOptions = const [
    {'value': 'websocket', 'label': 'WEBSOCKET (Port 443)'},
    {'value': 'normal', 'label': 'NORMAL (Standard UDP 53)'},
    {'value': 'ssl', 'label': 'SSL / DoH (Encrypted DNS)'},
    {'value': 'direct', 'label': 'DIRECT IP BIND'},
    {'value': 'auto', 'label': 'AUTO RESOLVE'},
  ];

  @override
  void initState() {
    super.initState();
    final vpnProvider = context.read<VpnProvider>();
    _config = vpnProvider.activeCustomConfig;

    _nameController.text = _config.name;
    _payloadController.text = _config.payload;
    _hostController.text = _config.urlHost;
    _protocol = _config.protocol;
    _dnsMode = _config.serverDnsMode;
    _proxyType = _config.proxyType ?? 'http';
    _proxyHostController.text = _config.proxyHost ?? '';
    _proxyPortController.text = (_config.proxyPort ?? 8080).toString();

    // Dynamically sync options from backend if available
    _loadBackendOptions();
  }

  Future<void> _loadBackendOptions() async {
    final opts = await CustomSetupApiService.fetchOptions();
    if (opts != null && mounted) {
      // Backend options loaded
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _payloadController.dispose();
    _hostController.dispose();
    _proxyHostController.dispose();
    _proxyPortController.dispose();
    super.dispose();
  }

  void _openPayloadGenerator() async {
    await PayloadGeneratorModal.show(context);
    // Refresh payload from VpnProvider if updated by generator
    if (mounted) {
      final vpn = context.read<VpnProvider>();
      setState(() {
        _payloadController.text = vpn.customPayloadString;
        _config.payload = vpn.customPayloadString;
      });
    }
  }

  Future<void> _testConnection() async {
    setState(() {
      _isTesting = true;
      _testMessage = null;
    });

    final host = _hostController.text.trim().isEmpty ? '89.116.28.187' : _hostController.text.trim();
    final res = await CustomSetupApiService.testConnection(
      host: host,
      port: 443,
      protocol: _protocol,
    );

    if (mounted) {
      setState(() {
        _isTesting = false;
        _testSuccess = res['success'] == true;
        _testMessage = res['message'] ?? 'Connectivity tested.';
      });
    }
  }

  void _saveAndApply() {
    final vpnProvider = context.read<VpnProvider>();

    _config.name = _nameController.text.trim().isEmpty ? 'My Custom Setup' : _nameController.text.trim();
    _config.protocol = _protocol;
    _config.serverDnsMode = _dnsMode;
    _config.urlHost = _hostController.text.trim().isEmpty ? 'mobily.com.sa' : _hostController.text.trim();
    _config.payload = _payloadController.text.trim();
    _config.proxyType = _proxyType;
    _config.proxyHost = _proxyHostController.text.trim();
    _config.proxyPort = int.tryParse(_proxyPortController.text.trim()) ?? 8080;
    _config.isActive = true;

    // Apply locally
    vpnProvider.setActiveCustomConfig(_config);
    vpnProvider.setCustomSetup(true);

    // Save to Laravel Backend asynchronously
    CustomSetupApiService.saveConfiguration(_config);

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Custom Setup Saved: ${_config.protocolLabel}! 🎉"),
        backgroundColor: const Color(0xFF2E7D32),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isProxyProtocol = _protocol == 'http_proxy';

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.90,
          maxWidth: 440,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFF43A047), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Modal Header with Share & Scan buttons matching requirements
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
              child: Row(
                children: [
                  const Icon(Icons.tune_rounded, color: Color(0xFF43A047), size: 24),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'CUSTOM SETUP',
                      style: TextStyle(
                        fontSize: 16.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111827),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  // Share Button
                  IconButton(
                    icon: const Icon(Icons.share_rounded, color: Color(0xFF43A047), size: 22),
                    tooltip: 'Share QR Config',
                    onPressed: () => CustomConfigQrModal.show(context, config: _config),
                  ),
                  // Scan / Import Button
                  IconButton(
                    icon: const Icon(Icons.qr_code_scanner_rounded, color: Color(0xFF43A047), size: 22),
                    tooltip: 'Scan / Import Config',
                    onPressed: () => CustomConfigQrModal.show(context, config: _config),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Color(0xFF6B7280), size: 22),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFE5E7EB)),

            // Scrollable Configuration Form
            Flexible(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Configuration Name
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Configuration Name',
                        isDense: true,
                        prefixIcon: const Icon(Icons.label_outline_rounded, color: Color(0xFF43A047), size: 20),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Section 1: Select Protocol
                    DropdownButtonFormField<String>(
                      initialValue: _protocol,
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: 'Select Protocol',
                        isDense: true,
                        prefixIcon: const Icon(Icons.vpn_lock_rounded, color: Color(0xFF43A047), size: 20),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      items: _protocolOptions.map((p) {
                        return DropdownMenuItem<String>(
                          value: p['value'],
                          child: Row(
                            children: [
                              Text(p['label']!, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFDCFCE7),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  p['badge']!,
                                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF15803D)),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _protocol = val);
                      },
                    ),
                    const SizedBox(height: 12),

                    // URL Host / Bug Host
                    TextField(
                      controller: _hostController,
                      decoration: InputDecoration(
                        labelText: 'URL Host / Bug Host',
                        hintText: 'e.g. mobily.com.sa or 89.116.28.187',
                        prefixIcon: const Icon(Icons.public_rounded, color: Color(0xFF43A047), size: 20),
                        isDense: true,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Section 2: Payload Editor with Action Buttons
                    Row(
                      children: [
                        const Text(
                          'Custom Payload:',
                          style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Color(0xFF374151)),
                        ),
                        const Spacer(),
                        // (+) Payload Generator Button
                        InkWell(
                          onTap: _openPayloadGenerator,
                          borderRadius: BorderRadius.circular(6),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFF43A047),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.add_circle_outline_rounded, color: Colors.white, size: 14),
                                SizedBox(width: 4),
                                Text(
                                  'Generator (+)',
                                  style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        // Copy Button
                        IconButton(
                          icon: const Icon(Icons.copy_rounded, size: 18, color: Color(0xFF6B7280)),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          tooltip: 'Copy Payload',
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: _payloadController.text));
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payload copied! 📋')));
                          },
                        ),
                        const SizedBox(width: 6),
                        // Paste Button
                        IconButton(
                          icon: const Icon(Icons.paste_rounded, size: 18, color: Color(0xFF6B7280)),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          tooltip: 'Paste Payload',
                          onPressed: () async {
                            final data = await Clipboard.getData('text/plain');
                            if (data?.text != null) {
                              setState(() => _payloadController.text = data!.text!);
                            }
                          },
                        ),
                        const SizedBox(width: 6),
                        // Clear Button
                        IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 18, color: Color(0xFFEF4444)),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          tooltip: 'Clear',
                          onPressed: () => setState(() => _payloadController.clear()),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Multiline Payload Input
                    TextField(
                      controller: _payloadController,
                      maxLines: 4,
                      style: const TextStyle(fontFamily: 'monospace', fontSize: 11.5, color: Color(0xFF0F172A)),
                      decoration: InputDecoration(
                        hintText: 'Enter your custom payload...\nExample: GET / HTTP/1.1[crlf]Host: [host][crlf]Upgrade: websocket[crlf][crlf]',
                        hintStyle: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        isDense: true,
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Section 3: Server DNS Mode Dropdown
                    DropdownButtonFormField<String>(
                      initialValue: _dnsMode,
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: 'Server DNS Mode',
                        isDense: true,
                        prefixIcon: const Icon(Icons.dns_rounded, color: Color(0xFF43A047), size: 20),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      items: _dnsModeOptions.map((d) {
                        return DropdownMenuItem<String>(
                          value: d['value'],
                          child: Text(d['label']!, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _dnsMode = val);
                      },
                    ),
                    const SizedBox(height: 12),

                    // Section 4: Proxy Configuration (Enabled when HTTP > PROXY)
                    if (isProxyProtocol) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFCBD5E1)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.router_rounded, color: Color(0xFF43A047), size: 18),
                                SizedBox(width: 6),
                                Text(
                                  'Proxy Configuration:',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: TextField(
                                    controller: _proxyHostController,
                                    decoration: InputDecoration(
                                      labelText: 'Proxy Host',
                                      isDense: true,
                                      hintText: '127.0.0.1 or domain',
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  flex: 2,
                                  child: TextField(
                                    controller: _proxyPortController,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      labelText: 'Port',
                                      isDense: true,
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],

                    // Section 5: Connection Testing Button
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF2E7D32),
                        side: const BorderSide(color: Color(0xFF43A047)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      onPressed: _isTesting ? null : _testConnection,
                      icon: _isTesting
                          ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.network_ping_rounded, size: 18),
                      label: Text(_isTesting ? 'Testing Connectivity...' : 'TEST HOST CONNECTIVITY'),
                    ),

                    if (_testMessage != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: _testSuccess ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _testSuccess ? const Color(0xFFA5D6A7) : const Color(0xFFEF9A9A),
                          ),
                        ),
                        child: Text(
                          _testMessage!,
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: _testSuccess ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const Divider(height: 1, color: Color(0xFFE5E7EB)),

            // Footer Actions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF64748B),
                        side: const BorderSide(color: Color(0xFFCBD5E1)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text('CANCEL'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF43A047),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: _saveAndApply,
                      child: const Text(
                        'SAVE & ACTIVATE',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
