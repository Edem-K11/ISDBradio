
import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:isdb_radio/models/archive.dart';
import 'package:just_audio/just_audio.dart';

class AudioPlayerHandler extends BaseAudioHandler {
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  // Playlist
  List<Archive> _playlist = [];
  int _currentIndex = 0;  

  // Radio streaming
  bool _isRadioMode = false;
  String? _currentRadioUrl;
  String? _currentRadioTitle;
  
  // Stream controllers
  final StreamController<List<Archive>> _playlistController = StreamController<List<Archive>>.broadcast();
  final StreamController<int> _currentIndexController = StreamController<int>.broadcast();
  final StreamController<bool> _radioModeController = StreamController<bool>.broadcast();
  final StreamController<bool> _playlistPlayingOn = StreamController<bool>.broadcast();
  final StreamController<bool> _radioLoading = StreamController<bool>.broadcast();
  
  // Getters pour les streams
  Stream<List<Archive>> get playlistStream => _playlistController.stream;
  Stream<int> get currentIndexStream => _currentIndexController.stream;
  Stream<bool> get radioModeStream => _radioModeController.stream;
  Stream<bool> get playlistPlayingOn => _playlistPlayingOn.stream;
  Stream<bool> get radioLoading => _radioLoading.stream;

  AudioPlayerHandler() {
    _init();
  }
  
  // --- Initialisation (Cette méthode va initialiser le playBack et les différents périphériques qui vont avec)
  Future<void> _init() async {
    // Écouter les changements de position du lecteur
    _audioPlayer.positionStream.listen((position) {
      // Pour le streaming radio, on peut ignorer la position du lecteur
      if (!_isRadioMode) {
        playbackState.add(playbackState.value.copyWith(
          updatePosition: position,
        ));
      }
    });
    
    // Écouter les changements de durée totale (utile pour les fichiers locaux, si le fichier streaming n'a pas de durée fixe)
    _audioPlayer.durationStream.listen((duration) {
      if (duration != null && !_isRadioMode) {
        // Mise à jour seulement pour les fichiers locaux
      }
    });
    
    // Écouter les changements d'état de lecture pour mettre à jour la notificatione et le playbackState
    _audioPlayer.playerStateStream.listen((state) {
      final isPlaying = state.playing;
      final processingState = state.processingState;
      
      AudioProcessingState audioProcessingState;
      switch (processingState) {
        case ProcessingState.idle:
          audioProcessingState = AudioProcessingState.idle;
          break;
        case ProcessingState.loading:
          audioProcessingState = AudioProcessingState.loading;
          break;
        case ProcessingState.buffering:
          audioProcessingState = AudioProcessingState.buffering;
          break;
        case ProcessingState.ready:
          audioProcessingState = AudioProcessingState.ready;
          break;
        case ProcessingState.completed:
          audioProcessingState = AudioProcessingState.completed;
          if (!_isRadioMode) {
            skipToNext();
          }
          break;
      }


      // Contrôles différents selon le mode
      List<MediaControl> controls;


      // Déterminer le contrôle de lecture/pause/chargement
      MediaControl playPauseControl;
      final isLoading = processingState == ProcessingState.loading;      
      // Broadcasting de l'état du loading
      _radioLoading.add(isLoading);

      if (isLoading) {
        // Afficher un loader pendant le chargement
        // print("isLoading : ${isLoading} and i'm turning");
        playPauseControl = const MediaControl(
          androidIcon: 'drawable/ic_loading', // Vous devez créer cette icône
          label: 'Loading...',
          action: MediaAction.custom,
          // customAction: CustomMediaAction(name: 'loading', extras: {'message': 'Loading...'}),
        );
      } else if (isPlaying) {
        playPauseControl = MediaControl.pause;
      } else {
        playPauseControl = MediaControl.play;
      }
      
      if (_isRadioMode) {
        controls = [playPauseControl];
      } else {
        controls = [
          MediaControl.skipToPrevious,
          playPauseControl,
          MediaControl.skipToNext,
          MediaControl.stop,
        ];
      }
      
      playbackState.add(playbackState.value.copyWith(
        controls: controls,
        systemActions: _isRadioMode ? const {} : const {
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
        },
        androidCompactActionIndices: _isRadioMode ? const [0] : const [0, 1, 2],
        processingState: audioProcessingState,
        playing: isPlaying,
      ));
    });
  }


