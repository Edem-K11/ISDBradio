import 'package:flutter_test/flutter_test.dart';
import 'package:isdb_radio/features/episodes/data/episode.dart';
import 'package:isdb_radio/features/episodes/data/paginated.dart';

void main() {
  group('Episode', () {
    test('parses a full payload including nested category', () {
      final e = Episode.fromJson({
        'title': 'Le journal',
        'slug': 'le-journal',
        'description': 'desc',
        'audio_url': 'https://example.com/a.mp3',
        'cover_url': 'https://example.com/c.png',
        'duration_seconds': 185,
        'plays_count': 12,
        'published_at': '2026-08-01T10:00:00+00:00',
        'category': {'name': 'Actualités', 'slug': 'actualites', 'color': '#1B7A3A'},
      });

      expect(e.slug, 'le-journal');
      expect(e.isPlayable, isTrue);
      expect(e.duration, const Duration(seconds: 185));
      expect(e.category?.slug, 'actualites');
      expect(e.publishedAt?.year, 2026);
    });

    test('handles a minimal payload', () {
      final e = Episode.fromJson({'title': 'x', 'slug': 'x'});
      expect(e.isPlayable, isFalse);
      expect(e.duration, isNull);
      expect(e.category, isNull);
      expect(e.playsCount, 0);
    });
  });

  group('Paginated', () {
    test('reads Laravel pagination meta', () {
      final page = Paginated<Episode>.fromJson({
        'data': [
          {'title': 'a', 'slug': 'a'},
          {'title': 'b', 'slug': 'b'},
        ],
        'meta': {'current_page': 2, 'last_page': 5, 'total': 73},
      }, Episode.fromJson);

      expect(page.items, hasLength(2));
      expect(page.currentPage, 2);
      expect(page.hasMore, isTrue);
      expect(page.total, 73);
    });

    test('hasMore is false on the last page', () {
      final page = Paginated<Episode>.fromJson({
        'data': <dynamic>[],
        'meta': {'current_page': 5, 'last_page': 5, 'total': 73},
      }, Episode.fromJson);
      expect(page.hasMore, isFalse);
    });
  });
}
