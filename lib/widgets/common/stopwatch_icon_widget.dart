import 'package:flutter/material.dart';

class StopwatchIconWidget extends StatelessWidget {
  final double size;

  const StopwatchIconWidget({
    super.key,
    this.size = 36,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size * 1.25,
      height: size,
      child: Stack(
        alignment: Alignment.centerRight,
        children: [
          // Motion / speed lines on left
          Positioned(
            left: 0,
            top: size * 0.2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: size * 0.3,
                  height: 2,
                  decoration: BoxDecoration(
                    color: const Color(0xFF03A9F4).withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
                const SizedBox(height: 3),
                Container(
                  width: size * 0.22,
                  height: 2,
                  decoration: BoxDecoration(
                    color: const Color(0xFF03A9F4).withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
                const SizedBox(height: 3),
                Container(
                  width: size * 0.35,
                  height: 2,
                  decoration: BoxDecoration(
                    color: const Color(0xFF03A9F4).withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ],
            ),
          ),

          // Main stopwatch
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(
                color: const Color(0xFF0288D1),
                width: 2.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0288D1).withValues(alpha: 0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Top stopwatch knob
                  Positioned(
                    top: 2,
                    child: Container(
                      width: 4,
                      height: 3,
                      color: const Color(0xFFFFB300),
                    ),
                  ),
                  // Center hand
                  Container(
                    width: 2,
                    height: size * 0.35,
                    alignment: Alignment.topCenter,
                    child: Container(
                      width: 2,
                      height: size * 0.2,
                      color: const Color(0xFF01579B),
                    ),
                  ),
                  // Center dot
                  Container(
                    width: 4,
                    height: 4,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE53935),
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