  // MÉTHODES POUR LE STREAMING RADIO
  
  /// Démarrer le streaming radio
  Future<void> startRadioStream({
    required String streamUrl,
    required String title,
    String? author,
    String? artUri,
  }) async {
    try {

      await _audioPlayer.stop();

      _isRadioMode = true;
      _currentRadioUrl = streamUrl;
      _currentRadioTitle = title;
      
      _radioModeController.add(true);
      _playlistPlayingOn.add(false);
      
      // Mettre à jour les métadonnées
      mediaItem.add(MediaItem(
        id: 'radio_stream',
        title: title,
        artist: author ?? "Live Stream",
        artUri: artUri != null ? Uri.parse(artUri) : null,
        duration: null, // Pas de durée pour le streaming
        extras: {
        'isRadio': true,
        'streamUrl': streamUrl,
      },
      ));
      
      // Charger et jouer le flux
      await _audioPlayer.setUrl(streamUrl);
      await play();
      
    } catch (e) {
      print('Erreur lors du démarrage du streaming radio: $e');
      // Gérer l'erreur selon vos besoins
      _isRadioMode = false;
      _radioModeController.add(false);
    }
  }
  
  /// Arrêter le streaming radio
  Future<void> stopRadioStream() async {

    await _audioPlayer.stop();

    _isRadioMode = false;
    _currentRadioUrl = null;
    _currentRadioTitle = null;

    // Effacer les métadonnées
    mediaItem.add(null);
    
    _radioModeController.add(false);    
  }
  
  /// Arrêter le streaming radio
  Future<void> resumeRadioStream() async {

    await _audioPlayer.pause();

    // _isRadioMode = false;
    // _currentRadioUrl = null;
    // _currentRadioTitle = null;

    // // Effacer les métadonnées
    // mediaItem.add(null);
    
    // _radioModeController.add(false);    
  }

  /// Basculer entre pause/play pour le radio
  Future<void> toggleRadioPlayback() async {
    if (_isRadioMode) {
      if (_audioPlayer.playing) {
        await pause();
      } else {
        await play();
      }
    }
  }

  // MÉTHODES POUR LA PLAYLIST

  /// Passer en mode playlist
  Future<void> switchToPlaylistMode() async {
    if (_isRadioMode) {
      await stopRadioStream();
    }
    _isRadioMode = false;
    _radioModeController.add(false);
    _playlistPlayingOn.add(true);
  }

  
  
  // Définir la playlist
  Future<void> setPlaylist(List<AudioSource> audioSources, List<Archive> archives) async {
    try {
      if (audioSources.isEmpty || archives.isEmpty) {
        return print("Liste vide détectée, setPlaylist annulée");
      }
      // Synchronisation des deux listes
      _playlist.clear();
      _playlist.addAll(archives);


      // Configuration du lecteur
      await _audioPlayer.setAudioSources(audioSources);

    } catch (e) {
      print('Erreur setPlaylist: $e');
      rethrow;
    }
  }
  
  // Définir l'index actuel
  Future<void> setCurrentIndex(int index) async {
    if (index >= 0 && index < _playlist.length) {
      // Arrêter le radio si en cours
      if (_isRadioMode) {
        await stopRadioStream();
      }

      _playlistPlayingOn.add(true);


      if(_currentIndex != index) {
          _currentIndex = index;
          print("Changement d'index vers (currentIndex): $_currentIndex");
          _currentIndexController.add(_currentIndex);
          await _loadCurrentArchive();
      }
    }
  }
  
