import 'package:flutter/material.dart';

/// Brand palette for Radio ISDB, derived from the institute logo
/// (Don Bosco green, coral-red figures, cream disc).
abstract final class AppColors {
  /// Primary Don Bosco green.
  static const Color green = Color(0xFF1B7A3A);
  static const Color greenDark = Color(0xFF0F5427);
  static const Color greenLight = Color(0xFF4CAF6D);

  /// Accent taken from the logo figures.
  static const Color coral = Color(0xFFE8412F);

  /// Warm off-white light background — flat equivalent of #F8F4F1 at 80% over
  /// white. Used everywhere (scaffold, app bars, nav bar backdrop) so the whole
  /// UI reads as one continuous surface.
  static const Color lightBackground = Color(0xFFF9F6F4);

  /// Slightly raised light surface for cards / chips.
  static const Color lightSurface = Color(0xFFFFFFFF);

  /// Neutral cream from the logo disc, kept for reference.
  static const Color cream = Color(0xFFF3F7F1);

  /// "On air" indicator.
  static const Color live = Color(0xFFE53935);
}
