import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/format.dart';
import '../../../player/player_controller.dart';
import '../../../player/widgets/equalizer_icon.dart';
import '../../data/episode.dart';

class EpisodeTile extends StatelessWidget {
  const EpisodeTile({super.key, required this.episode});

  final Episode episode;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final player = context.watch<PlayerController>();
    final isCurrent = player.isCurrentEpisode(episode);
    final isPlaying = isCurrent && player.isPlaying;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Material(
        color: isCurrent
            ? scheme.primary.withValues(alpha: 0.10)
            : scheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => context.push('/episodes/${episode.slug}', extra: episode),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Cover(url: episode.coverUrl),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        episode.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: isCurrent ? scheme.primary : scheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (episode.category != null) ...[
                            Text(
                              episode.category!.name,
                              style: TextStyle(
                                fontSize: 11,
                                color: scheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '  ·  ',
                              style: TextStyle(
                                fontSize: 11,
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                          Expanded(
                            child: Text(
                              [
                                if (episode.publishedAt != null)
                                  Format.date(episode.publishedAt!),
                                if (episode.duration != null)
                                  Format.shortDuration(episode.duration!),
                              ].join('  ·  '),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                if (isCurrent)
                  Padding(
                    padding: const EdgeInsets.all(4),
                    child: EqualizerIcon(
                      color: scheme.primary,
                      playing: isPlaying,
                      size: 22,
                    ),
                  )
                else
                  Icon(
                    Icons.play_circle_fill_rounded,
                    color: scheme.primary,
                    size: 32,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Cover extends StatelessWidget {
  const _Cover({this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    const fallback = AssetImage('assets/images/logo_isdb.png');
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: 56,
        height: 56,
        child: url == null
            ? const Image(image: fallback, fit: BoxFit.cover)
            : CachedNetworkImage(
                imageUrl: url!,
                fit: BoxFit.cover,
                placeholder: (_, __) =>
                    ColoredBox(color: scheme.surfaceContainerHighest),
                errorWidget: (_, __, ___) =>
                    const Image(image: fallback, fit: BoxFit.cover),
              ),
      ),
    );
  }
}
