
import 'package:flutter/material.dart';
import 'package:isdb_radio/services/audio_player_handler.dart';

class StreamingProvider extends ChangeNotifier {
  // Audio Handler
  final AudioPlayerHandler _audioHandler;
  
  // État du streaming
  bool _isLoading = false;
  bool _isStreaming = false;
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
      if (isRadioMode != _isStreaming) {
        _isStreaming = isRadioMode;
        notifyListeners();
      }
    });
    
    // Écouter les changements d'état de lecture
    _audioHandler.playbackState.listen((state) {
      final wasStreaming = _isStreaming;
      _isStreaming = _audioHandler.isRadioMode && state.playing;
      
      if (wasStreaming != _isStreaming) {
        notifyListeners();
      }
    });
  }
  
  // Méthode pour obtenir l'état de lecture de la radio
  bool get isRadioPlaying => _audioHandler.isPlaying && _audioHandler.isRadioMode;
  
  // Getters
  // bool get isStreaming => _isStreaming;
  bool get isLive => _isLive;
  bool get isLoading => _isLoading;
  bool get isRadioMode => _audioHandler.isRadioMode;
  String get stationName => _stationName;
  String get stationImagePath => _stationImagePath;
  String get streamUrl => _streamUrl;
  
  // Contrôles de streaming
  Future<void> startStreaming() async {
    try {

      _isStreaming = true;
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
      _isStreaming = false;
      notifyListeners();
    } catch (e) {
      print('Erreur lors de l\'arrêt du streaming: $e');
    }
  }
  
  Future<void> toggleStreaming() async {
    if (_isStreaming) {
      await stopStreaming();
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