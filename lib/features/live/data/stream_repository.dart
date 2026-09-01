import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/network/dio_client.dart';
import 'stream_config.dart';

/// Fetches the live-stream configuration.
///
/// Strategy: always try the API first so dashboard changes show up, keep the
/// last successful response cached, and fall back to that cache (then a
/// built-in default) only when the network fails.
class StreamRepository {
  StreamRepository({Dio? dio}) : _dio = dio ?? DioClient.instance;

  final Dio _dio;
  static const _cacheKey = 'cached_stream_config_v1';

  Future<StreamConfig> getConfig() async {
    try {
      return await _fetchAndCache();
    } on DioException catch (e) {
      debugPrint('StreamRepository: network failed (${e.type}), using cache');
      return await _readCache() ?? StreamConfig.fallback();
    }
  }

  /// Force a network refresh; throws [ApiException] on failure.
  Future<StreamConfig> refresh() async {
    try {
      return await _fetchAndCache();
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<StreamConfig> _fetchAndCache() async {
    final response = await _dio.get<Map<String, dynamic>>('/stream');
    final data = response.data?['data'] as Map<String, dynamic>?;
    if (data == null) {
      throw ApiException('Réponse inattendue du serveur.');
    }
    final config = StreamConfig.fromJson(data);
    await _writeCache(config);
    return config;
  }

  Future<StreamConfig?> _readCache() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_cacheKey);
    if (raw == null) return null;
    try {
      return StreamConfig.decode(raw);
    } catch (_) {
      return null;
    }
  }

  Future<void> _writeCache(StreamConfig config) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cacheKey, config.encode());
  }
}
