import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/vpn_provider.dart';

class PayloadGeneratorModal extends StatefulWidget {
  const PayloadGeneratorModal({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      builder: (context) => const PayloadGeneratorModal(),
    );
  }

  @override
  State<PayloadGeneratorModal> createState() => _PayloadGeneratorModalState();
}

class _PayloadGeneratorModalState extends State<PayloadGeneratorModal> {
  // 1. Payload Mode
  String _payloadMode = 'Normal'; // Normal, Split, Direct
  bool _rotate = false;

  // 2. URL Host / Bug Host
  final TextEditingController _urlHostController = TextEditingController(text: 'mobily.com.sa');

  // 3. Request Method (Full width, CONNECT will never be clipped to CONNEC..)
  String _requestMethod = 'CONNECT';
  final List<String> _methods = const ['CONNECT', 'GET', 'POST', 'PUT', 'HEAD', 'OPTIONS', 'TRACE'];

  // 4. Injection Method
  String _injectionMethod = 'Normal';
  final List<String> _injections = const ['Normal', 'Front Inject', 'Back Inject'];

  // 5. Query Method
  String _queryMethod = 'Normal';
  final List<String> _queryMethods = const ['Normal', 'Front Query', 'Back Query'];

  // 6. Extra Headers
  bool _onlineHost = true;
  bool _forwardHost = false;
  bool _reverseProxy = false;
  bool _keepAlive = true;
  bool _userAgent = true;
  bool _referer = false;

  // 7. Extra Options
  bool _raw = false;
  bool _dualConnect = false;

  // Generated Payload output
  String _generatedPayload = '';

  @override
  void initState() {
    super.initState();
    _generatePayloadString();
  }

  @override
  void dispose() {
    _urlHostController.dispose();
    super.dispose();
  }

  void _generatePayloadString() {
    final host = _urlHostController.text.trim().isEmpty ? 'mobily.com.sa' : _urlHostController.text.trim();
    final sb = StringBuffer();

    // Query injection
    String hostTarget = '[host_port]';
    if (_queryMethod == 'Front Query') {
      hostTarget = '$host@[host_port]';
    } else if (_queryMethod == 'Back Query') {
      hostTarget = '[host_port]@$host';
    }

    if (_raw) {
      sb.write('$_requestMethod $hostTarget [protocol][crlf]Host: $host[crlf][crlf]');
      setState(() => _generatedPayload = sb.toString());
      return;
    }

    if (_injectionMethod == 'Front Inject') {
      sb.write('GET http://$host/ [protocol][crlf][crlf]');
    }

    sb.write('$_requestMethod $hostTarget [protocol][crlf]');
    sb.write('Host: $host[crlf]');

    if (_onlineHost) {
      sb.write('X-Online-Host: $host[crlf]');
    }
    if (_forwardHost) {
      sb.write('X-Forward-Host: $host[crlf]');
    }
    if (_reverseProxy) {
      sb.write('X-Forwarded-For: 127.0.0.1[crlf]');
    }
    if (_keepAlive) {
      sb.write('Connection: Keep-Alive[crlf]');
    }
    if (_userAgent) {
      sb.write('User-Agent: [ua][crlf]');
    }
    if (_referer) {
      sb.write('Referer: http://$host/[crlf]');
    }
    if (_rotate) {
      sb.write('X-Rotate: enabled[crlf]');
    }
    if (_dualConnect) {
      sb.write('X-Dual-Connect: true[crlf]');
    }

    if (_payloadMode == 'Split') {
      sb.write('[split]');
    }

    sb.write('[crlf]');

    if (_injectionMethod == 'Back Inject') {
      sb.write('GET http://$host/ [protocol][crlf][crlf]');
    }

    setState(() {
      _generatedPayload = sb.toString();
    });
  }

