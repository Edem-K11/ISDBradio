import 'dart:convert';

import '../../../core/config/env.dart';

/// Live-stream configuration served by `GET /api/v1/stream`.
class StreamConfig {
  const StreamConfig({
    required this.stationName,
    required this.streamUrl,
    required this.codec,
    required this.isOnAir,
    required this.offlineMessage,
    this.slogan,
    this.backupUrl,
    this.logoUrl,
  });

  final String stationName;
  final String? slogan;
  final String streamUrl;
  final String? backupUrl;
  final String codec;
  final bool isOnAir;
  final String offlineMessage;
  final String? logoUrl;

  /// Used before the API has ever been reached.
  factory StreamConfig.fallback() => const StreamConfig(
    stationName: Env.defaultStationName,
    streamUrl: Env.fallbackStreamUrl,
    codec: 'mp3',
    isOnAir: true,
    offlineMessage: 'La radio est actuellement hors antenne. Reviens bientôt !',
  );

  factory StreamConfig.fromJson(Map<String, dynamic> json) => StreamConfig(
    stationName: (json['station_name'] as String?)?.trim().isNotEmpty == true
        ? json['station_name'] as String
        : Env.defaultStationName,
    slogan: json['slogan'] as String?,
    streamUrl: json['stream_url'] as String,
    backupUrl: json['backup_url'] as String?,
    codec: (json['codec'] as String?) ?? 'mp3',
    isOnAir: json['is_on_air'] as bool? ?? true,
    offlineMessage:
        (json['offline_message'] as String?) ??
        'La radio est actuellement hors antenne.',
    logoUrl: json['logo_url'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'station_name': stationName,
    'slogan': slogan,
    'stream_url': streamUrl,
    'backup_url': backupUrl,
    'codec': codec,
    'is_on_air': isOnAir,
    'offline_message': offlineMessage,
    'logo_url': logoUrl,
  };

  String encode() => jsonEncode(toJson());

  static StreamConfig decode(String raw) =>
      StreamConfig.fromJson(jsonDecode(raw) as Map<String, dynamic>);
}
