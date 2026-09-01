import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Holds the branch navigators in a [PageView] so moving between the Direct and
/// Émissions tabs slides like a drawer (the finger drags the page, with a
/// snap on release) instead of switching instantly.
class ShellPager extends StatefulWidget {
  const ShellPager({
    super.key,
    required this.navigationShell,
    required this.children,
  });

  final StatefulNavigationShell navigationShell;
  final List<Widget> children;

  @override
  State<ShellPager> createState() => _ShellPagerState();
}

class _ShellPagerState extends State<ShellPager> {
  late final PageController _controller =
      PageController(initialPage: widget.navigationShell.currentIndex);

  @override
  void didUpdateWidget(ShellPager old) {
    super.didUpdateWidget(old);
    final target = widget.navigationShell.currentIndex;
    // The bottom bar (or a drawer link) changed the branch: animate there.
    if (_controller.hasClients && _controller.page?.round() != target) {
      _controller.animateToPage(
        target,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    if (index != widget.navigationShell.currentIndex) {
      widget.navigationShell.goBranch(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: _controller,
      onPageChanged: _onPageChanged,
      children: [
        for (final child in widget.children)
          _KeepAlive(child: child),
      ],
    );
  }
}

/// Keeps an off-screen branch mounted so its scroll position and audio-driven
/// state survive a swipe to the other tab.
class _KeepAlive extends StatefulWidget {
  const _KeepAlive({required this.child});

  final Widget child;

  @override
  State<_KeepAlive> createState() => _KeepAliveState();
}

class _KeepAliveState extends State<_KeepAlive>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}
