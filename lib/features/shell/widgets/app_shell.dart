import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/glass_panel.dart';
import '../../player/player_controller.dart';
import '../../player/widgets/mini_player.dart';

/// Bottom-navigation shell hosting the "Direct" and "Émissions" branches.
///
/// The nav bar and mini-player are floating overlays — not part of the page
/// layout — so page content scrolls *behind* them (visible, softened, through
/// the glass blur) instead of stopping short at a reserved bottom strip.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final onLiveTab = navigationShell.currentIndex == 0;

    return Scaffold(
      body: Stack(
        children: [
          // Full-bleed: branch pages size to the whole screen and scroll
          // under the floating bar below (they reserve their own clearance
          // via bottom padding — see kFloatingShellClearance).
          Positioned.fill(child: navigationShell),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              minimum: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // On the Direct tab the full live UI is already visible, so
                  // only an episode can appear here; on Émissions, anything.
                  MiniPlayer(suppress: onLiveTab ? PlayerKind.live : null),
                  const SizedBox(height: 8),
                  // Pill-shaped floating nav bar: fully rounded, translucent,
                  // blurred — content is meant to show faintly through it.
                  // More translucent than the mini-player (opacity 0.65 vs
                  // 0.9) so the two read as related but distinct surfaces.
                  GlassPanel(
                    borderRadius: 42,
                    opacity: 0.65,
                    child: _PillNavBar(
                      currentIndex: navigationShell.currentIndex,
                      onSelect: (index) => navigationShell.goBranch(
                        index,
                        initialLocation: index == navigationShell.currentIndex,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TabSpec {
  const _TabSpec(this.icon, this.label);
  final IconData icon;
  final String label;
}

const _kNavBarHeight = 84.0;

/// A capsule that physically slides between destinations (iOS-style), instead
/// of each tab owning its own independent highlight. There is exactly one
/// coloured background in the tree; it just moves.
class _PillNavBar extends StatelessWidget {
  const _PillNavBar({required this.currentIndex, required this.onSelect});

  final int currentIndex;
  final ValueChanged<int> onSelect;

  static const _tabs = [
    _TabSpec(Icons.radio, 'Direct'),
    _TabSpec(Icons.podcasts, 'Émissions'),
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final count = _tabs.length;
    // -1 (fully left) .. +1 (fully right) for an Alignment along the row.
    final x = -1.0 + (2.0 * currentIndex / (count - 1));

    return SizedBox(
      height: _kNavBarHeight,
      child: Stack(
        children: [
          AnimatedAlign(
            duration: const Duration(milliseconds: 300),
            // Apple's characteristic decelerate-and-settle easing.
            curve: const Cubic(0.25, 1, 0.5, 1),
            alignment: Alignment(x, 0),
            child: FractionallySizedBox(
              widthFactor: 1 / count,
              heightFactor: 1,
              // Tiny inset so the capsule reads as "inside" the bar rather
              // than exactly flush with its edges — not a big card margin.
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: scheme.primary.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            ),
          ),
          Row(
            children: [
              for (var i = 0; i < count; i++)
                Expanded(
                  child: _TabContent(
                    icon: _tabs[i].icon,
                    label: _tabs[i].label,
                    selected: i == currentIndex,
                    onTap: () => onSelect(i),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TabContent extends StatelessWidget {
  const _TabContent({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = selected ? scheme.primary : scheme.onSurfaceVariant;

    return Semantics(
      selected: selected,
      button: true,
      label: label,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          // The sliding capsule behind is the only "pressed" feedback we
          // want — no ripple/highlight rectangle drawn on top of it.
          splashFactory: NoSplash.splashFactory,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 22, color: color),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: color,
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
