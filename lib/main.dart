import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'app/app.dart';
import 'core/theme/theme_controller.dart';
import 'features/info/presentation/info_controller.dart';
import 'features/player/player_controller.dart';
import 'features/splash/splash_screen.dart';
import 'services/audio/audio_handler.dart';
import 'services/audio/default_art.dart';

late final RadioAudioHandler audioHandler;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const Bootstrap());
}

/// Paints the branded splash on the very first frame, then runs the heavy
/// startup work (audio service, notification art, locale data) *behind* it so
/// the animation is actually visible instead of hidden by the OS splash.
class Bootstrap extends StatefulWidget {
  const Bootstrap({super.key});

  @override
  State<Bootstrap> createState() => _BootstrapState();
}

class _BootstrapState extends State<Bootstrap> {
  /// Built once and reused so the theme preference is resolved *before* the app
  /// is first painted — no dark-then-light flash on entry.
  final ThemeController _theme = ThemeController();

  /// Startup work + a floor on how long the splash stays up, so a fast device
  /// still shows the animation for a beat rather than flashing it.
  late final Future<void> _ready = Future.wait([
    _init(),
    Future<void>.delayed(const Duration(milliseconds: 2200)),
  ]);

  Future<void> _init() async {
    await initializeDateFormatting('fr_FR');
    await _theme.load();
    await DefaultArt.prepare();

    audioHandler = await AudioService.init(
      builder: RadioAudioHandler.new,
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'app.isdb.radio.audio',
        androidNotificationChannelName: 'Lecture Radio ISDB',
        // Keep the notification alive when paused so pausing never kills playback
        // on aggressive OEMs, and let it be dismissed only when truly stopped.
        androidNotificationOngoing: false,
        androidStopForegroundOnPause: false,
        fastForwardInterval: Duration(seconds: 10),
        rewindInterval: Duration(seconds: 10),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _ready,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: SplashScreen(),
          );
        }
        return MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: _theme),
            ChangeNotifierProvider(
              create: (_) => PlayerController(audioHandler: audioHandler),
            ),
            ChangeNotifierProvider(
              create: (_) => InfoController()..load(),
            ),
          ],
          child: const RadioIsdbApp(),
        );
      },
    );
  }
}
