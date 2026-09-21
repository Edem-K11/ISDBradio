import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';

import '../../core/network/api_exception.dart';
import '../../services/audio/audio_handler.dart';
import '../episodes/data/episode.dart';
import '../episodes/data/episode_repository.dart';
import '../live/data/stream_config.dart';
import '../live/data/stream_repository.dart';

/// What the single audio player is currently attached to.
enum PlayerKind { none, live, episode }

enum PlayPhase { idle, loading, buffering, playing, paused, error }

/// The one place that owns audio playback state for the whole app.
///
/// Only one thing plays at a time (the background handler has a single player),
/// so live and recorded-episode playback share this controller. Screens and the
/// mini-player just read from it.
class PlayerController extends ChangeNotifier {
  PlayerController({
    required RadioAudioHandler audioHandler,
    StreamRepository? streamRepository,
    EpisodeRepository? episodeRepository,
  }) : _handler = audioHandler,
       _streamRepo = streamRepository ?? StreamRepository(),
       _episodeRepo = episodeRepository ?? EpisodeRepository() {
    _subs
      ..add(_handler.playbackState.listen(_onPlaybackState))
      ..add(_handler.mediaItem.listen(_onMediaItem))
      ..add(_handler.positionStream.listen(_onPosition))
      ..add(_handler.durationStream.listen(_onDuration));
  }

  final RadioAudioHandler _handler;
  final StreamRepository _streamRepo;
  final EpisodeRepository _episodeRepo;
  final List<StreamSubscription<dynamic>> _subs = [];

  static const skipInterval = Duration(seconds: 10);

  // ---------------------------------------------------------------------------
  // Shared
  // ---------------------------------------------------------------------------
  PlayerKind _kind = PlayerKind.none;
  PlayPhase _phase = PlayPhase.idle;
  String? _errorMessage;

  PlayerKind get kind => _kind;
  PlayPhase get phase => _phase;
  String? get errorMessage => _errorMessage;

  bool get isActive => _kind != PlayerKind.none;
  bool get isPlaying =>
      _phase == PlayPhase.playing || _phase == PlayPhase.buffering;
  bool get isBuffering =>
      _phase == PlayPhase.loading || _phase == PlayPhase.buffering;

  /// Audio is actually coming out — false while (re)connecting or buffering.
  /// Drives the on-screen animations so they freeze during a reconnection.
  bool get isStreaming => _phase == PlayPhase.playing;

  // ---------------------------------------------------------------------------
  // Live
  // ---------------------------------------------------------------------------
  StreamConfig? _config;
  bool _loadingConfig = false;
  String? _nowPlaying;

  StreamConfig? get config => _config;
  bool get isLoadingConfig => _loadingConfig;
  String? get nowPlaying => _nowPlaying;
  bool get isOnAir => _config?.isOnAir ?? true;
  String get stationName => _config?.stationName ?? 'Radio ISDB';
  String? get slogan => _config?.slogan;
  String get offlineMessage =>
      _config?.offlineMessage ?? 'La radio est actuellement hors antenne.';

  bool get isLivePlaying => _kind == PlayerKind.live;

  Future<void> loadConfig() async {
    if (_config != null || _loadingConfig) return;
    _loadingConfig = true;
    notifyListeners();
    _config = await _streamRepo.getConfig();
    _loadingConfig = false;
    notifyListeners();
  }

  Future<void> refreshConfig() async {
    try {
      _config = await _streamRepo.refresh();
      _errorMessage = null;
    } on ApiException catch (e) {
      _errorMessage = e.message;
    }
    notifyListeners();
  }

  /// Play / pause the live stream. Pausing keeps the notification (so playback
  /// can be resumed); resuming reconnects to the live edge.
  Future<void> toggleLive() async {
    if (_kind == PlayerKind.live && isPlaying) {
      await _handler.pause();
      return;
    }

    _config ??= await _streamRepo.getConfig();
    final config = _config!;
    if (!config.isOnAir) {
      notifyListeners();
      return;
    }

    _kind = PlayerKind.live;
    _phase = PlayPhase.loading;
    _errorMessage = null;
    _nowPlaying = null;
    notifyListeners();

    try {
      await _handler.playLive(config);
    } catch (_) {
      _phase = PlayPhase.error;
      _errorMessage = 'Lecture impossible. Réessaie dans un instant.';
      notifyListeners();
    }
  }

  /// Fully stop the live stream and remove the notification.
  Future<void> stopLive() async {
    if (_kind == PlayerKind.live) await _handler.stop();
  }

  // ---------------------------------------------------------------------------
  // Episodes
  // ---------------------------------------------------------------------------
  Episode? _episode;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _completed = false;
  bool _reportedPlay = false;

  /// The list an episode was opened from (its category page, search results…),
  /// so the player's prev/next controls can move through it. Kept separate
  /// from `_episode` so it survives across `openEpisode` calls.
  List<Episode> _queue = [];
  int _queueIndex = -1;

  Episode? get episode => _episode;
  Duration get position => _position;
  Duration get duration => _duration;
  bool get isEpisodeCompleted => _completed;
  bool get isEpisodePlaying => _kind == PlayerKind.episode;

  bool get hasNextEpisode =>
      _queueIndex >= 0 && _queueIndex < _queue.length - 1;
  bool get hasPreviousEpisode => _queueIndex > 0;

  double get episodeProgress {
    final total = _duration.inMilliseconds;
    if (total <= 0) return 0;
    return (_position.inMilliseconds / total).clamp(0.0, 1.0);
  }

