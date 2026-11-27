import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary XJ Tunnel Green Theme
  static const Color primaryGreen = Color(0xFF43A047);       // Material Green 600
  static const Color primaryGreenDark = Color(0xFF2E7D32);   // Material Green 800
  static const Color primaryGreenDeep = Color(0xFF1B5E20);   // Material Green 900
  static const Color primaryGreenLight = Color(0xFF81C784);  // Material Green 300
  static const Color accentGreen = Color(0xFF4CAF50);        // Material Green 500

  // Header and Bar Colors
  static const Color headerGreen = Color(0xFF43A047);
  static const Color bottomBarGreen = Color(0xFF43A047);

  // Background and Cards
  static const Color scaffoldBg = Color(0xFFFFFFFF);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color cardBorder = Color(0xFF374151);         // Outline in screenshot
  static const Color cardBorderLight = Color(0xFFE5E7EB);
  static const Color dialogBorder = Color(0xFF43A047);

  // Text Colors
  static const Color textDark = Color(0xFF1F2937);
  static const Color textBlack = Color(0xFF000000);
  static const Color textMuted = Color(0xFF6B7280);
  static const Color textSubtle = Color(0xFF9CA3AF);

  // Status & Badges
  static const Color statusConnected = Color(0xFF43A047);
  static const Color statusDisconnected = Color(0xFF9E9E9E);
  static const Color ovpnBadgeGreen = Color(0xFF1B5E20);
  static const Color speedBadgeGreen = Color(0xFF4CAF50);

  // Legacy & Compatibility Aliases
  static const Color neonGreen = Color(0xFF43A047);
  static const Color neonGreenBright = Color(0xFF4CAF50);
  static const Color neonGreenLight = Color(0xFF81C784);
  static const Color neonGreenDark = Color(0xFF2E7D32);
  static const Color neonGreenGlow = Color(0x3343A047);
  static const Color powerGradientStart = Color(0xFF43A047);
  static const Color powerGradientEnd = Color(0xFF2E7D32);
  static const Color darkBg = Color(0xFF090D11);
  static const Color darkCard = Color(0xFF121820);
  static const Color darkCardElevated = Color(0xFF161F28);
  static const Color darkBorder = Color(0xFF1C2732);
  static const Color darkBorderActive = Color(0xFF43A047);
  static const Color darkTextPrimary = Color(0xFFF1F5F9);
  static const Color darkTextSecondary = Color(0xFF8899A6);
  static const Color darkTextMuted = Color(0xFF5B7083);
  static const Color lightBg = Color(0xFFF4F7F6);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightCardElevated = Color(0xFFF8FAFC);
  static const Color lightBorder = Color(0xFFE2E8F0);
  static const Color lightBorderActive = Color(0xFF43A047);
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF475569);
  static const Color lightTextMuted = Color(0xFF94A3B8);
  static const Color badgeSshBg = Color(0xFF43A047);
  static const Color badgeSshText = Color(0xFF090D11);
  static const Color badgeTcpBg = Color(0xFF1E293B);
  static const Color badgeTcpText = Color(0xFF94A3B8);
  static const Color badgeSniBg = Color(0xFF4D7C0F);
  static const Color badgeSniText = Color(0xFFD9F99D);
  static const Color badgeOvpnBg = Color(0xFF047857);
  static const Color badgeOvpnText = Color(0xFFA7F3D0);
  static const Color badgeVlessBg = Color(0xFF365314);
  static const Color badgeVlessText = Color(0xFFBEF264);
  static const Color badgePayloadBg = Color(0xFF3F6212);
  static const Color badgePayloadText = Color(0xFFD9F99D);
  static const Color onlineGreen = Color(0xFF43A047);
  static const Color offlineRed = Color(0xFFEF4444);
  static const Color warningOrange = Color(0xFFF59E0B);

  // Gradients
  static const LinearGradient buttonGreenGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF43A047),
      Color(0xFF2E7D32),
    ],
  );

  static const LinearGradient drawerHeaderGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF388E3C),
      Color(0xFF1B5E20),
    ],
  );
}
