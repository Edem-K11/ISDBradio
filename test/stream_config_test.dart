import 'package:flutter_test/flutter_test.dart';
import 'package:isdb_radio/features/live/data/stream_config.dart';

void main() {
  group('StreamConfig', () {
    test('parses the API payload', () {
      final config = StreamConfig.fromJson({
        'station_name': 'Radio ISDB',
        'slogan': 'La radio de l\'ISDB',
        'stream_url': 'https://example.com/live.mp3',
        'backup_url': null,
        'codec': 'mp3',
        'is_on_air': true,
        'offline_message': 'Hors antenne',
        'logo_url': 'https://example.com/logo.png',
      });

      expect(config.stationName, 'Radio ISDB');
      expect(config.streamUrl, 'https://example.com/live.mp3');
      expect(config.isOnAir, isTrue);
      expect(config.logoUrl, 'https://example.com/logo.png');
    });

    test('falls back to defaults for missing optional fields', () {
      final config = StreamConfig.fromJson({
        'stream_url': 'https://example.com/live.mp3',
      });

      expect(config.stationName, isNotEmpty);
      expect(config.codec, 'mp3');
      expect(config.isOnAir, isTrue);
      expect(config.offlineMessage, isNotEmpty);
    });

    test('survives an encode/decode round-trip', () {
      final original = StreamConfig.fallback();
      final restored = StreamConfig.decode(original.encode());

      expect(restored.stationName, original.stationName);
      expect(restored.streamUrl, original.streamUrl);
      expect(restored.isOnAir, original.isOnAir);
    });
  });
}
