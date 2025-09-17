
import 'package:flutter/material.dart';
import 'package:isdb_radio/services/audio_player_handler.dart';

class StreamingProvider extends ChangeNotifier {
  // Audio Handler
  final AudioPlayerHandler _audioHandler;
  
  // État du streaming
  bool _isLoading = false;
  bool _radioModeActive = false;
  bool _radioIsPlaying = false;
  bool _isLive = false;
  final String _stationName = "Radio ISDB";
  final String _stationImagePath = 'assets/images/logo_isdb.png';
    
  // URL du flux radio (exemple - remplacez par votre vraie URL)
  final String _streamUrl = "https://jazzradio.ice.infomaniak.ch/jazzradio-high.mp3"; // Remplacez par votre URL
  
  // Constructor
  StreamingProvider(this._audioHandler) {
    _initAudioService();
  }
  
  // Initialiser le service audio
  void _initAudioService() {

    // Ecouter les changements du lecteur pour voir si la lectue à débuter
    _audioHandler.radioLoading.listen((radioLoading){
      _isLoading = radioLoading;
      notifyListeners();
    });

    // Écouter les changements d'état du mode radio
    _audioHandler.radioModeStream.listen((isRadioMode) {
      if (isRadioMode != _radioModeActive) {
        _radioModeActive = isRadioMode;
        notifyListeners();
      }
      notifyListeners();
    });
    
    // Écouter les changements d'état de lecture
    _audioHandler.playbackState.listen((state) {
      final radioWasPlaying = _radioIsPlaying;
      _radioIsPlaying = _audioHandler.isRadioMode && state.playing;
      
      if (radioWasPlaying != _radioIsPlaying) {
        notifyListeners();
      }
    });
  }
  
  // Méthode pour obtenir l'état de lecture de la radio
  bool get radioIsPlaying => _radioIsPlaying;
  
  // Getters 
  bool get radioActive => _radioModeActive;
  bool get isLive => _isLive;
  bool get isLoading => _isLoading;
  String get stationName => _stationName;
  String get stationImagePath => _stationImagePath;
  String get streamUrl => _streamUrl;
  
  // Contrôles de streaming
  Future<void> startStreaming() async {
    try {
      // _radioIsPlaying = true;
      _radioModeActive = true;
      _isLive = true;
      notifyListeners();

      await _audioHandler.startRadioStream(
        streamUrl: _streamUrl,
        title: _stationName,
        author: "Live Stream",
        artUri: _stationImagePath,
      );
      
    } catch (e) {
      print('Erreur lors du démarrage du streaming: $e');
      // Gérer l'erreur selon vos besoins
    }
  }
  
  Future<void> stopStreaming() async {
    try {
      await _audioHandler.stopRadioStream();
      _radioModeActive = false;
      notifyListeners();
    } catch (e) {
      print('Erreur lors de l\'arrêt du streaming: $e');
    }
  }

  Future<void> pauseStreaming() async {
    if (_radioModeActive && _radioIsPlaying) {
      await _audioHandler.pause();
      _radioIsPlaying = false;
      notifyListeners();
    }
  }
  
  Future<void> toggleStreaming() async {
    if (_radioIsPlaying) {
      // await stopStreaming();
      await pauseStreaming();
    } else {
      await startStreaming();
    }
  }
  
  
  @override
  void dispose() {
    _audioHandler.stopRadioStream();
    super.dispose();
  }
}