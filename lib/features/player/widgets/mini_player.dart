import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../player_controller.dart';

/// Compact playback bar shown above the bottom navigation (and on secondary
/// pages). It hides itself when nothing is playing, or when [suppress] matches
/// what is currently playing — so it never doubles the full-screen player.
class MiniPlayer extends StatefulWidget {
  const MiniPlayer({super.key, this.suppress});

  final PlayerKind? suppress;

  @override
  State<MiniPlayer> createState() => _MiniPlayerState();
}

class _MiniPlayerState extends State<MiniPlayer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _vinyl = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 8),
  );

  @override
  void dispose() {
    _vinyl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerController>();
    final scheme = Theme.of(context).colorScheme;

    final hidden = player.kind == PlayerKind.none ||
        player.kind == widget.suppress;

    final spinning = player.kind == PlayerKind.live && player.isPlaying;
    if (spinning && !_vinyl.isAnimating) {
      _vinyl.repeat();
    } else if (!spinning && _vinyl.isAnimating) {
      _vinyl.stop();
    }

    return AnimatedSize(
      duration: const Duration(milliseconds: 200),
      alignment: Alignment.bottomCenter,
      child: hidden
          ? const SizedBox(width: double.infinity)
          : Material(
              color: scheme.surfaceContainerHigh,
              child: InkWell(
                onTap: () => _open(context, player),
                child: SizedBox(
                  height: 60,
                  child: Column(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            const SizedBox(width: 10),
                            _leading(player, scheme),
                            const SizedBox(width: 12),
                            Expanded(child: _labels(context, player)),
                            _trailing(player, scheme),
                            const SizedBox(width: 8),
                          ],
                        ),
                      ),
                      if (player.kind == PlayerKind.episode)
                        LinearProgressIndicator(
                          value: player.episodeProgress,
                          minHeight: 2,
                          backgroundColor: scheme.surfaceContainerHighest,
                        ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  void _open(BuildContext context, PlayerController player) {
    if (player.kind == PlayerKind.live) {
      context.go('/live');
    } else if (player.episode != null) {
      context.push('/episodes/${player.episode!.slug}', extra: player.episode);
    }
  }

  Widget _leading(PlayerController player, ColorScheme scheme) {
    if (player.kind == PlayerKind.live) {
      return RotationTransition(
        turns: _vinyl,
        child: const CircleAvatar(
          radius: 18,
          backgroundColor: AppColors.green,
          backgroundImage: AssetImage('assets/images/logo_isdb.png'),
        ),
      );
    }
    final cover = player.episode?.coverUrl;
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: SizedBox(
        width: 40,
        height: 40,
        child: cover != null
            ? CachedNetworkImage(imageUrl: cover, fit: BoxFit.cover)
            : const Image(
                image: AssetImage('assets/images/logo_isdb.png'),
                fit: BoxFit.cover,
              ),
      ),
    );
  }

  Widget _labels(BuildContext context, PlayerController player) {
    final scheme = Theme.of(context).colorScheme;
    final isLive = player.kind == PlayerKind.live;
    final title = isLive
        ? player.stationName
        : (player.episode?.title ?? 'Émission');
    final subtitle = isLive
        ? (player.isBuffering ? 'Connexion…' : 'EN DIRECT')
        : (player.episode?.category?.name ?? 'Émission');

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: scheme.onSurface,
          ),
        ),
        Text(
          subtitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isLive ? FontWeight.w700 : FontWeight.w400,
            letterSpacing: isLive ? 0.8 : 0,
            color: isLive && !player.isBuffering
                ? AppColors.live
                : scheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _trailing(PlayerController player, ColorScheme scheme) {
    if (player.isBuffering) {
      return const Padding(
        padding: EdgeInsets.all(14),
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2.5),
        ),
      );
    }
    if (player.kind == PlayerKind.live) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(
              player.isPlaying
                  ? Icons.pause_rounded
                  : Icons.play_arrow_rounded,
            ),
            color: scheme.onSurface,
            onPressed: player.toggleLive,
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded),
            color: scheme.onSurfaceVariant,
            onPressed: player.stopLive,
          ),
        ],
      );
    }
    return IconButton(
      icon: Icon(
        player.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
      ),
      color: scheme.onSurface,
      onPressed: player.toggleEpisode,
    );
  }
}
