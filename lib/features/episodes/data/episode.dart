import 'program_category.dart';

/// A recorded programme, from `GET /api/v1/episodes[/{slug}]`.
class Episode {
  const Episode({
    required this.title,
    required this.slug,
    this.description,
    this.audioUrl,
    this.coverUrl,
    this.durationSeconds,
    this.playsCount = 0,
    this.publishedAt,
    this.category,
  });

  final String title;
  final String slug;
  final String? description;
  final String? audioUrl;
  final String? coverUrl;
  final int? durationSeconds;
  final int playsCount;
  final DateTime? publishedAt;
  final ProgramCategory? category;

  bool get isPlayable => audioUrl != null && audioUrl!.isNotEmpty;

  Duration? get duration =>
      durationSeconds != null ? Duration(seconds: durationSeconds!) : null;

  factory Episode.fromJson(Map<String, dynamic> json) => Episode(
    title: json['title'] as String,
    slug: json['slug'] as String,
    description: json['description'] as String?,
    audioUrl: json['audio_url'] as String?,
    coverUrl: json['cover_url'] as String?,
    durationSeconds: (json['duration_seconds'] as num?)?.toInt(),
    playsCount: (json['plays_count'] as num?)?.toInt() ?? 0,
    publishedAt: json['published_at'] != null
        ? DateTime.tryParse(json['published_at'] as String)
        : null,
    category: json['category'] is Map<String, dynamic>
        ? ProgramCategory.fromJson(json['category'] as Map<String, dynamic>)
        : null,
  );
}
