import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/env.dart';

/// Single configured [Dio] instance for the Radio ISDB API.
class DioClient {
  DioClient._();

  static final Dio instance = _create();

  static Dio _create() {
    final dio = Dio(
      BaseOptions(
        baseUrl: Env.apiBaseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 25),
        headers: {'Accept': 'application/json'},
        responseType: ResponseType.json,
      ),
    );

    if (Env.verboseLogging) {
      dio.interceptors.add(
        LogInterceptor(
          requestBody: false,
          responseBody: false,
          logPrint: (o) => debugPrint('[dio] $o'),
        ),
      );
    }

    return dio;
  }
}
