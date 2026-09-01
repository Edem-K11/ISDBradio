/// A programme category, from `GET /api/v1/categories`.
class ProgramCategory {
  const ProgramCategory({
    required this.name,
    required this.slug,
    required this.color,
    this.sortOrder = 0,
    this.episodesCount,
  });

  final String name;
  final String slug;
  final String color;
  final int sortOrder;
  final int? episodesCount;

  factory ProgramCategory.fromJson(Map<String, dynamic> json) => ProgramCategory(
    name: json['name'] as String,
    slug: json['slug'] as String,
    color: (json['color'] as String?) ?? '#1B7A3A',
    sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
    episodesCount: (json['episodes_count'] as num?)?.toInt(),
  );
}
