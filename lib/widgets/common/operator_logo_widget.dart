import 'package:flutter/material.dart';
import '../../models/network_payload.dart';

class OperatorLogoWidget extends StatelessWidget {
  final NetworkIconType iconType;
  final double size;

  const OperatorLogoWidget({
    super.key,
    required this.iconType,
    this.size = 38,
  });

  @override
  Widget build(BuildContext context) {
    switch (iconType) {
      case NetworkIconType.mobily:
        return _buildMobilyLogo();
      case NetworkIconType.stc:
        return _buildStcLogo();
      case NetworkIconType.jawwy:
        return _buildJawwyLogo();
      case NetworkIconType.salam:
        return _buildSalamLogo();
      case NetworkIconType.globe:
        return _buildGlobeLogo();
      case NetworkIconType.ethioSim:
      case NetworkIconType.sim5g:
        return _buildSim5GLogo();
      case NetworkIconType.airtel:
        return _buildAirtelLogo();
      case NetworkIconType.wifi:
        return _buildWifiLogo();
    }
  }

  Widget _buildMobilyLogo() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE0E0E0), width: 0.8),
      ),
      padding: const EdgeInsets.all(2),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.all_inclusive_rounded,
            size: size * 0.48,
            color: const Color(0xFF00A3E0),
          ),
          Text(
            'mobily',
            style: TextStyle(
              color: const Color(0xFF00A3E0),
              fontSize: size * 0.17,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.2,
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStcLogo() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF4F008C), // STC signature purple
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          'stc',
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.38,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildJawwyLogo() {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Color(0xFFFF5E00),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          'جَوّي',
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.32,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildSalamLogo() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF00B050),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.water_drop_rounded,
              color: Colors.white,
              size: 16,
            ),
            Text(
              'salam',
              style: TextStyle(
                color: Colors.white,
                fontSize: size * 0.18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlobeLogo() {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            Color(0xFF29B6F6),
            Color(0xFF0288D1),
            Color(0xFF01579B),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.public_rounded,
          color: const Color(0xFF69F0AE),
          size: size * 0.62,
        ),
      ),
    );
  }

  Widget _buildSim5GLogo() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF0288D1), width: 1.2),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.sim_card_outlined,
              size: size * 0.44,
              color: const Color(0xFF0288D1),
            ),
            Text(
              '5G',
              style: TextStyle(
                fontSize: size * 0.22,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF0288D1),
                height: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAirtelLogo() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFEF4444), width: 1.2),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.all_inclusive_rounded,
              color: const Color(0xFFDC2626),
              size: size * 0.44,
            ),
            Text(
              'airtel',
              style: TextStyle(
                color: const Color(0xFFDC2626),
                fontSize: size * 0.22,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.3,
                height: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWifiLogo() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF9CA3AF), width: 1.0),
      ),
      child: Center(
        child: Icon(
          Icons.wifi_rounded,
          color: const Color(0xFF1F2937),
          size: size * 0.65,
        ),
      ),
    );
  }
}
