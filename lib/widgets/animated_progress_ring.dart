import 'package:flutter/material.dart';
import 'dart:math' as math;

class AnimatedProgressRing extends StatefulWidget {
  final String label;
  final String value;
  final double percent;
  final Color color;
  final TextStyle valueStyle;
  final TextStyle labelStyle;
  final double radius;

  const AnimatedProgressRing({
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
  State<AnimatedProgressRing> createState() => _AnimatedProgressRingState();
}

class _AnimatedProgressRingState extends State<AnimatedProgressRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: widget.percent).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomPaint(
              size: Size(widget.radius * 2, widget.radius * 2),
              painter: _AnimatedRingPainter(
                percent: _animation.value,
                color: widget.color,
              ),
              child: SizedBox(
                width: widget.radius * 2,
                height: widget.radius * 2,
                child: Center(
                  child: Text(widget.value, style: widget.valueStyle),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.label,
              style: widget.labelStyle,
              textAlign: TextAlign.center,
            ),
          ],
        );
      },
    );
  }
}

class _AnimatedRingPainter extends CustomPainter {
  final double percent;
  final Color color;

  _AnimatedRingPainter({required this.percent, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8.0;

    paint.color = color.withAlpha(51);
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
  bool shouldRepaint(_AnimatedRingPainter oldDelegate) =>
      percent != oldDelegate.percent || color != oldDelegate.color;
}
