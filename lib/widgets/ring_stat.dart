import 'package:flutter/material.dart';
import 'dart:math' as math;

class RingStat extends StatelessWidget {
  final String label;
  final String value;
  final double percent;
  final Color color;
  final TextStyle valueStyle;
  final TextStyle labelStyle;
  final double radius;

  const RingStat({
    super.key,
    required this.label,
    required this.value,
    required this.percent,
    required this.color,
    required this.valueStyle,
    required this.labelStyle,
    this.radius = 50.0,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomPaint(
          size: Size(radius * 2, radius * 2),
          painter: _RingPainter(
            percent: percent,
            color: color,
          ),
          child: SizedBox(
            width: radius * 2,
            height: radius * 2,
            child: Center(
              child: Text(value, style: valueStyle),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: labelStyle,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _RingPainter extends CustomPainter {
  final double percent;
  final Color color;

  _RingPainter({required this.percent, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8.0;

    // Usar withAlpha en lugar de withOpacity
    paint.color = color.withAlpha(51); // 0.2 * 255 ≈ 51
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      math.min(size.width, size.height) / 2,
      paint,
    );

    paint.color = color;
    canvas.drawArc(
      Rect.fromCircle(
        center: Offset(size.width / 2, size.height / 2),
        radius: math.min(size.width, size.height) / 2,
      ),
      -math.pi / 2,
      2 * math.pi * percent,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) => 
    percent != oldDelegate.percent || color != oldDelegate.color;
}
