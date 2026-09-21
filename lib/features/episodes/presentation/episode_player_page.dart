import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/format.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/widgets/app_state_views.dart';
import '../../player/player_controller.dart';
import '../../player/widgets/mini_player.dart';
import '../data/episode.dart';
import '../data/episode_repository.dart';
import 'widgets/episode_details_sheet.dart';

class EpisodePlayerPage extends StatefulWidget {
  const EpisodePlayerPage({super.key, this.slug, this.episode});

  final String? slug;
  final Episode? episode;

  @override
  State<EpisodePlayerPage> createState() => _EpisodePlayerPageState();
}

class _EpisodePlayerPageState extends State<EpisodePlayerPage> {
  Episode? _episode;
  String? _error;
  bool _loading = true;
  final _scrollController = ScrollController();
  String? _trackedSlug;
  PlayerController? _player;

  @override
  void initState() {
    super.initState();
    _resolve();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _player ??= context.read<PlayerController>()
      ..addListener(_onPlayerChanged);
  }

  @override
  void dispose() {
    _player?.removeListener(_onPlayerChanged);
    _scrollController.dispose();
    super.dispose();
  }

  // Jump back to the top (cover art) whenever the controller switches to a
  // different episode — via prev/next — so the new one is what's on screen.
  void _onPlayerChanged() {
    final slug = _player?.episode?.slug;
    if (slug == null || slug == _trackedSlug) return;
    _trackedSlug = slug;
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
    }
  }

  Future<void> _resolve() async {
    Episode? episode = widget.episode;
    if (episode == null && widget.slug != null) {
      try {
        episode = await EpisodeRepository().fetchEpisode(widget.slug!);
      } on ApiException catch (e) {
        if (mounted) {
          setState(() {
            _error = e.message;
            _loading = false;
          });
        }
        return;
      }
    }
    if (!mounted) return;
    if (episode == null) {
      setState(() {
        _error = 'Émission introuvable.';
        _loading = false;
      });
      return;
    }
    setState(() {
      _episode = episode;
      _loading = false;
    });
    _trackedSlug = episode.slug;
    unawaited(context.read<PlayerController>().openEpisode(episode));
  }

  // --- swipe-down-to-dismiss -------------------------------------------------
  double _pullDown = 0;
  double _dragDown = 0;

  bool _onScroll(ScrollNotification n) {
    if (n is ScrollStartNotification) {
      _pullDown = 0;
    } else if (n is OverscrollNotification &&
        n.dragDetails != null && // only a real finger drag, not the open anim
        n.overscroll < 0 &&
        n.metrics.pixels <= 0) {
      _pullDown += -n.overscroll;
    } else if (n is ScrollEndNotification && _pullDown > 60) {
      _pullDown = 0;
      Navigator.of(context).maybePop();
    }
    return false;
  }

  void _onDragDown(DragUpdateDetails d) => _dragDown += d.delta.dy;

  void _onDragEnd(DragEndDetails d) {
    final flungDown = (d.primaryVelocity ?? 0) > 150;
    final draggedDown = _dragDown > 90;
    _dragDown = 0;
    if (flungDown || draggedDown) Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    // Watched so the info button always opens the sheet for whatever the
    // player is actually on — including after prev/next moved it along.
    final player = context.watch<PlayerController>();
    final currentEpisode =
        (player.kind == PlayerKind.episode ? player.episode : null) ??
        _episode;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 52,
        // Swipe down anywhere on the bar (buttons still get their taps first).
        flexibleSpace: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onVerticalDragUpdate: _onDragDown,
          onVerticalDragEnd: _onDragEnd,
        ),
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 30),
          tooltip: 'Retour aux émissions',
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        actions: [
          if (currentEpisode != null)
            IconButton(
              icon: const Icon(Icons.info_outline_rounded),
              tooltip: "Détails de l'émission",
              onPressed: () =>
                  showEpisodeDetailsSheet(context, currentEpisode),
            ),
          const SizedBox(width: 4),
        ],
      ),
      body: _loading
          ? const AppLoader()
          : _error != null
          ? AppErrorView(message: _error!)
          : NotificationListener<ScrollNotification>(
              onNotification: _onScroll,
              child: _PlayerView(
                initialEpisode: _episode!,
                scrollController: _scrollController,
              ),
            ),
      bottomNavigationBar: const MiniPlayer(suppress: PlayerKind.episode),
    );
  }
}

class _PlayerView extends StatelessWidget {
  const _PlayerView({required this.initialEpisode, required this.scrollController});

  final Episode initialEpisode;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerController>();
    final scheme = Theme.of(context).colorScheme;
    // Once playback has started this tracks whatever the controller is
    // currently on — so tapping "next"/"previous" updates this same sheet
    // instead of needing a new route.
    final episode = player.kind == PlayerKind.episode
        ? (player.episode ?? initialEpisode)
        : initialEpisode;
    final isCurrent = player.isCurrentEpisode(episode);

    final total = isCurrent && player.duration > Duration.zero
        ? player.duration
        : (episode.duration ?? Duration.zero);

