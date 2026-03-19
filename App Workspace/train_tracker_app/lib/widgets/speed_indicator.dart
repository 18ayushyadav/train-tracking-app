import 'dart:math' as math;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class SpeedIndicator extends StatelessWidget {
  final double speedKmh;
  const SpeedIndicator({super.key, required this.speedKmh});

  @override
  Widget build(BuildContext context) {
    final fraction = (speedKmh / 180).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Text('speed'.tr(), style: const TextStyle(color: Colors.white38, fontSize: 11, letterSpacing: 1)),
          const SizedBox(height: 12),
          SizedBox(
            width: 100, height: 100,
            child: CustomPaint(
              painter: _SpeedometerPainter(fraction: fraction),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('${speedKmh.toStringAsFixed(0)}',
                        style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                    const Text('km/h', style: TextStyle(color: Colors.white38, fontSize: 10)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SpeedometerPainter extends CustomPainter {
  final double fraction;
  _SpeedometerPainter({required this.fraction});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;
    final start = math.pi * 0.75;
    final sweep = math.pi * 1.5;

    // Background arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      start, sweep, false,
      Paint()..color = Colors.white12..style = PaintingStyle.stroke..strokeWidth = 8..strokeCap = StrokeCap.round,
    );

    // Value arc
    final color = fraction < 0.5
        ? Color.lerp(const Color(0xFF4CAF50), const Color(0xFFFFB300), fraction * 2)!
        : Color.lerp(const Color(0xFFFFB300), const Color(0xFFEF5350), (fraction - 0.5) * 2)!;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      start, sweep * fraction, false,
      Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 8..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_SpeedometerPainter old) => old.fraction != fraction;
}
