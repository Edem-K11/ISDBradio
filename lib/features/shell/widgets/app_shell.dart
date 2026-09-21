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
    final scheme = Theme.of(context).colorScheme;
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
                    // NavigationBar wraps its own content in a SafeArea, which
                    // pads for the *device's* status bar / gesture inset —
                    // meaningless for a pill floating well clear of both, and
                    // asymmetric here since our own SafeArea above already
                    // consumed the bottom inset but left the top one alone
                    // (top: false). Left unhandled, that phantom top padding
                    // silently added to `height`, which is why shrinking it
                    // barely moved anything. Strip it so `height` is the real,
                    // final height.
                    child: MediaQuery.removePadding(
                      context: context,
                      removeTop: true,
                      removeBottom: true,
                      removeLeft: true,
                      removeRight: true,
                      child: NavigationBar(
                        height: 84,
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        selectedIndex: navigationShell.currentIndex,
                        onDestinationSelected: (index) => navigationShell.goBranch(
                          index,
                          initialLocation: index == navigationShell.currentIndex,
                        ),
                        destinations: [
                          NavigationDestination(
                            icon: Icon(Icons.radio, color: scheme.onSurfaceVariant),
                            selectedIcon: Icon(Icons.radio, color: scheme.primary),
                            label: 'Direct',
                          ),
                          NavigationDestination(
                            icon: Icon(Icons.podcasts, color: scheme.onSurfaceVariant),
                            selectedIcon: Icon(Icons.podcasts, color: scheme.primary),
                            label: 'Émissions',
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
