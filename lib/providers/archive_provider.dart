import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:isdb_radio/services/cache_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:isdb_radio/models/archive.dart';
import 'package:isdb_radio/services/audio_player_handler.dart';
import 'package:isdb_radio/services/rss_service.dart';

class ArchiveProvider extends ChangeNotifier {
  
  // Audio Handler et Rss Service
  final AudioPlayerHandler _audioHandler;
  final RssService _rssService = RssService();
  
  // Playlist de Archives
  List<Archive> _archiveList = [];
  bool _isRefreshing = false; // Indicateur de mise à jour


  // Index de la chanson actuelle
  int? _currentArchiveIndex;

  // Archive actuellement jouée
  Archive? get currentArchive {
    if (_currentArchiveIndex != null && 
        _currentArchiveIndex! >= 0 && 
        _currentArchiveIndex! < _archiveList.length) {
      return _archiveList[_currentArchiveIndex!];
    }
    return null;
  }

  bool _archiveListIsOn = false;
  bool _loading = false;
  String? errorMessage;

  // État de lecture
  bool _audioPlayerIsPlaying = false;
  Duration _currentDuration = Duration.zero;
  Duration _totalDuration = Duration.zero;
  
  // StreamSubscription pour le nettoyage
  StreamSubscription? _archiveListSubscription;
  
// Constructor
ArchiveProvider(this._audioHandler) {
  _initAudioService();
  _loadData();
}
  
  // Initialiser le service audio
  void _initAudioService() {
    _audioHandler.playlistPlayingOn.listen((value){
      _archiveListIsOn = value;
      notifyListeners();
    });
    
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
    
    _audioHandler.currentIndexStream.listen((index) {
      _currentDuration = Duration.zero;
      _currentArchiveIndex = index;
      notifyListeners();
    });
  }

  // Méthode pour convertir Archive en AudioSource avec optimisation
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

  Future<void> _loadData() async {
    // 1. CHARGER IMMÉDIATEMENT depuis le cache
    _loadFromCache();
    
    // 2. METTRE À JOUR depuis internet (en arrière-plan)
    _refreshFromNetwork();
  }

  void _loadFromCache() {
    // Récupération INSTANTANÉE depuis Hive
    _archiveList = CacheService.getArchives();
    notifyListeners(); // L'UI se met à jour immédiatement
    
    // Configurer le lecteur audio si on a des données
    if (_archiveList.isNotEmpty) {
      final audioSources = _convertArchivesToAudioSources(_archiveList);
      _audioHandler.setPlaylist(audioSources, _archiveList);
    }
  }

  Future<void> _refreshFromNetwork() async {
    _isRefreshing = true;
    notifyListeners();
    
    try {
      // Récupérer les nouvelles données depuis RSS
      final freshArchives = await _rssService.fetchFeed(null);
      
      if (freshArchives != null && freshArchives.isNotEmpty) {
        // Marquer comme archives et ajouter la date de cache
        final archivesWithCache = freshArchives.map((archive) => 
          Archive(
            title: archive.title,
            audioUrl: archive.audioUrl,
            imageUrl: archive.imageUrl,
            author: archive.author,
            publicationDate: archive.publicationDate,
            duration: archive.duration,
            cachedAt: DateTime.now(),
          )
        ).toList();
        
        // SAUVEGARDER dans Hive pour la prochaine fois
        await CacheService.saveArchives(archivesWithCache);
        
        // Mettre à jour l'UI
        _archiveList = archivesWithCache;
        final audioSources = _convertArchivesToAudioSources(_archiveList);
        await _audioHandler.setPlaylist(audioSources, _archiveList);
        notifyListeners();
      }
    } catch (e) {
      print('Erreur réseau: $e');
      // Pas grave, on garde les données du cache
    }
    
    _isRefreshing = false;
    notifyListeners();
  }

  
  // Précharger les images
  Future<void> preloadImages(BuildContext context) async {
    if (_archiveList.isNotEmpty) {
      await _rssService.preloadImages(_archiveList, context);
    }
  }

  // Rafraîchir la liste des archives
  Future<void> refreshArchivesList() async {
    // Nettoyer le cache pour forcer le rechargement
    _rssService.clearCache();
    await _refreshFromNetwork();
  }
  
  // G E T T E R S
  List<Archive> get playlist => _archiveList;
  int? get currentArchiveIndex => _currentArchiveIndex;
  bool get audioPlayerIsPlaying => _audioPlayerIsPlaying;
  bool get playListIsOn => _archiveListIsOn;
  bool get isRefreshing => _isRefreshing;
  bool get isLoading => _loading;
  Duration get currentDuration => _currentDuration;
  Duration get totalDuration => _totalDuration;
  
  
  // S E T T E R S
  void setCurrentArchiveIndex(int? newIndex) {
    if (newIndex != null && newIndex >= 0 && newIndex < _archiveList.length) {
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
    _archiveListSubscription?.cancel();
    _audioHandler.stop();
    _rssService.dispose();
    super.dispose();
  }
}