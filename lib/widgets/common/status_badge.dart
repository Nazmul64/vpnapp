import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';

class StatusBadge extends StatelessWidget {
  final String label;

  const StatusBadge({
    super.key,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color textColor;

    switch (label.toUpperCase()) {
      case 'SSH':
        bg = const Color(0xFF65A30D); // Lime green
        textColor = const Color(0xFFECFCCB);
        break;
      case 'TCP':
        bg = const Color(0xFF1E293B);
        textColor = const Color(0xFF94A3B8);
        break;
      case 'SNI':
        bg = const Color(0xFF3F6212);
        textColor = const Color(0xFFD9F99D);
        break;
      case 'OVPN':
        bg = const Color(0xFF065F46);
        textColor = const Color(0xFFA7F3D0);
        break;
      case 'VLESS':
        bg = const Color(0xFF4D7C0F);
        textColor = const Color(0xFFECFCCB);
        break;
      case 'WS':
        bg = const Color(0xFF1E293B);
        textColor = const Color(0xFF94A3B8);
        break;
      case 'PROXY+PAYLOAD':
      case 'PAYLOAD':
        bg = const Color(0xFF365314);
        textColor = const Color(0xFFD9F99D);
        break;
      default:
        bg = AppColors.darkCardElevated;
        textColor = AppColors.neonGreen;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: AppTypography.caption.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
          fontSize: 10,
        ),
      ),
    );
  }
}
