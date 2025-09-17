import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:isdb_radio/models/archive.dart';
import 'package:isdb_radio/services/audio_player_handler.dart';
import 'package:isdb_radio/services/rss_service.dart';

class ArchiveProvider extends ChangeNotifier {
  
  // Audio Handler et Rss Service
  final AudioPlayerHandler _audioHandler;
  final RssService _rssService = RssService();
  
  // Playlist de Archives
  final List<Archive> _playlist = [];

  // Index de la chanson actuelle
  int? _currentArchiveIndex;

  // Archive actuellement jouée
  Archive? get currentArchive {
    if (_currentArchiveIndex != null && _currentArchiveIndex! >= 0 && _currentArchiveIndex! < _playlist.length) {
      return _playlist[_currentArchiveIndex!];
    }
    return null;
  }

  bool _playListIsOn = false;
  bool _loading = false;
  String? errorMessage;

  // État de lecture
  bool _audioPlayerIsPlaying = false;
  Duration _currentDuration = Duration.zero;
  Duration _totalDuration = Duration.zero;
  
// Constructor
ArchiveProvider(this._audioHandler) {
  _initAudioService();
  loadPlaylist();
}
  
  // Initialiser le service audio
  void _initAudioService() {
    _audioHandler.playlistPlayingOn.listen((value){
      _playListIsOn = value;
      notifyListeners();
    });
    
    // Écouter les changements d'état
    _audioHandler.playbackState.listen((state) {
      _audioPlayerIsPlaying = state.playing;
      _currentDuration = state.position;
      notifyListeners();
    });
    
    _audioHandler.mediaItem.listen((mediaItem) {
      if (mediaItem != null) {
        _totalDuration = mediaItem.duration ?? Duration.zero;
        notifyListeners();
      }
    });
    
    // Écouter les changements d'index
    _audioHandler.currentIndexStream.listen((index) {
      _currentDuration = Duration.zero;
      _currentArchiveIndex = index;
      notifyListeners();
    });
  }

  // Méthode pour convertir Archive en AudioSource
  List<AudioSource> _convertArchivesToAudioSources(List<Archive> archives) {
    return archives.map((archive) {
      return AudioSource.uri(
        Uri.parse(archive.audioUrl),
        tag: MediaItem(
          id: archive.audioUrl,
          title: archive.title,
          artist: archive.author ?? 'Inconnu',
          artUri: Uri.tryParse(archive.imageUrl ?? ''),
          duration: archive.duration,
        ),
      );
    }).toList();
  }

  // Méthode pour parser la durée depuis une string
  Future<void> loadPlaylist({String? rssUrl}) async {
    _loading = true;
    notifyListeners();
    try {
      final fetchedArchives = await _rssService.fetchFeed(rssUrl);
      if (fetchedArchives != null && fetchedArchives.isNotEmpty) {
        _playlist.clear();
        _playlist.addAll(fetchedArchives);
        
        // Convertir en AudioSources avant de passer au handler
        final audioSources = _convertArchivesToAudioSources(fetchedArchives);
        await _audioHandler.setPlaylist(audioSources, _playlist);
        
        _loading = false;
        notifyListeners();
      } else {
        _loading = false;
        notifyListeners(); 
        print('le fetch est vide');
      }
    } catch (e) {
      errorMessage = "Erreur chargement playlist: ${e.toString()}";
      print(errorMessage);
      _loading = false;
      notifyListeners();
    }
  }

  // Rafraîchir la liste des archives
  Future<void> refreshArchivesList() async {
    await loadPlaylist();
  }
  
  // G E T T E R S
  List<Archive> get playlist => _playlist;
  int? get currentArchiveIndex => _currentArchiveIndex;
  bool get audioPlayerIsPlaying => _audioPlayerIsPlaying;
  bool get playListIsOn => _playListIsOn;
  bool get isLoading => _loading;
  Duration get currentDuration => _currentDuration;
  Duration get totalDuration => _totalDuration;
  
  // S E T T E R S
  void setCurrentArchiveIndex(int? newIndex) {
    if (newIndex != null && newIndex >= 0 && newIndex < _playlist.length) {
      _currentArchiveIndex = newIndex;
      _audioHandler.setCurrentIndex(newIndex);
      notifyListeners();
    }
  }
  
  // Méthodes de contrôle
  Future<void> play() async {
    await _audioHandler.play();
  }
  
  Future<void> pause() async {
    await _audioHandler.pause();
  }
  
  Future<void> pauseOrResume() async {
    if (_audioPlayerIsPlaying) {
      await pause();
    } else {
      await play();
    }
  }
  
  Future<void> seek(Duration position) async {
    await _audioHandler.seek(position);
  }
  
  Future<void> playNextArchive() async {
    await _audioHandler.skipToNext();
  }
  
  Future<void> playPreviousArchive() async {
    await _audioHandler.skipToPrevious();
  }
  
  @override
  void dispose() {
    _audioHandler.stop();
    super.dispose();
  }
}