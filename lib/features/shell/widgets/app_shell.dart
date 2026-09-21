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
                  //
                  // Custom-built (not Material's NavigationBar): M3's
                  // indicator only ever wraps the icon, and the label sits
                  // outside it with no background of its own. Here the
                  // highlight pill wraps icon *and* label together.
                  GlassPanel(
                    borderRadius: 42,
                    opacity: 0.65,
                    child: SizedBox(
                      height: 84,
                      child: Row(
                        children: [
                          _NavTab(
                            icon: Icons.radio,
                            label: 'Direct',
                            selected: navigationShell.currentIndex == 0,
                            onTap: () => navigationShell.goBranch(
                              0,
                              initialLocation: navigationShell.currentIndex == 0,
                            ),
                          ),
                          _NavTab(
                            icon: Icons.podcasts,
                            label: 'Émissions',
                            selected: navigationShell.currentIndex == 1,
                            onTap: () => navigationShell.goBranch(
                              1,
                              initialLocation: navigationShell.currentIndex == 1,
                            ),
                          ),
                        ],
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

class _NavTab extends StatelessWidget {
  const _NavTab({
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

    return Expanded(
      child: Semantics(
        selected: selected,
        button: true,
        label: label,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onTap,
            child: Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOut,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: selected
                      ? scheme.primary.withValues(alpha: 0.16)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(24),
                ),
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
        ),
      ),
    );
  }
}
