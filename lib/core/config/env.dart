/// Compile-time environment configuration.
///
/// Values are injected at build/run time with `--dart-define`, e.g.:
///
/// ```
/// flutter run \
///   --dart-define=API_BASE_URL=http://10.0.2.2:8000/api/v1
/// ```
///
/// Nothing secret lives here — only the public API base URL and a fallback
/// stream used when the backend is unreachable on first launch.
class Env {
  const Env._();

  /// Base URL of the Radio ISDB REST API (no trailing slash).
  ///
  /// Defaults to the Android-emulator loopback so `flutter run` works with a
  /// locally served backend without extra flags.
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000/api/v1',
  );

  /// Last-resort live stream used only when the backend has never been reached
  /// and no cached configuration exists. Overridable from the dashboard once
  /// the API is available.
  static const String fallbackStreamUrl = String.fromEnvironment(
    'FALLBACK_STREAM_URL',
    defaultValue: 'https://jazzradio.ice.infomaniak.ch/jazzradio-high.mp3',
  );

  /// Human-readable station name shown before the API responds.
  static const String defaultStationName = String.fromEnvironment(
    'DEFAULT_STATION_NAME',
    defaultValue: 'Radio ISDB',
  );

  /// Enables verbose network/audio logging. Off in release builds.
  static const bool verboseLogging = bool.fromEnvironment(
    'VERBOSE_LOGGING',
    defaultValue: !bool.fromEnvironment('dart.vm.product'),
  );
}
