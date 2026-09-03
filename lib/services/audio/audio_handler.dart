import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

import '../../features/episodes/data/episode.dart';
import '../../features/live/data/stream_config.dart';
import 'default_art.dart';

/// Single background audio handler for Radio ISDB — the live stream and
/// recorded episodes share one player.
class RadioAudioHandler extends BaseAudioHandler with SeekHandler {
  RadioAudioHandler() {
    _init();
  }

  final AudioPlayer _player = AudioPlayer();
  bool _isLive = false;

  /// Kept so the media-notification play button can rejoin the live stream:
  /// pausing a live stream stops the player (rather than buffering stale audio),
  /// so "play" has to start a fresh connection, not resume.
  StreamConfig? _lastLiveConfig;

  /// True between a live "pause" (which stops the player) and the next play.
  /// Lets us present a real paused state — dismissable notification, working
  /// play button — instead of "nothing playing".
  bool _livePaused = false;

  Future<void> _init() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());

    _player.playbackEventStream.listen(
      _broadcastState,
      onError: (Object e, StackTrace st) {
        debugPrint('audio playback error: $e');
        playbackState.add(
          playbackState.value.copyWith(
            processingState: AudioProcessingState.error,
          ),
        );
      },
    );

    // Live "now playing" from Icecast/Shoutcast ICY metadata.
    _player.icyMetadataStream.listen((icy) {
      final title = icy?.info?.title;
      final current = mediaItem.value;
      if (title != null && title.isNotEmpty && current != null) {
        mediaItem.add(current.copyWith(title: title));
      }
    });

    // Correct the media item with the real decoded duration (episodes).
    _player.durationStream.listen((duration) {
      final current = mediaItem.value;
      if (duration != null &&
          current != null &&
          current.isLive != true &&
          current.duration != duration) {
        mediaItem.add(current.copyWith(duration: duration));
      }
    });
  }

  void _broadcastState([PlaybackEvent? event]) {
    // just_audio's stop() leaves `playing` true (it only reflects play/pause
    // intent), so treat an idle player as not playing — otherwise the media
    // notification keeps showing a pause button after a live stop.
    final playing =
        _player.playing && _player.processingState != ProcessingState.idle;
    playbackState.add(
      PlaybackState(
        controls: [
          if (!_isLive) MediaControl.rewind,
          if (playing) MediaControl.pause else MediaControl.play,
          if (!_isLive) MediaControl.fastForward,
          MediaControl.stop,
        ],
        systemActions: const {
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
        },
        androidCompactActionIndices: _isLive ? const [0] : const [0, 1, 2],
        processingState: _livePaused
            ? AudioProcessingState.ready
            : switch (_player.processingState) {
                ProcessingState.idle => AudioProcessingState.idle,
                ProcessingState.loading => AudioProcessingState.loading,
                ProcessingState.buffering => AudioProcessingState.buffering,
                ProcessingState.ready => AudioProcessingState.ready,
                ProcessingState.completed => AudioProcessingState.completed,
              },
        playing: playing,
        updatePosition: _player.position,
        bufferedPosition: _player.bufferedPosition,
        speed: _player.speed,
      ),
    );
  }

  /// Start (or restart) the live stream.
  Future<void> playLive(StreamConfig config) async {
    _isLive = true;
    _livePaused = false;
    _lastLiveConfig = config;
    final item = MediaItem(
      id: config.streamUrl,
      title: config.stationName,
      artist: config.slogan?.isNotEmpty == true ? config.slogan : 'En direct',
      isLive: true,
      artUri: (config.logoUrl != null ? Uri.tryParse(config.logoUrl!) : null) ??
          DefaultArt.uri,
    );
    mediaItem.add(item);

    try {
      await _player.setAudioSource(
        AudioSource.uri(Uri.parse(config.streamUrl), tag: item),
      );
      await _player.play();
    } catch (e) {
      debugPrint('playLive failed: $e');
      playbackState.add(
        playbackState.value.copyWith(
          processingState: AudioProcessingState.error,
        ),
      );
      rethrow;
    }
  }

  /// Load a recorded episode for seekable playback.
  Future<void> playEpisode(Episode episode) async {
    if (!episode.isPlayable) return;
    _isLive = false;
    _livePaused = false;
    final item = MediaItem(
      id: episode.audioUrl!,
      title: episode.title,
      artist: episode.category?.name ?? 'Émission',
      album: 'Radio ISDB',
      duration: episode.duration,
      artUri:
          (episode.coverUrl != null ? Uri.tryParse(episode.coverUrl!) : null) ??
              DefaultArt.uri,
    );
    mediaItem.add(item);

    try {
      await _player.setAudioSource(
        AudioSource.uri(Uri.parse(episode.audioUrl!), tag: item),
      );
      await _player.play();
    } catch (e) {
      debugPrint('playEpisode failed: $e');
      playbackState.add(
        playbackState.value.copyWith(
          processingState: AudioProcessingState.error,
        ),
      );
      rethrow;
    }
  }

  @override
  Future<void> play() async {
    // Resuming a paused live stream (e.g. from the notification): the player was
    // stopped, so reconnect instead of a no-op _player.play().
    if (_isLive && _livePaused && _lastLiveConfig != null) {
      await playLive(_lastLiveConfig!);
      return;
    }
    await _player.play();
  }

  @override
  Future<void> pause() async {
    if (_isLive) {
      _livePaused = true;
      await _player.stop();
      _broadcastState(); // stop() doesn't emit a clean state — force it
    } else {
      await _player.pause();
    }
  }

  @override
  Future<void> stop() async {
    await _player.stop();
    _isLive = false;
    _livePaused = false;
    mediaItem.add(null);
    await super.stop();
  }

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  /// Exposed for the presentation layer.
  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;

  Future<void> dispose() => _player.dispose();
}