    return ListView(
      controller: scrollController,
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: const EdgeInsets.fromLTRB(24, 4, 24, 32),
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: episode.coverUrl != null
                ? CachedNetworkImage(
                    imageUrl: episode.coverUrl!,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => const _CoverFallback(),
                  )
                : const _CoverFallback(),
          ),
        ),
        const SizedBox(height: 24),
        GestureDetector(
          onTap: () => showEpisodeDetailsSheet(context, episode),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      episode.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      episode.category?.name ?? 'Émission',
                      style: TextStyle(
                        color: scheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.info_outline_rounded,
                size: 20,
                color: scheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        _ProgressBar(
          position: isCurrent ? player.position : Duration.zero,
          total: total,
          enabled: isCurrent && total > Duration.zero,
          onSeek: player.seek,
        ),
        const SizedBox(height: 20),
        _Controls(episode: episode),
      ],
    );
  }
}

/// Seekable progress bar that ignores incoming position updates while the user
/// is dragging (and briefly after), which removes the thumb "shake".
class _ProgressBar extends StatefulWidget {
  const _ProgressBar({
    required this.position,
    required this.total,
    required this.enabled,
    required this.onSeek,
  });

  final Duration position;
  final Duration total;
  final bool enabled;
  final ValueChanged<Duration> onSeek;

  @override
  State<_ProgressBar> createState() => _ProgressBarState();
}

class _ProgressBarState extends State<_ProgressBar> {
  double? _dragMs;

  @override
  void didUpdateWidget(_ProgressBar old) {
    super.didUpdateWidget(old);
    // Once the real position has caught up with where we dropped the thumb,
    // hand control back to the stream.
    if (_dragMs != null) {
      final diff = (widget.position.inMilliseconds - _dragMs!).abs();
      if (diff < 900) _dragMs = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalMs = widget.total.inMilliseconds.toDouble();
    final maxMs = totalMs <= 0 ? 1.0 : totalMs;
    final live = widget.position.inMilliseconds.toDouble().clamp(0.0, maxMs);
    final value = (_dragMs ?? live).clamp(0.0, maxMs);
    final shown = Duration(milliseconds: value.round());

    return Column(
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackShape: const RoundedRectSliderTrackShape(),
          ),
          child: Slider(
            value: value,
            max: maxMs,
            onChanged: widget.enabled
                ? (v) => setState(() => _dragMs = v)
                : null,
            onChangeEnd: widget.enabled
                ? (v) {
                    widget.onSeek(Duration(milliseconds: v.round()));
                    // keep _dragMs until didUpdateWidget clears it
                    setState(() => _dragMs = v);
                  }
                : null,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                Format.duration(shown),
                style: const TextStyle(fontSize: 12),
              ),
              Text(
                widget.total > Duration.zero
                    ? Format.duration(widget.total)
                    : '--:--',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Controls extends StatelessWidget {
  const _Controls({required this.episode});

  final Episode episode;

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerController>();
    final isCurrent = player.isCurrentEpisode(episode);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _OutlineButton(
          icon: Icons.skip_previous_rounded,
          onTap: isCurrent ? player.playPrevious : null,
        ),
        _OutlineButton(
          icon: Icons.replay_10_rounded,
          onTap: isCurrent ? player.skipBackward : null,
        ),
        _PlayButton(
          busy: isCurrent && player.isBuffering,
          playing: isCurrent && player.isPlaying,
          onTap: () => isCurrent
              ? player.toggleEpisode()
              : player.openEpisode(episode),
        ),
        _OutlineButton(
          icon: Icons.forward_10_rounded,
          onTap: isCurrent ? player.skipForward : null,
        ),
        _OutlineButton(
          icon: Icons.skip_next_rounded,
          onTap: (isCurrent && player.hasNextEpisode) ? player.playNext : null,
        ),
      ],
    );
  }
}

class _OutlineButton extends StatelessWidget {
  const _OutlineButton({required this.icon, this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return IconButton(
      iconSize: 28,
      onPressed: onTap,
      color: scheme.onSurface,
      disabledColor: scheme.onSurface.withValues(alpha: 0.25),
      icon: Icon(icon),
    );
  }
}

class _PlayButton extends StatelessWidget {
  const _PlayButton({
    required this.busy,
    required this.playing,
    required this.onTap,
  });

  final bool busy;
  final bool playing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: 76,
      height: 76,
      decoration: BoxDecoration(
        color: scheme.primary,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withValues(alpha: 0.28),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Center(
            child: busy
                ? SizedBox(
                    width: 26,
                    height: 26,
                    child: CircularProgressIndicator(
                      color: scheme.onPrimary,
                      strokeWidth: 3,
                    ),
                  )
                : Icon(
                    playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: scheme.onPrimary,
                    size: 40,
                  ),
          ),
        ),
      ),
    );
  }
}

class _CoverFallback extends StatelessWidget {
  const _CoverFallback();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: const Padding(
        padding: EdgeInsets.all(48),
        child: Image(image: AssetImage('assets/images/logo_isdb.png')),
      ),
    );
  }
}
