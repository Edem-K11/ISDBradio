import 'package:dio/dio.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/network/dio_client.dart';
import 'episode.dart';
import 'paginated.dart';
import 'program_category.dart';

/// Talks to the episodes/categories endpoints of the Radio ISDB API.
class EpisodeRepository {
  EpisodeRepository({Dio? dio}) : _dio = dio ?? DioClient.instance;

  final Dio _dio;

  Future<Paginated<Episode>> fetchEpisodes({
    int page = 1,
    int perPage = 15,
    String? categorySlug,
    String? search,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/episodes',
        queryParameters: {
          'page': page,
          'per_page': perPage,
          if (categorySlug != null) 'category': categorySlug,
          if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        },
      );
      return Paginated<Episode>.fromJson(response.data!, Episode.fromJson);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<Episode> fetchEpisode(String slug) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/episodes/$slug');
      return Episode.fromJson(response.data!['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<List<ProgramCategory>> fetchCategories() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/categories');
      return (response.data!['data'] as List<dynamic>)
          .whereType<Map<String, dynamic>>()
          .map(ProgramCategory.fromJson)
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// Fire-and-forget play counter; failures are ignored.
  Future<void> reportPlay(String slug) async {
    try {
      await _dio.post<void>('/episodes/$slug/play');
    } catch (_) {
      // Not critical.
    }
  }
}