  bool isCurrentEpisode(Episode e) =>
      _kind == PlayerKind.episode && _episode?.slug == e.slug;

  /// Remembers the list an episode was opened from (a category page, search
  /// results…) so prev/next can move through it. Call this before navigating
  /// to the player; `openEpisode` then locates `current` inside it.
  void setQueue(List<Episode> episodes, Episode current) {
    _queue = List.of(episodes);
    _queueIndex = _queue.indexWhere((x) => x.slug == current.slug);
  }

  /// Called when an episode screen opens. Starts the episode unless it is
  /// already the active one (and not finished).
  Future<void> openEpisode(Episode e) async {
    final sameAndRunning =
        _kind == PlayerKind.episode && _episode?.slug == e.slug && !_completed;

    final idx = _queue.indexWhere((x) => x.slug == e.slug);
    if (idx == -1) {
      // Opened standalone (deep link, mini-player, notification) — it's the
      // only thing we know about.
      _queue = [e];
      _queueIndex = 0;
    } else {
      _queueIndex = idx;
    }

    if (sameAndRunning) return;

    _episode = e;
    _position = Duration.zero;
    _duration = e.duration ?? Duration.zero;
    _completed = false;
    _reportedPlay = false;
    _errorMessage = null;
    _kind = PlayerKind.episode;
    _phase = PlayPhase.loading;
    notifyListeners();

    await _startEpisode(e);
  }

  /// Next episode in the queue, if any.
  Future<void> playNext() async {
    if (!hasNextEpisode) return;
    await openEpisode(_queue[_queueIndex + 1]);
  }

  /// Previous episode in the queue — or, if we're more than a few seconds
  /// into the current one, just restart it (standard player behaviour).
  Future<void> playPrevious() async {
    if (_kind == PlayerKind.episode && _position > const Duration(seconds: 3)) {
      await seek(Duration.zero);
      return;
    }
    if (!hasPreviousEpisode) {
      await seek(Duration.zero);
      return;
    }
    await openEpisode(_queue[_queueIndex - 1]);
  }

  Future<void> toggleEpisode() async {
    final e = _episode;
    if (e == null) return;

    if (_completed) {
      _completed = false;
      _position = Duration.zero;
      _phase = PlayPhase.loading;
      notifyListeners();
      await _startEpisode(e);
      return;
    }

    if (isPlaying) {
      await _handler.pause();
    } else {
      await _handler.play();
    }
  }

  Future<void> _startEpisode(Episode e) async {
    try {
      await _handler.playEpisode(e);
      if (!_reportedPlay) {
        _reportedPlay = true;
        unawaited(_episodeRepo.reportPlay(e.slug));
      }
    } catch (_) {
      _phase = PlayPhase.error;
      _errorMessage = 'Lecture impossible.';
      notifyListeners();
    }
  }

  Future<void> seek(Duration to) => _handler.seek(_clampToDuration(to));

  Future<void> skipForward() =>
      _handler.seek(_clampToDuration(_position + skipInterval));

  Future<void> skipBackward() =>
      _handler.seek(_clampToDuration(_position - skipInterval));

  Duration _clampToDuration(Duration value) {
    if (value < Duration.zero) return Duration.zero;
    if (_duration > Duration.zero && value > _duration) return _duration;
    return value;
  }

  // ---------------------------------------------------------------------------
  // Handler stream plumbing
  // ---------------------------------------------------------------------------
  void _onMediaItem(MediaItem? item) {
    if (item == null) {
      if (_kind != PlayerKind.none) {
        _kind = PlayerKind.none;
        _phase = PlayPhase.idle;
        notifyListeners();
      }
      return;
    }

    if (item.isLive == true) {
      _kind = PlayerKind.live;
      final title = item.title;
      _nowPlaying = (title.isNotEmpty && title != stationName) ? title : null;
    } else {
      _kind = PlayerKind.episode;
    }
    notifyListeners();
  }

  void _onPlaybackState(PlaybackState state) {
    final ps = state.processingState;

    if (_kind == PlayerKind.episode &&
        ps == AudioProcessingState.completed) {
      _completed = true;
      _position = _duration;
      _phase = PlayPhase.paused;
      notifyListeners();
      return;
    }

    final next = switch (ps) {
      AudioProcessingState.loading => PlayPhase.loading,
      AudioProcessingState.buffering => PlayPhase.buffering,
      AudioProcessingState.error => PlayPhase.error,
      AudioProcessingState.ready => state.playing
          ? PlayPhase.playing
          : (_kind == PlayerKind.episode ? PlayPhase.paused : PlayPhase.idle),
      AudioProcessingState.idle => PlayPhase.idle,
      AudioProcessingState.completed => PlayPhase.idle,
    };

    if (next == PlayPhase.error) {
      _errorMessage ??= 'La lecture a été interrompue.';
    } else {
      _errorMessage = null;
    }

    if (next != _phase) {
      _phase = next;
      notifyListeners();
    }
  }

  void _onPosition(Duration p) {
    if (_kind != PlayerKind.episode || _completed) return;
    _position = p;
    notifyListeners();
  }

  void _onDuration(Duration? d) {
    if (_kind != PlayerKind.episode || d == null || d == Duration.zero) return;
    _duration = d;
    notifyListeners();
  }

  @override
  void dispose() {
    for (final s in _subs) {
      s.cancel();
    }
    super.dispose();
  }
}
