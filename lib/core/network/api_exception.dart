import 'package:dio/dio.dart';

/// Normalised network error surfaced to controllers and the UI.
class ApiException implements Exception {
  ApiException(this.message, {this.statusCode, this.isConnectionError = false});

  final String message;
  final int? statusCode;
  final bool isConnectionError;

  /// Build a user-facing exception from a Dio failure.
  factory ApiException.fromDio(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return ApiException(
          'La connexion au serveur a expiré.',
          isConnectionError: true,
        );
      case DioExceptionType.connectionError:
      case DioExceptionType.badCertificate:
        return ApiException(
          'Impossible de joindre le serveur. Vérifie ta connexion.',
          isConnectionError: true,
        );
      case DioExceptionType.badResponse:
        final code = error.response?.statusCode;
        return ApiException(
          code == 404
              ? 'Contenu introuvable.'
              : 'Le serveur a renvoyé une erreur ($code).',
          statusCode: code,
        );
      case DioExceptionType.cancel:
        return ApiException('Requête annulée.');
      case DioExceptionType.unknown:
        return ApiException(
          'Une erreur réseau est survenue.',
          isConnectionError: true,
        );
    }
  }

  @override
  String toString() => 'ApiException($statusCode): $message';
}
