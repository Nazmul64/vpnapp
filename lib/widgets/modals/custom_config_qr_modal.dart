import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/custom_configuration_model.dart';
import '../../providers/vpn_provider.dart';

class CustomConfigQrModal extends StatefulWidget {
  final CustomConfigurationModel? currentConfig;
  final int initialTab;

  const CustomConfigQrModal({
    super.key,
    this.currentConfig,
    this.initialTab = 0,
  });

  static Future<void> show(BuildContext context, {CustomConfigurationModel? config, int initialTab = 0}) {
    return showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      builder: (context) => CustomConfigQrModal(currentConfig: config, initialTab: initialTab),
    );
  }

  @override
  State<CustomConfigQrModal> createState() => _CustomConfigQrModalState();
}

class _CustomConfigQrModalState extends State<CustomConfigQrModal> {
  late int _activeTab; // 0 = SHARE / EXPORT, 1 = SCAN / IMPORT

  // Share state
  late String _shareString;

  // Import state
  final TextEditingController _importController = TextEditingController();
  CustomConfigurationModel? _previewConfig;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _activeTab = widget.initialTab;
    final config = widget.currentConfig ?? CustomConfigurationModel();
    _shareString = config.toShareString();
  }

  @override
  void dispose() {
    _importController.dispose();
    super.dispose();
  }

  void _validateImport() {
    setState(() {
      _errorMessage = null;
      _previewConfig = null;
    });

    final raw = _importController.text.trim();
    if (raw.isEmpty) {
      setState(() => _errorMessage = 'Please enter or paste configuration string.');
      return;
    }

    final parsed = CustomConfigurationModel.fromShareString(raw);
    if (parsed == null) {
      setState(() => _errorMessage = 'Invalid configuration format. Make sure it starts with MKCONFIG::');
      return;
    }

    setState(() {
      _previewConfig = parsed;
    });
  }

  void _applyImportedConfig() {
    if (_previewConfig == null) return;

    final vpnProvider = context.read<VpnProvider>();
    vpnProvider.setActiveCustomConfig(_previewConfig!);

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Configuration '${_previewConfig!.name}' imported & activated! 🎉"),
        backgroundColor: const Color(0xFF2E7D32),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
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
            // Modal Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 12, 10),
              child: Row(
                children: [
                  const Icon(Icons.qr_code_scanner_rounded, color: Color(0xFF43A047), size: 24),
                  const SizedBox(width: 8),
                  Text(
                    _activeTab == 0 ? 'Share Configuration' : 'Import Configuration',
                    style: const TextStyle(fontSize: 16.5, fontWeight: FontWeight.w800, color: Color(0xFF1F2937)),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Color(0xFF6B7280)),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFE5E7EB)),

            // Tabs Segment
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _activeTab == 0 ? const Color(0xFF43A047) : const Color(0xFFF1F5F9),
                        foregroundColor: _activeTab == 0 ? Colors.white : const Color(0xFF475569),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () => setState(() => _activeTab = 0),
                      icon: const Icon(Icons.share_rounded, size: 18),
                      label: const Text('SHARE', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _activeTab == 1 ? const Color(0xFF43A047) : const Color(0xFFF1F5F9),
                        foregroundColor: _activeTab == 1 ? Colors.white : const Color(0xFF475569),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () => setState(() => _activeTab = 1),
                      icon: const Icon(Icons.qr_code_2_rounded, size: 18),
                      label: const Text('SCAN / IMPORT', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),

            // Tab Content
            Flexible(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: _activeTab == 0 ? _buildShareTab() : _buildImportTab(),
              ),
            ),

            const Divider(height: 1, color: Color(0xFFE5E7EB)),

            // Footer
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('CLOSE', style: TextStyle(color: Color(0xFF6B7280), fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShareTab() {
    final cfg = widget.currentConfig ?? CustomConfigurationModel();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Stylized QR Card
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFCBD5E1)),
          ),
          child: Column(
            children: [
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF43A047), width: 1.5),
                ),
                child: const Center(
                  child: Icon(Icons.qr_code_2_rounded, color: Color(0xFF2E7D32), size: 90),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                cfg.name,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF111827)),
              ),
              Text(
                '${cfg.protocolLabel} • Host: ${cfg.urlHost}',
                style: const TextStyle(fontSize: 11.5, color: Color(0xFF6B7280)),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        const Text(
          'Shareable Encrypted String:',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF374151)),
        ),
        const SizedBox(height: 4),

        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(8),
          ),
          child: SelectableText(
            _shareString,
            style: const TextStyle(fontSize: 10.5, fontFamily: 'monospace', color: Color(0xFF334155)),
            maxLines: 3,
          ),
        ),

        const SizedBox(height: 12),

        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF43A047),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          onPressed: () {
            Clipboard.setData(ClipboardData(text: _shareString));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Configuration copied to clipboard! 📋')),
            );
          },
          icon: const Icon(Icons.copy_rounded, size: 18),
          label: const Text('COPY SHARE CODE', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildImportTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _importController,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: 'Paste QR String or MKCONFIG code',
            hintText: 'MKCONFIG::eyJwcm90b2NvbCI...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            isDense: true,
          ),
        ),

        const SizedBox(height: 10),

        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF43A047),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            padding: const EdgeInsets.symmetric(vertical: 11),
          ),
          onPressed: _validateImport,
          icon: const Icon(Icons.verified_rounded, size: 18),
          label: const Text('VALIDATE & PREVIEW', style: TextStyle(fontWeight: FontWeight.bold)),
        ),

        if (_errorMessage != null) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFFFEBEE),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _errorMessage!,
              style: const TextStyle(color: Color(0xFFC62828), fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ],

        if (_previewConfig != null) ...[
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF81C784)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.check_circle_rounded, color: Color(0xFF2E7D32), size: 18),
                    const SizedBox(width: 6),
                    Text(
                      _previewConfig!.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: Color(0xFF1B5E20)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text('Protocol: ${_previewConfig!.protocolLabel}', style: const TextStyle(fontSize: 12)),
                Text('URL Host: ${_previewConfig!.urlHost}', style: const TextStyle(fontSize: 12)),
                Text('DNS Mode: ${_previewConfig!.serverDnsMode.toUpperCase()}', style: const TextStyle(fontSize: 12)),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: _applyImportedConfig,
                    child: const Text('CONFIRM & ACTIVATE', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
