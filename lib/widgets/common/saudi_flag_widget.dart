import 'package:flutter/material.dart';

class SaudiFlagWidget extends StatelessWidget {
  final double width;
  final double height;

  const SaudiFlagWidget({
    super.key,
    this.width = 44,
    this.height = 30,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFF006C35), // Saudi Flag deep green
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Simplified Arabic Shahada representation
            Text(
              'لا إله إلا الله',
              style: TextStyle(
                color: Colors.white,
                fontSize: height * 0.28,
                fontWeight: FontWeight.bold,
                height: 1.0,
              ),
            ),
            const SizedBox(height: 1),
            // White sword representation
            Container(
              width: width * 0.55,
              height: 1.5,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}

