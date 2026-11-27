import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class PowerButtonGauge extends StatefulWidget {
  final bool isConnected;
  final bool isConnecting;
  final VoidCallback onTap;

  const PowerButtonGauge({
    super.key,
    required this.isConnected,
    this.isConnecting = false,
    required this.onTap,
  });

  @override
  State<PowerButtonGauge> createState() => _PowerButtonGaugeState();
}

class _PowerButtonGaugeState extends State<PowerButtonGauge>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _animController,
          builder: (context, child) {
            final pulseScale = widget.isConnected
                ? 1.0 + 0.025 * sin(_animController.value * 2 * pi)
                : 1.0;

            return Transform.scale(
              scale: pulseScale,
              child: SizedBox(
                width: 260,
                height: 260,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer Gauge Ticks & Progress Arc
                    CustomPaint(
                      size: const Size(260, 260),
                      painter: _GaugePainter(
                        isConnected: widget.isConnected,
                        isConnecting: widget.isConnecting,
                        progress: widget.isConnected
                            ? 0.72 + 0.08 * sin(_animController.value * 2 * pi)
                            : (widget.isConnecting ? _animController.value : 0.0),
                        isDark: isDark,
                      ),
                    ),

                    // Outer Glow Shadow (when connected)
                    if (widget.isConnected)
                      Container(
                        width: 170,
                        height: 170,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.neonGreen.withValues(alpha: isDark ? 0.45 : 0.25),
                              blurRadius: 36,
                              spreadRadius: 8,
                            ),
                          ],
                        ),
                      ),

                    // Inner Circular Power Button
                    Container(
                      width: 165,
                      height: 165,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: widget.isConnected
                            ? const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppColors.powerGradientStart,
                                  AppColors.powerGradientEnd,
                                ],
                              )
                            : (widget.isConnecting
                                ? LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      AppColors.neonGreen.withValues(alpha: 0.6),
                                      AppColors.neonGreenDark.withValues(alpha: 0.6),
                                    ],
                                  )
                                : LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: isDark
                                        ? [const Color(0xFF1E2833), const Color(0xFF141C24)]
                                        : [const Color(0xFFE2E8F0), const Color(0xFFCBD5E1)],
                                  )),
                        border: Border.all(
                          color: widget.isConnected
                              ? Colors.white.withValues(alpha: 0.35)
                              : (isDark ? const Color(0xFF2E3D4D) : const Color(0xFF94A3B8)),
                          width: 2.5,
                        ),
                      ),
                      child: Center(
                        child: widget.isConnecting
                            ? const SizedBox(
                                width: 44,
                                height: 44,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Icon(
                                Icons.power_settings_new_rounded,
                                size: 68,
                                color: widget.isConnected
                                    ? const Color(0xFF0D1810)
                                    : (isDark
                                        ? const Color(0xFF64748B)
                                        : const Color(0xFF64748B)),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  final bool isConnected;
  final bool isConnecting;
  final double progress;
  final bool isDark;

  _GaugePainter({
    required this.isConnected,
    required this.isConnecting,
    required this.progress,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = size.width / 2 - 8;
    final tickLength = 10.0;
    const totalTicks = 60;

    // Paint for background ring
    final ringPaint = Paint()
      ..color = (isDark ? const Color(0xFF1E2A36) : const Color(0xFFCBD5E1))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    canvas.drawCircle(center, outerRadius, ringPaint);

    // Draw Speedometer radial ticks
    final tickPaint = Paint()
      ..color = isDark ? const Color(0xFF283B4A) : const Color(0xFF94A3B8)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    final activeTickPaint = Paint()
      ..color = AppColors.neonGreen
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < totalTicks; i++) {
      final angle = (i / totalTicks) * 2 * pi - pi / 2;
      final isTickActive = isConnected && (i / totalTicks) <= progress;

      final p1 = Offset(
        center.dx + (outerRadius - tickLength) * cos(angle),
        center.dy + (outerRadius - tickLength) * sin(angle),
      );
      final p2 = Offset(
        center.dx + outerRadius * cos(angle),
        center.dy + outerRadius * sin(angle),
      );

      canvas.drawLine(p1, p2, isTickActive ? activeTickPaint : tickPaint);
    }

    // Draw active progress Arc on outer perimeter
    if (isConnected || isConnecting) {
      final arcPaint = Paint()
        ..color = AppColors.neonGreen
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.0
        ..strokeCap = StrokeCap.round;

      const startAngle = -pi / 2;
      final sweepAngle = 2 * pi * progress;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: outerRadius),
        startAngle,
        sweepAngle,
        false,
        arcPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.isConnected != isConnected ||
        oldDelegate.isDark != isDark;
  }
}
