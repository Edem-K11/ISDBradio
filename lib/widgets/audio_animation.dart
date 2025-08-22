
import 'package:flutter/material.dart';
import 'dart:math' as math;


class RadioWavyLineAndVynilRotation extends StatelessWidget {
  const RadioWavyLineAndVynilRotation({
    super.key,
    required AnimationController waveController,
    required bool isPlaying,
    required AnimationController vinylController,
  }) : _waveController = waveController, _isPlaying = isPlaying, _vinylController = vinylController;

  final AnimationController _waveController;
  final bool _isPlaying;
  final AnimationController _vinylController;

  @override
  Widget build(BuildContext context) {
    // Placeholder for radio streaming content
    return Stack(
      alignment: Alignment.center,
      children: [
        // Background wave animation
        AnimatedBuilder(
          animation: _waveController,
            builder: (context, child) {
              return CustomPaint(
                size: const Size(double.infinity, 200),
                painter: BackgroundWavePainter(
                  animation: _waveController,
                  isPlaying: _isPlaying,
                  waveColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
                ),
              );
            },
        ),

        // Radio Vynils animation
        AnimatedBuilder(
          animation: _vinylController,
          builder: (context, child) {
            return Transform.rotate(
              angle: _vinylController.value * 2 * math.pi,
              child: SizedBox(
                width: 260.0,
                height: 260.0,
                child: Stack(
                  alignment: Alignment.center,
                  // fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(100.0),
                      child: Image.asset(
                        'assets/images/vynil.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(
                      width: 120.0,
                      height: 120.0,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100.0),
                        child: Image.asset(
                          'assets/images/logo_isdb.png',
                          fit: BoxFit.cover,
                          colorBlendMode: BlendMode.darken,
                        ),
                      ),
                    ),
                  ]
                ),
              ),
            );
          }
        )
      ]
    );
  }
}

class AudioWaveAndLiveIndicator extends StatelessWidget {
  const AudioWaveAndLiveIndicator({
    super.key,
    required AnimationController audioWaveController,
    required bool isPlaying,
  }) : _audioWaveController = audioWaveController, _isPlaying = isPlaying;

  final AnimationController _audioWaveController;
  final bool _isPlaying;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Audio waves
        Container(
          height: 80,
          margin: const EdgeInsets.symmetric(horizontal: 35,),
          child: AnimatedBuilder(
            animation: _audioWaveController,
            builder: (context, child) {
              return CustomPaint(
                size: const Size(double.infinity, 80),
                painter: AudioWavePainter(
                  animation: _audioWaveController,
                  isPlaying: _isPlaying,
                ),
              );
            },
          ),
        ),
        
        // Live indicator
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 1000),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isPlaying 
                      ? Colors.red 
                      : Colors.grey[400],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _isPlaying ? 'LIVE' : 'OFFLINE',
                style: TextStyle(
                  color: _isPlaying 
                      ? Colors.red 
                      : Colors.grey[600],
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}



class BackgroundWavePainter extends CustomPainter {
  final Animation<double> animation;
  final bool isPlaying;
  final Color waveColor;

  BackgroundWavePainter({required this.animation, required this.isPlaying, required this.waveColor});

  @override
  void paint(Canvas canvas, Size size,) {
    if (!isPlaying) return;

    // final paint = Paint()
    //   ..color = Colors.green.withValues(alpha: 0.15)
    //   ..strokeWidth = 2
    //   ..style = PaintingStyle.stroke;

    

    // // Multiple animated circles with different frequencies
    // for (int i = 1; i <= 4; i++) {
    //   final radius = 80 + (i * 30) + (math.sin(animation.value * 2 * math.pi * i) * 10);
    //   canvas.drawCircle(center, radius, paint);
    // }

    // Wavy lines
    final wavePaint = Paint()
      ..color = waveColor
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);

    for (int wave = 0; wave < 5; wave++) {
      final path = Path();
      final waveOffset = animation.value * 2 * math.pi + (wave * math.pi / 3);
      
      for (double x = 0; x < size.width; x += 2) {
        final y = center.dy + 
          math.sin((x / 30) + waveOffset) * (4 + wave * 5) +
          math.sin((x / 15) + waveOffset * 2) * 2;
        
        if (x == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      
      canvas.drawPath(path, wavePaint);
    }
  }

  @override
  bool shouldRepaint(BackgroundWavePainter oldDelegate) {
    return animation != oldDelegate.animation || isPlaying != oldDelegate.isPlaying;
  }
}

class AudioWavePainter extends CustomPainter {
  final Animation<double> animation;
  final bool isPlaying;

  AudioWavePainter({required this.animation, required this.isPlaying});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final barWidth = 4.0;
    final barSpacing = 2.0;
    final totalBars = (size.width / (barWidth + barSpacing)).floor();

    for (int i = 0; i < totalBars; i++) {
      final x = i * (barWidth + barSpacing);
      
      // Different heights and frequencies for each bar
      final baseHeight = 20 + (i % 7) * 3;
      final animatedHeight = isPlaying 
        ? baseHeight + math.sin(animation.value * 2 * math.pi * (1 + i * 0.1)) * 15
        : baseHeight * 0.3;
      
      final height = math.max(4, animatedHeight.abs());
      
      // Color based on height
      paint.color = height > 25 
        ? Colors.green 
        : (height > 15 ? Colors.green[400]! : Colors.grey[400]!);
      
      final barRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          x.toDouble(), 
          ((size.height - height) / 2).toDouble(), 
          barWidth.toDouble(), 
          height.toDouble()
        ),
        Radius.circular(barWidth / 2),
      );
      
      canvas.drawRRect(barRect, paint);
    }
  }

  @override
  bool shouldRepaint(AudioWavePainter oldDelegate) {
    return animation != oldDelegate.animation || isPlaying != oldDelegate.isPlaying;
  }
}