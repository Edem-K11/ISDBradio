import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/network/dio_client.dart';
import 'app_config.dart';

class AppConfigRepository {
  AppConfigRepository({Dio? dio}) : _dio = dio ?? DioClient.instance;

  final Dio _dio;
  static const _cacheKey = 'cached_app_config_v1';

  /// Always try the API first (so dashboard changes appear), cache the result,
  /// and fall back to the cache only when the network fails.
  Future<AppConfig> get() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/app-config');
      final config = AppConfig.fromJson(
        response.data!['data'] as Map<String, dynamic>,
      );
      await _writeCache(config);
      return config;
    } on DioException catch (e) {
      final cached = await _readCache();
      if (cached != null) return cached;
      throw ApiException.fromDio(e);
    }
  }

  Future<AppConfig?> _readCache() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_cacheKey);
    if (raw == null) return null;
    try {
      return AppConfig.decode(raw);
    } catch (_) {
      return null;
    }
  }

  Future<void> _writeCache(AppConfig config) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cacheKey, config.encode());
  }
}
