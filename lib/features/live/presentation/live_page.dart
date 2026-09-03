import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../player/player_controller.dart';
import '../../shell/widgets/app_drawer.dart';
import 'widgets/audio_animation.dart';

class LivePage extends StatefulWidget {
  const LivePage({super.key});

  @override
  State<LivePage> createState() => _LivePageState();
}

class _LivePageState extends State<LivePage> with TickerProviderStateMixin {
  late final AnimationController _vinylController;
  late final AnimationController _waveController;
  late final AnimationController _audioWaveController;

  @override
  void initState() {
    super.initState();
    _vinylController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    );
    _waveController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    _audioWaveController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    )..repeat();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PlayerController>().loadConfig();
    });
  }

  @override
  void dispose() {
    _vinylController.dispose();
    _waveController.dispose();
    _audioWaveController.dispose();
    super.dispose();
  }

  void _syncVinyl(bool playing) {
    if (playing && !_vinylController.isAnimating) {
      _vinylController.repeat();
    } else if (!playing && _vinylController.isAnimating) {
      _vinylController.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerController>();
    final isLive = player.isLivePlaying;
    // Animations run only while audio is actually playing — they freeze during
    // a (re)connection instead of spinning on nothing.
    final streaming = isLive && player.isStreaming;
    final connecting = isLive && player.isBuffering;
    _syncVinyl(streaming);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.segment_rounded, size: 28),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Text(
          player.stationName.toUpperCase(),
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
      ),
      drawer: const AppDrawer(),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: player.refreshConfig,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 80),
            children: [
              _StationHeader(slogan: player.slogan),
              const SizedBox(height: 8),
              RadioWavyLineAndVynilRotation(
                waveController: _waveController,
                isPlaying: streaming,
                vinylController: _vinylController,
              ),
              const SizedBox(height: 8),
              AudioWaveAndLiveIndicator(
                audioWaveController: _audioWaveController,
                isPlaying: streaming,
                isConnecting: connecting,
                isPaused: isLive && !streaming && !connecting,
              ),
              const SizedBox(height: 8),
              _NowPlaying(player: player),
              const SizedBox(height: 8),
              _Controls(player: player),
            ],
          ),
        ),
      ),
    );
  }
}

class _StationHeader extends StatelessWidget {
  const _StationHeader({this.slogan});

  final String? slogan;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final label = (slogan != null && slogan!.isNotEmpty)
        ? slogan!
        : 'La radio de l\'Institut Supérieur Don Bosco';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: Center(
        child: IntrinsicWidth(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                height: 1.5,
                color: scheme.outlineVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NowPlaying extends StatelessWidget {
  const _NowPlaying({required this.player});

  final PlayerController player;

  @override
  Widget build(BuildContext context) {
    if (!player.isOnAir) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Text(
          player.offlineMessage,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }

    final String text;
    if (player.isLivePlaying && player.phase == PlayPhase.error) {
      text = player.errorMessage ?? 'Lecture interrompue.';
    } else if (player.isLivePlaying && player.isBuffering) {
      text = 'Connexion au direct…';
    } else if (player.isLivePlaying) {
      text = player.nowPlaying ?? '';
    } else {
      text = '';
    }
    if (text.isEmpty) return const SizedBox(height: 20);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Text(
        text,
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _Controls extends StatelessWidget {
  const _Controls({required this.player});

  final PlayerController player;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final disabled = !player.isOnAir;
    final busy = player.isLivePlaying && player.isBuffering;
    final playing = player.isLivePlaying && player.isPlaying;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Center(
        child: Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: disabled ? scheme.surfaceContainerHighest : scheme.primary,
            shape: BoxShape.circle,
            boxShadow: disabled
                ? null
                : [
                    BoxShadow(
                      color: scheme.primary.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: disabled ? null : player.toggleLive,
              child: Center(
                child: busy
                    ? SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(
                          color: scheme.onPrimary,
                          strokeWidth: 3,
                        ),
                      )
                    : Icon(
                        playing ? Icons.stop_rounded : Icons.play_arrow_rounded,
                        color: disabled
                            ? scheme.onSurfaceVariant
                            : scheme.onPrimary,
                        size: 40,
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
