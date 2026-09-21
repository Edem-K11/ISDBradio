import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../player/player_controller.dart';
import '../../player/widgets/mini_player.dart';

/// Bottom-navigation shell hosting the "Direct" and "Émissions" branches.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final onLiveTab = navigationShell.currentIndex == 0;
    // Same tone the NavigationBar already used, kept explicit so the floating
    // card and the bar inside it always match.
    final barBackground = theme.navigationBarTheme.backgroundColor ??
        scheme.surface;

    return Scaffold(
      // The branch pages live in a PageView (see ShellPager) so switching tabs
      // slides like a drawer.
      body: navigationShell,
      // A single floating rounded card — mini-player docked directly on top of
      // the tab bar, margined off the screen edges. The margin shows the same
      // colour as the page behind it, so it reads as floating rather than cut.
      bottomNavigationBar: SafeArea(
        top: false,
        minimum: const EdgeInsets.fromLTRB(12, 0, 12, 8),
        child: Container(
          decoration: BoxDecoration(
            color: barBackground,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.14),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // On the Direct tab the full live UI is already visible, so only
              // an episode can appear here; on the Émissions tab anything can.
              MiniPlayer(suppress: onLiveTab ? PlayerKind.live : null),
              NavigationBar(
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
            ],
          ),
        ),
      ),
    );
  }
}
