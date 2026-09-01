import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Small animated "now playing" equalizer. Bars animate only while [playing].
class EqualizerIcon extends StatefulWidget {
  const EqualizerIcon({
    super.key,
    required this.color,
    this.playing = true,
    this.size = 18,
  });

  final Color color;
  final bool playing;
  final double size;

  @override
  State<EqualizerIcon> createState() => _EqualizerIconState();
}

class _EqualizerIconState extends State<EqualizerIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  @override
  void initState() {
    super.initState();
    if (widget.playing) _c.repeat();
  }

  @override
  void didUpdateWidget(EqualizerIcon old) {
    super.didUpdateWidget(old);
    if (widget.playing && !_c.isAnimating) {
      _c.repeat();
    } else if (!widget.playing && _c.isAnimating) {
      _c.stop();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) => CustomPaint(
          painter: _EqPainter(_c.value, widget.color, widget.playing),
        ),
      ),
    );
  }
}

class _EqPainter extends CustomPainter {
  _EqPainter(this.t, this.color, this.playing) : super(repaint: null);

  final double t;
  final Color color;
  final bool playing;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeCap = StrokeCap.round;
    const bars = 4;
    final gap = size.width / (bars * 2 - 1);
    for (var i = 0; i < bars; i++) {
      final phase = t * 2 * math.pi + i * 1.3;
      final f = playing ? (0.5 + 0.5 * math.sin(phase)).abs() : 0.35;
      final h = size.height * (0.25 + 0.75 * f);
      final x = i * gap * 2 + gap / 2;
      canvas.drawLine(
        Offset(x, size.height),
        Offset(x, size.height - h),
        paint..strokeWidth = gap,
      );
    }
  }

  @override
  bool shouldRepaint(_EqPainter old) =>
      old.t != t || old.playing != playing || old.color != color;
}
