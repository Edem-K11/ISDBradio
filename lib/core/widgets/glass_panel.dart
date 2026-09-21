import 'dart:ui';

import 'package:flutter/material.dart';

/// Bottom padding a scrollable page needs so its last item can scroll clear
/// of the floating mini-player + pill navigation bar (see [AppShell]).
const double kFloatingShellClearance = 168;

/// Same, for pages that only float a [MiniPlayer] above them (no nav bar).
const double kFloatingBarClearance = 92;

/// A translucent, blurred "glass" surface for the floating mini-player and
/// navigation bar — page content stays faintly visible behind them instead of
/// being hidden behind a solid panel.
class GlassPanel extends StatelessWidget {
  const GlassPanel({
    super.key,
    required this.child,
    this.borderRadius = 24,
    this.blurSigma = 18,
  });

  final Widget child;
  final double borderRadius;
  final double blurSigma;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tint = isDark ? Colors.black : Colors.white;
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: DecoratedBox(
          decoration: BoxDecoration(
            // Translucent, not opaque — content behind should stay faintly
            // visible through the blur.
            color: tint.withValues(alpha: isDark ? 0.55 : 0.68),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: Colors.white.withValues(alpha: isDark ? 0.06 : 0.55),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.14),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
