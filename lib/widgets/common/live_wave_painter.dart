import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class LiveWavePainter extends CustomPainter {
  final List<double> values;
  final Color color;

  LiveWavePainter({
    required this.values,
    this.color = AppColors.neonGreen,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    final double stepX = size.width / (values.length - 1).clamp(1, 100);

    // Normalize values to fit within height
    final double minVal = values.reduce((a, b) => a < b ? a : b);
    final double maxVal = values.reduce((a, b) => a > b ? a : b);
    final double range = (maxVal - minVal).abs() == 0 ? 1.0 : (maxVal - minVal);

    for (int i = 0; i < values.length; i++) {
      final double normalizedY = (values[i] - minVal) / range;
      // Invert Y so higher is higher up, with padding
      final double y = size.height - (normalizedY * (size.height - 4) + 2);
      final double x = i * stepX;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant LiveWavePainter oldDelegate) {
    return true;
  }
}
