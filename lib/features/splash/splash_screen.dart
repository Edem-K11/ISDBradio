import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Branded loading screen shown at launch, on the same flat green as the native
/// splash so the hand-off is seamless. Purely visual — the bootstrapper swaps it
/// for the app once initialisation finishes.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  static const _green = Color(0xFF15693B);

  late final AnimationController _intro = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  )..forward();

  @override
  void dispose() {
    _intro.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _green,
      body: Container(
        color: _green,
        alignment: Alignment.center,
        child: FadeTransition(
          opacity: CurvedAnimation(parent: _intro, curve: Curves.easeOut),
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.94, end: 1).animate(
              CurvedAnimation(parent: _intro, curve: Curves.easeOutCubic),
            ),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _LogoWithHeadphones(),
                SizedBox(height: 22),
                Text(
                  'RADIO ISDB',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The plain ISDB emblem with a flat, drawn headset over it — no glow, no
/// photo-composite, just clean shapes in the brand colours.
class _LogoWithHeadphones extends StatelessWidget {
  const _LogoWithHeadphones();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 168,
      height: 168,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(168, 168),
            painter: _HeadphonesPainter(),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(6),
              child: const Image(
                image: AssetImage('assets/images/logo_isdb.png'),
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// White headband arc + two red ear cups wrapping the logo — flat, no shadows.
class _HeadphonesPainter extends CustomPainter {
  static const _cupColor = Color(0xFFE23B2E);

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;

    final band = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 11
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r - 5),
      math.pi + 0.55,
      math.pi - 1.1,
      false,
      band,
    );

    final cup = Paint()..color = _cupColor;
    final rrect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(3, c.dy), width: 20, height: 34),
      const Radius.circular(10),
    );
    canvas.drawRRect(rrect, cup);
    canvas.drawRRect(rrect.shift(Offset(size.width - 6, 0)), cup);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
