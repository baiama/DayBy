import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Determinate ring from the home screen card: olive progress on an
/// accent track, starting at 12 o'clock.
class ProgressRing extends StatelessWidget {
  const ProgressRing({
    super.key,
    required this.value,
    required this.color,
    required this.trackColor,
    this.size = 114,
    this.thickness = 8,
    this.child,
  });

  final double value;
  final Color color;
  final Color trackColor;
  final double size;
  final double thickness;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(end: value.clamp(0, 1)),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
      builder: (context, v, _) => CustomPaint(
        size: Size.square(size),
        painter: _RingPainter(v, color, trackColor, thickness),
        child: SizedBox.square(dimension: size, child: Center(child: child)),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.value, this.color, this.track, this.thickness);

  final double value;
  final Color color;
  final Color track;
  final double thickness;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(thickness / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.round;
    // Material 3 style: a small gap between the active arc and the track.
    const gap = 0.12;
    const start = -math.pi / 2;
    final sweep = 2 * math.pi * value;
    if (value < 1) {
      final trackStart = start + sweep + (value > 0 ? gap : 0);
      final trackSweep = 2 * math.pi - sweep - (value > 0 ? 2 * gap : 0);
      if (trackSweep > 0) {
        canvas.drawArc(rect, trackStart, trackSweep, false, paint..color = track);
      }
    }
    if (value > 0) {
      canvas.drawArc(rect, start, sweep, false, paint..color = color);
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.value != value || old.color != color || old.track != track;
}
