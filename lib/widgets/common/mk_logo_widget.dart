import 'package:flutter/material.dart';

class MkLogoWidget extends StatelessWidget {
  final double size;
  final bool withGlow;

  const MkLogoWidget({
    super.key,
    this.size = 40,
    this.withGlow = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          colors: [
            Color(0xFF1B3820),
            Color(0xFF0A140B),
            Color(0xFF000000),
          ],
        ),
        border: Border.all(
          color: const Color(0xFF00E676),
          width: size * 0.045,
        ),
        boxShadow: withGlow
            ? [
                BoxShadow(
                  color: const Color(0xFF00E676).withValues(alpha: 0.5),
                  blurRadius: size * 0.3,
                  spreadRadius: 2,
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'MK',
              style: TextStyle(
                color: const Color(0xFF00E676),
                fontSize: size * 0.36,
                fontWeight: FontWeight.w900,
                fontFamily: 'monospace',
                letterSpacing: -0.5,
                height: 1.0,
                shadows: [
                  Shadow(
                    color: const Color(0xFF00E676).withValues(alpha: 0.8),
                    blurRadius: 6,
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: size * 0.04),
              padding: EdgeInsets.symmetric(
                horizontal: size * 0.1,
                vertical: size * 0.02,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF004D20),
                borderRadius: BorderRadius.circular(size * 0.1),
              ),
              child: Text(
                '-VPN-',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: size * 0.14,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  height: 1.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Backward compatibility aliases
typedef XjLogoWidget = MkLogoWidget;
typedef MkTunnelLogoWidget = MkLogoWidget;
