import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/episodes/data/episode.dart';
import '../features/episodes/presentation/episode_player_page.dart';
import '../features/episodes/presentation/episodes_page.dart';
import '../features/episodes/presentation/search_page.dart';
import '../features/info/presentation/info_page.dart';
import '../features/live/presentation/live_page.dart';
import '../features/settings/presentation/appearance_page.dart';
import '../features/shell/widgets/app_shell.dart';
import '../features/shell/widgets/shell_pager.dart';

final _rootKey = GlobalKey<NavigatorState>();
final _liveKey = GlobalKey<NavigatorState>();
final _episodesKey = GlobalKey<NavigatorState>();

/// Bottom-sheet-style page: slides up on open, down on close, with an eased
/// curve so the swipe-to-dismiss feels smooth rather than instant.
CustomTransitionPage<void> _slideUpPage({
  required LocalKey key,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: key,
    child: child,
    transitionDuration: const Duration(milliseconds: 380),
    reverseTransitionDuration: const Duration(milliseconds: 320),
    transitionsBuilder: (context, animation, secondary, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 1),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      );
    },
  );
}

/// Application routes. A [StatefulShellRoute] keeps a persistent state for each
/// bottom-navigation branch; secondary screens are pushed on the root navigator.
final GoRouter appRouter = GoRouter(
  navigatorKey: _rootKey,
  initialLocation: '/live',
  routes: [
    StatefulShellRoute(
      builder: (context, state, navigationShell) =>
          AppShell(navigationShell: navigationShell),
      navigatorContainerBuilder: (context, navigationShell, children) =>
          ShellPager(navigationShell: navigationShell, children: children),
      branches: [
        StatefulShellBranch(
          navigatorKey: _liveKey,
          routes: [
            GoRoute(
              path: '/live',
              builder: (context, state) => const LivePage(),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _episodesKey,
          routes: [
            GoRoute(
              path: '/episodes',
              builder: (context, state) => const EpisodesPage(),
              routes: [
                GoRoute(
                  path: 'search',
                  parentNavigatorKey: _rootKey,
                  builder: (context, state) => const EpisodesSearchPage(),
                ),
                GoRoute(
                  path: ':slug',
                  parentNavigatorKey: _rootKey,
                  pageBuilder: (context, state) => _slideUpPage(
                    key: state.pageKey,
                    child: EpisodePlayerPage(
                      slug: state.pathParameters['slug'],
                      episode: state.extra is Episode
                          ? state.extra as Episode
                          : null,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/info',
      parentNavigatorKey: _rootKey,
      builder: (context, state) => const InfoPage(),
    ),
    GoRoute(
      path: '/settings/appearance',
      parentNavigatorKey: _rootKey,
      builder: (context, state) => const AppearancePage(),
    ),
  ],
);
