import 'dart:ui';

import 'package:flutter/material.dart';

/// Bottom padding a scrollable page needs so its last item can scroll clear
/// of the floating mini-player + pill navigation bar (see [AppShell]).
const double kFloatingShellClearance = 188;

/// Same, for pages that only float a [MiniPlayer] above them (no nav bar).
const double kFloatingBarClearance = 92;

/// A translucent, blurred "glass" surface for the floating mini-player and
/// navigation bar — page content stays faintly visible behind them instead of
/// being hidden behind a solid panel, while a border + shadow keep the panel
/// legible as its own floating surface rather than a continuation of the page.
class GlassPanel extends StatelessWidget {
  const GlassPanel({
    super.key,
    required this.child,
    this.borderRadius = 24,
    this.blurSigma = 18,
    // How opaque the tinted surface is. Higher = reads as a clearer, more
    // "solid" panel (the mini-player); lower = more atmospheric, lets more
    // of the page bleed through (the nav bar) — see AppShell for the split.
    this.opacity = 0.7,
  });

  final Widget child;
  final double borderRadius;
  final double blurSigma;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tint = isDark ? Colors.black : Colors.white;
    final radius = BorderRadius.circular(borderRadius);

    return DecoratedBox(
      // The shadow lives on this *outer* box, outside the ClipRRect below —
      // inside it, the clip would trim the shadow away entirely and the
      // panel would read as flush with the page instead of floating above it.
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.45)
                : const Color.fromRGBO(60, 45, 35, 0.09),
            blurRadius: 24,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: tint.withValues(alpha: isDark ? opacity * 0.9 : opacity),
              borderRadius: radius,
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.10)
                    : const Color.fromRGBO(80, 60, 50, 0.10),
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
