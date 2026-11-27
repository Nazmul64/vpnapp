import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../models/server_protocol.dart';
import '../../providers/vpn_provider.dart';
import '../common/saudi_flag_widget.dart';

class ProtocolSelectionModal extends StatelessWidget {
  const ProtocolSelectionModal({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      builder: (context) => const ProtocolSelectionModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vpnProvider = context.watch<VpnProvider>();
    final protocols = ServerProtocol.allProtocols;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.75,
          maxWidth: 420,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
              child: Row(
                children: [
                  const Icon(
                    Icons.vpn_lock_rounded,
                    color: Color(0xFF43A047),
                    size: 24,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Select Tunnel Protocol',
                    style: AppTypography.itemTitle.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Color(0xFF757575)),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFE0E0E0)),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: protocols.length,
                separatorBuilder: (context, index) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final protocol = protocols[index];
                  final isSelected = vpnProvider.selectedProtocol.id == protocol.id;

                  return InkWell(
                    onTap: () {
                      vpnProvider.selectProtocol(protocol);
                      Navigator.of(context).pop();
                    },
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF43A047)
                              : const Color(0xFFD1D5DB),
                          width: isSelected ? 1.5 : 1.0,
                        ),
                      ),
                      child: Row(
                        children: [
                          protocol.id == 'auto_select'
                              ? Container(
                                  width: 44,
                                  height: 30,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE0F2FE),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: const Color(0xFFBAE6FD)),
                                  ),
                                  child: const Icon(
                                    Icons.language_rounded,
                                    color: Color(0xFF0284C7),
                                    size: 22,
                                  ),
                                )
                              : (protocol.countryCode == 'SA'
                                  ? const SaudiFlagWidget(width: 44, height: 30)
                                  : Container(
                                      width: 44,
                                      height: 30,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF3F4F6),
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(color: const Color(0xFFE5E7EB)),
                                      ),
                                      child: Text(
                                        protocol.flagEmoji,
                                        style: const TextStyle(fontSize: 22),
                                      ),
                                    )),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  protocol.title,
                                  style: AppTypography.itemTitle.copyWith(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  protocol.subtitle,
                                  style: AppTypography.itemSubtitle.copyWith(
                                    fontSize: 11,
                                    color: const Color(0xFF6B7280),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            constraints: const BoxConstraints(maxWidth: 95),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.ovpnBadgeGreen
                                  : const Color(0xFF4B5563),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Text(
                              protocol.badge,
                              style: AppTypography.badgeText.copyWith(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
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