  // Charger la chanson actuelle
  Future<void> _loadCurrentArchive() async {
    if (_playlist.isEmpty) return;

    _isRadioMode = false;
    _radioModeController.add(false);
    
    final currentArchive = _playlist[_currentIndex];

    // Mettre à jour les métadonnées
    mediaItem.add(MediaItem(
      id: _currentIndex.toString(),
      title: currentArchive.title,
      artist: currentArchive.author,
      artUri: currentArchive.imageUrl != null
        ? Uri.parse(currentArchive.imageUrl!)
        : null,
      duration: await _loadAudio(currentArchive.audioUrl),
    ));

    // Start playing after loading
    play();
  }

  // Charge l'URL de l'audio
  Future<Duration?> _loadAudio(String audioPath) async {
    try {
      // Vérifier si c'est une URL (commence par http/https)
      if (audioPath.startsWith('http://') || audioPath.startsWith('https://')) {
        // URL distante (podcast)

        _audioPlayer.stop();

        print("Chargement de l'URL distante: $audioPath");

        return await _audioPlayer.setUrl(audioPath);
      }
    } catch (e) {
      print('Erreur lors du chargement audio: $e');
      return null;
    }
    return null;
  }

  // METHODES POUR AUDIO SERVICE (override)
  
  @override
  Future<void> play() async {
    await _audioPlayer.play();
  }
  
  @override
  Future<void> pause() async {
    await _audioPlayer.pause();
  }
  
  @override
  Future<void> stop() async {
    
    await _audioPlayer.stop();

    if (_isRadioMode) {
      await stopRadioStream();
    }

    // Supprimer les métadonnées pour faire disparaître la notification
    mediaItem.add(null);
    
    // Mettre à jour l'état de lecture du palybackState et de la notification
    playbackState.add(playbackState.value.copyWith(
      processingState: AudioProcessingState.idle,
      playing: false,
    ));
    
    await super.stop();
  }
  
  @override
  Future<void> seek(Duration position) async {
    // Le seek n'est pas supporté pour le streaming radio
    if (!_isRadioMode) {
      await _audioPlayer.seek(position);
    }
  }
  
  @override
  Future<void> skipToNext() async {
    // Seulement pour la playlist
    if (!_isRadioMode && _currentIndex < _playlist.length - 1) {
      await setCurrentIndex(_currentIndex + 1);
    } else if (!_isRadioMode) {
      await setCurrentIndex(0); // Revenir au début
    }
    await play();
  }
  
  @override
  Future<void> skipToPrevious() async {
    // Seulement pour la playlist
    if (!_isRadioMode) {
      if (_audioPlayer.position.inSeconds > 2) {
        await seek(Duration.zero);
      } else {
        if (_currentIndex > 0) {
          await setCurrentIndex(_currentIndex - 1);
        } else {
          await setCurrentIndex(_playlist.length - 1); // Aller à la fin
        }
        await play();
      }
    }
  }

  @override
  Future<void> customAction(String name, [Map<String, dynamic>? extras]) async {
    // Gérer les actions personnalisées
    switch (name) {
      case 'loading':
        // Ne rien faire pendant le chargement
        break;
      default:
        super.customAction(name, extras);
    }
  }
  
  @override
  Future<void> onTaskRemoved() async {
    // Optionnel : arrêter la lecture quand l'app est fermée
    // Arrêter complètement la lecture et supprimer la notification
    await stop();
    await super.onTaskRemoved();
  }

  @override
  Future<void> onNotificationDeleted() async {
    // Arrêter la lecture quand la notification est supprimée
    await stop();
    await super.onNotificationDeleted();
  }
  
  // Getters pour l'état actuel
  Duration get currentPosition => _audioPlayer.position;
  Duration? get totalDuration => _audioPlayer.duration;
  bool get isPlaying => _audioPlayer.playing;
  int get currentIndex => _currentIndex;
  List<Archive> get playlist => _playlist;
  // Getters pour l'état radio
  bool get isRadioMode => _isRadioMode;
  String? get currentRadioUrl => _currentRadioUrl;
  String? get currentRadioTitle => _currentRadioTitle;
  

}