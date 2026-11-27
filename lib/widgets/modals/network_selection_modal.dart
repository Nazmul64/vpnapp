import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_typography.dart';
import '../../models/network_payload.dart';
import '../../providers/vpn_provider.dart';
import '../common/operator_logo_widget.dart';

class NetworkSelectionModal extends StatefulWidget {
  const NetworkSelectionModal({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      builder: (context) => const NetworkSelectionModal(),
    );
  }

  @override
  State<NetworkSelectionModal> createState() => _NetworkSelectionModalState();
}

class _NetworkSelectionModalState extends State<NetworkSelectionModal> {
  String _searchQuery = '';
  bool _showAllNetworks = false; // By default Local Networks is active (matching screenshot 2)
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _extractCountryCode(String networkString) {
    final match = RegExp(r'\[([A-Z]{2})\]').firstMatch(networkString);
    return match != null ? match.group(1)! : 'BD';
  }

  @override
  Widget build(BuildContext context) {
    final vpnProvider = context.watch<VpnProvider>();
    final allPayloads = NetworkPayload.allPayloads;
    final userCountryCode = _extractCountryCode(vpnProvider.currentNetwork);

    final filteredList = allPayloads.where((item) {
      if (!_showAllNetworks) {
        final matchesCountry = item.countryCode == userCountryCode ||
            (userCountryCode == 'BD' && item.isLocal && item.countryCode == 'BD');
        if (!matchesCountry) return false;
      }
      if (_searchQuery.trim().isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return item.name.toLowerCase().contains(q) ||
          item.operator.toLowerCase().contains(q) ||
          item.networkTag.toLowerCase().contains(q) ||
          item.subtitle.toLowerCase().contains(q);
    }).toList();

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.90,
          maxWidth: 420,
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
          children: [
            // Top Padding & Search Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFFB0BEC5),
                    width: 1.2,
                  ),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 14),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (val) {
                          setState(() {
                            _searchQuery = val;
                          });
                        },
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF1F2937),
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Search network name',
                          hintStyle: TextStyle(
                            fontSize: 13.5,
                            color: Color(0xFF9E9E9E),
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.search_rounded,
                        color: Color(0xFF43A047),
                        size: 24,
                      ),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ),

            // Segmented Tab Switch: Local Networks | All Networks
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFF43A047),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    // Local Networks tab
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _showAllNetworks = false;
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: !_showAllNetworks
                                ? const Color(0xFF43A047)
                                : Colors.white,
                            borderRadius: const BorderRadius.horizontal(
                              left: Radius.circular(6.5),
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Local Networks',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: !_showAllNetworks
                                  ? Colors.white
                                  : const Color(0xFF424242),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // All Networks tab
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _showAllNetworks = true;
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: _showAllNetworks
                                ? const Color(0xFF43A047)
                                : Colors.white,
                            borderRadius: const BorderRadius.horizontal(
                              right: Radius.circular(6.5),
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'All Networks',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: _showAllNetworks
                                  ? Colors.white
                                  : const Color(0xFF424242),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Payloads List
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                itemCount: filteredList.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final payload = filteredList[index];
                  final isSelected = vpnProvider.selectedPayload.id == payload.id;

                  return InkWell(
                    onTap: () {
                      vpnProvider.selectPayload(payload);
                      Navigator.of(context).pop();
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 9,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFFF1F8E9) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF43A047)
                              : const Color(0xFFE0E0E0),
                          width: isSelected ? 1.5 : 1.0,
                        ),
                      ),
                      child: Row(
                        children: [
                          // Operator / Country Brand Icon
                          OperatorLogoWidget(
                            iconType: payload.iconType,
                            size: 38,
                          ),
                          const SizedBox(width: 10),

                          // Text Content
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  payload.name,
                                  style: AppTypography.itemTitle.copyWith(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF1F2937),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  payload.subtitle,
                                  style: AppTypography.itemSubtitle.copyWith(
                                    fontSize: 10.8,
                                    color: const Color(0xFF757575),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 8),

                          // Radio checkmark on right (Selected: green circle with checkmark, Unselected: empty circle)
                          Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected
                                  ? const Color(0xFF43A047)
                                  : Colors.transparent,
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF43A047)
                                    : const Color(0xFFCFD8DC),
                                width: 1.8,
                              ),
                            ),
                            child: isSelected
                                ? const Center(
                                    child: Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 15,
                                    ),
                                  )
                                : null,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