  void _applyToVpn() {
    _generatePayloadString();
    final vpnProvider = context.read<VpnProvider>();
    final host = _urlHostController.text.trim().isEmpty ? 'DIRECT' : _urlHostController.text.trim();

    vpnProvider.applyCustomPayload(
      title: 'Custom Setup Enabled: $_requestMethod > $_payloadMode',
      subtitle: 'Host: $host | $_injectionMethod',
      payload: _generatedPayload,
    );

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Custom Payload applied! ($_requestMethod > $_payloadMode)'),
        backgroundColor: const Color(0xFF2E7D32),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.88,
          maxWidth: 440,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: const Color(0xFF43A047),
            width: 1.5,
          ),
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
                  Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFDCFCE7),
                    ),
                    child: const Icon(
                      Icons.settings_suggest_rounded,
                      color: Color(0xFF2E7D32),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Payload Generator',
                      style: TextStyle(
                        fontSize: 16.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Color(0xFF6B7280), size: 22),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFE5E7EB)),

            // Scrollable Content
            Flexible(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Mode Selection: Normal / Split / Direct
                    Row(
                      children: [
                        const Text(
                          'Payload Mode:',
                          style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Color(0xFF374151)),
                        ),
                        const Spacer(),
                        _buildModeChip('Normal'),
                        const SizedBox(width: 6),
                        _buildModeChip('Split'),
                        const SizedBox(width: 6),
                        _buildModeChip('Direct'),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // URL Host / Bug Host
                    TextField(
                      controller: _urlHostController,
                      onChanged: (_) => _generatePayloadString(),
                      decoration: InputDecoration(
                        labelText: 'URL Host / Bug Host',
                        hintText: 'e.g. mobily.com.sa or 104.16.0.1',
                        prefixIcon: const Icon(Icons.link_rounded, color: Color(0xFF43A047), size: 20),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Color(0xFF43A047), width: 1.5),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Request Method & Injection Method in two equal columns
                    Row(
                      children: [
                        // Request Method Dropdown
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _requestMethod,
                            isExpanded: true,
                            decoration: InputDecoration(
                              labelText: 'Request Method',
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            items: _methods.map((m) {
                              return DropdownMenuItem<String>(
                                value: m,
                                child: Text(
                                  m,
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                                  overflow: TextOverflow.visible,
                                ),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _requestMethod = val);
                                _generatePayloadString();
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Injection Method Dropdown
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _injectionMethod,
                            isExpanded: true,
                            decoration: InputDecoration(
                              labelText: 'Injection Method',
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            items: _injections.map((inj) {
                              return DropdownMenuItem<String>(
                                value: inj,
                                child: Text(
                                  inj,
                                  style: const TextStyle(fontSize: 12.5),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _injectionMethod = val);
                                _generatePayloadString();
                              }
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Query Method & Rotate Row
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _queryMethod,
                            isExpanded: true,
                            decoration: InputDecoration(
                              labelText: 'Query Method',
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            items: _queryMethods.map((q) {
                              return DropdownMenuItem<String>(
                                value: q,
                                child: Text(q, style: const TextStyle(fontSize: 12.5)),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _queryMethod = val);
                                _generatePayloadString();
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Rotate multi-host checkbox
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              setState(() => _rotate = !_rotate);
                              _generatePayloadString();
                            },
                            child: Row(
                              children: [
                                Checkbox(
                                  value: _rotate,
                                  activeColor: const Color(0xFF43A047),
                                  onChanged: (v) {
                                    setState(() => _rotate = v ?? false);
                                    _generatePayloadString();
                                  },
                                ),
                                const Expanded(
                                  child: Text('Rotate Host', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Extra Headers Section Header
                    const Text(
                      'Extra Headers:',
                      style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Color(0xFF374151)),
                    ),
                    const SizedBox(height: 6),

                    // Grid of 6 checkboxes
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        _buildCheckboxItem('Online Host', _onlineHost, (v) {
                          setState(() => _onlineHost = v);
                          _generatePayloadString();
                        }),
                        _buildCheckboxItem('Forward Host', _forwardHost, (v) {
                          setState(() => _forwardHost = v);
                          _generatePayloadString();
                        }),
                        _buildCheckboxItem('Reverse Proxy', _reverseProxy, (v) {
                          setState(() => _reverseProxy = v);
                          _generatePayloadString();
                        }),
                        _buildCheckboxItem('Keep Alive', _keepAlive, (v) {
                          setState(() => _keepAlive = v);
                          _generatePayloadString();
                        }),
                        _buildCheckboxItem('User Agent', _userAgent, (v) {
                          setState(() => _userAgent = v);
                          _generatePayloadString();
                        }),
                        _buildCheckboxItem('Referer', _referer, (v) {
                          setState(() => _referer = v);
                          _generatePayloadString();
                        }),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Extra options (Raw, Dual Connect)
                    const Text(
                      'Extra Options:',
                      style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Color(0xFF374151)),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        _buildCheckboxItem('Raw Mode', _raw, (v) {
                          setState(() => _raw = v);
                          _generatePayloadString();
                        }),
                        _buildCheckboxItem('Dual Connect', _dualConnect, (v) {
                          setState(() => _dualConnect = v);
                          _generatePayloadString();
                        }),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Payload Preview Box
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Generated Payload String:',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF64748B)),
                          ),
                          const SizedBox(height: 4),
                          SelectableText(
                            _generatedPayload,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 11,
                              color: Color(0xFF0F172A),
                              height: 1.25,
                            ),
                          ),
                        ],
                      ),
                    ),
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
                        foregroundColor: const Color(0xFF374151),
                        side: const BorderSide(color: Color(0xFFCBD5E1)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: _generatePayloadString,
                      child: const Text('GENERATE', style: TextStyle(fontWeight: FontWeight.bold)),
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
                      onPressed: _applyToVpn,
                      child: const Text('APPLY SETUP', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
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

  Widget _buildModeChip(String mode) {
    final isSelected = _payloadMode == mode;
    return InkWell(
      onTap: () {
        setState(() => _payloadMode = mode);
        _generatePayloadString();
      },
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF43A047) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected ? const Color(0xFF2E7D32) : const Color(0xFFE2E8F0),
          ),
        ),
        child: Text(
          mode,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : const Color(0xFF475569),
          ),
        ),
      ),
    );
  }

  Widget _buildCheckboxItem(String label, bool value, ValueChanged<bool> onChanged) {
    return SizedBox(
      width: 125,
      child: InkWell(
        onTap: () => onChanged(!value),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: value,
                activeColor: const Color(0xFF43A047),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                onChanged: (v) => onChanged(v ?? false),
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontSize: 11.5, color: Color(0xFF374151)),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
