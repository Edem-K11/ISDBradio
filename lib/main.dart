import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:isdb_radio/providers/navigation_provider.dart';
import 'package:isdb_radio/providers/streaming_provider.dart';
import 'package:isdb_radio/pages/home_page.dart';
import 'package:isdb_radio/services/audio_player_handler.dart';
import 'package:isdb_radio/themes/app_theme.dart';
import 'package:provider/provider.dart';

late final AudioPlayerHandler audioHandler;
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Audio Handler
  // Initialise AudioService et récupère ton handler
  audioHandler = await AudioService.init(
    builder: () => AudioPlayerHandler(),
    config: AudioServiceConfig(
      androidNotificationChannelId: 'com.example.isdb_radio.channel.audio',
      androidNotificationChannelName: 'Music Player',
      androidNotificationChannelDescription: 'Contrôles de lecture de musique',
      androidNotificationOngoing: true,
      androidNotificationIcon: 'drawable/ic_notification',
      androidShowNotificationBadge: true,
      // androidStopForegroundOnPause: true, // Garde la notification même en pause
    ),
  );
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => NavigationProvider()),
        ChangeNotifierProvider(create: (context) => StreamingProvider(audioHandler)),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {

  @override
  void initState() {
    super.initState();
    // Ajouter l'observateur du cycle de vie de l'application
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    // Supprimer l'observateur et arrêter le service audio
    WidgetsBinding.instance.removeObserver(this);
    _cleanupAudioService();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    switch (state) {
      case AppLifecycleState.detached:
        // Application fermée définitivement
        print('App fermée - Arrêt du service audio');
        _cleanupAudioService();
        break;
      case AppLifecycleState.paused:
        // Application en arrière-plan (ne pas arrêter la musique)
        print('App en arrière-plan');
        break;
      case AppLifecycleState.resumed:
        // Application revenue au premier plan
        print('App revenue au premier plan');
        break;
      case AppLifecycleState.inactive:
        // Application inactive (transition)
        break;
      case AppLifecycleState.hidden:
        // Application cachée
        break;
    }
  }

  /// Méthode pour nettoyer proprement le service audio
  Future<void> _cleanupAudioService() async {
    try {
      // Arrêter la lecture
      await audioHandler.stop();
      
    } catch (e) {
      print('Erreur lors du nettoyage du service audio: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
      theme: AppTheme.lightTheme,
      debugShowMaterialGrid: false,
    );
  }
}