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
    final scheme = Theme.of(context).colorScheme;
    final onLiveTab = navigationShell.currentIndex == 0;

    return Scaffold(
      // The branch pages live in a PageView (see ShellPager) so switching tabs
      // slides like a drawer.
      body: navigationShell,
      // ColoredBox so the nav bar's rounded top corners reveal the same
      // background as the body — no darker patch peeking through.
      bottomNavigationBar: ColoredBox(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // On the Direct tab the full live UI is already visible, so only an
            // episode can appear here; on the Émissions tab anything can.
            MiniPlayer(suppress: onLiveTab ? PlayerKind.live : null),
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(22),
                topRight: Radius.circular(22),
              ),
              child: NavigationBar(
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
          ],
        ),
      ),
    );
  }
}
