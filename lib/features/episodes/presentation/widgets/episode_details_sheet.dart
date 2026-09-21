import 'package:flutter/material.dart';

import '../../../../core/format.dart';
import '../../data/episode.dart';

/// Full episode info (title, category, date, duration, description…) in a
/// bottom sheet, so the player screen itself can stay uncluttered.
Future<void> showEpisodeDetailsSheet(BuildContext context, Episode episode) {
  final scheme = Theme.of(context).colorScheme;
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: scheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) => _EpisodeDetailsSheet(episode: episode),
  );
}

class _EpisodeDetailsSheet extends StatelessWidget {
  const _EpisodeDetailsSheet({required this.episode});

  final Episode episode;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final hasDescription =
        episode.description != null && episode.description!.isNotEmpty;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: scheme.onSurfaceVariant.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              episode.title,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (episode.category != null)
                  _Chip(
                    icon: Icons.podcasts_rounded,
                    label: episode.category!.name,
                  ),
                if (episode.publishedAt != null)
                  _Chip(
                    icon: Icons.calendar_today_rounded,
                    label: Format.date(episode.publishedAt!),
                  ),
                if (episode.duration != null)
                  _Chip(
                    icon: Icons.schedule_rounded,
                    label: Format.shortDuration(episode.duration!),
                  ),
                _Chip(
                  icon: Icons.play_circle_outline_rounded,
                  label: '${episode.playsCount} écoute'
                      '${episode.playsCount > 1 ? 's' : ''}',
                ),
              ],
            ),
            const SizedBox(height: 20),
            Flexible(
              child: SingleChildScrollView(
                child: Text(
                  hasDescription
                      ? episode.description!
                      : 'Aucune description pour cette émission.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.5,
                    color: hasDescription
                        ? scheme.onSurface
                        : scheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: scheme.onSurfaceVariant),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
