import 'package:flutter/material.dart';
import 'package:isdb_radio/providers/archive_provider.dart';
import 'package:isdb_radio/themes/theme.dart';
import 'package:isdb_radio/widgets/audio_animation.dart';
import 'package:provider/provider.dart';
import 'package:marquee/marquee.dart';

class ListenArchivePage extends StatefulWidget {
  const ListenArchivePage({super.key});

  @override
  State<ListenArchivePage> createState() => _ListenArchivePageState();
}

class _ListenArchivePageState extends State<ListenArchivePage>
    with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _vinylController;
  late AnimationController _waveController;
  
  // État du slider
  double? _sliderValue;
  
  // Constantes pour la configuration
  static const Duration _vinylDuration = Duration(seconds: 3);
  static const Duration _waveDuration = Duration(seconds: 2);
  static const double _appBarIconSize = 40.0;
  static const double _playButtonSize = 40.0;
  static const double _sliderThumbRadius = 8.0;
  static const double _sliderOverlayRadius = 14.0;
  
  // Constantes pour le marquee
  static const double _marqueeVelocity = 30.0;
  static const double _marqueeBlankSpace = 40.0;
  static const Duration _marqueePauseAfterRound = Duration(seconds: 2);

  @override
  void initState() {
    super.initState();
    _initializeAnimationControllers();
  }

  void _initializeAnimationControllers() {
    _vinylController = AnimationController(
      duration: _vinylDuration,
      vsync: this,
    );
    
    _waveController = AnimationController(
      duration: _waveDuration,
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _vinylController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ArchiveProvider>(
      builder: (context, archiveProvider, child) {
        _updateVinylAnimation(archiveProvider.audioPlayerIsPlaying);
        
        return Scaffold(
          appBar: _buildAppBar(context),
          body: _buildBody(context, archiveProvider),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      leading: IconButton(
        iconSize: _appBarIconSize,
        icon: Icon(
          AppIcons.arrowDown,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      foregroundColor: Theme.of(context).colorScheme.onSurface,
    );
  }

  Widget _buildBody(BuildContext context, ArchiveProvider archiveProvider) {
    return Column(
      children: [
        _buildAnimationSection(archiveProvider),
        const SizedBox(height: 10.0),
        _buildTitleSection(context, archiveProvider),
        const SizedBox(height: 5.0),
        _buildPlayerControls(context, archiveProvider),
      ],
    );
  }

  Widget _buildAnimationSection(ArchiveProvider archiveProvider) {
    return RadioWavyLineAndVynilRotation(
      waveController: _waveController,
      isPlaying: archiveProvider.audioPlayerIsPlaying,
      vinylController: _vinylController,
    );
  }

  Widget _buildTitleSection(BuildContext context, ArchiveProvider archiveProvider) {
    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildScrollingTitle(context, archiveProvider),
          const SizedBox(height: 16.0),
          _buildSubtitle(context),
        ],
      ),
    );
  }

  Widget _buildScrollingTitle(BuildContext context, ArchiveProvider archiveProvider) {
    final title = archiveProvider.currentArchive?.title ?? "Emission";
    final textStyle = TextStyle(
      fontSize: 20,
      color: Theme.of(context).colorScheme.primary,
      fontWeight: FontWeight.bold,
    );
    
    return SizedBox(
      height: 30.0,
      child: Marquee(
        text: title,
        style: textStyle,
        scrollAxis: Axis.horizontal,
        crossAxisAlignment: CrossAxisAlignment.center,
        blankSpace: _marqueeBlankSpace,
        velocity: _marqueeVelocity,
        pauseAfterRound: _marqueePauseAfterRound,
        showFadingOnlyWhenScrolling: true,
        fadingEdgeStartFraction: 0.1,
        fadingEdgeEndFraction: 0.1,
        startPadding: 10.0,
        accelerationDuration: Duration(seconds: 1),
        accelerationCurve: Curves.linear,
        decelerationDuration: Duration(milliseconds: 500),
        decelerationCurve: Curves.easeOut,
      ),
    );
  }



  Widget _buildSubtitle(BuildContext context) {
    return Text(
      "Réécoutez toutes vos émissions préférées",
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontSize: 18,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildPlayerControls(BuildContext context, ArchiveProvider archiveProvider) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildSliderSection(context, archiveProvider),
        _buildTimeDisplay(archiveProvider),
        const SizedBox(height: 30.0),
        _buildControlButtons(context, archiveProvider),
      ],
    );
  }

  Widget _buildSliderSection(BuildContext context, ArchiveProvider archiveProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: SliderTheme(
        data: SliderTheme.of(context).copyWith(
          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: _sliderThumbRadius),
          overlayShape: const RoundSliderOverlayShape(overlayRadius: _sliderOverlayRadius),
          inactiveTrackColor: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        child: Slider(
          min: 0.0,
          max: _getMaxSliderValue(archiveProvider),
          value: _getSliderValue(archiveProvider),
          activeColor: Theme.of(context).colorScheme.primary,
          inactiveColor: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.2),
          onChangeStart: (value) => _onSliderChangeStart(value),
          onChanged: (value) => _onSliderChanged(value),
          onChangeEnd: (value) => _onSliderChangeEnd(value, archiveProvider),
        ),
      ),
    );
  }

  Widget _buildTimeDisplay(ArchiveProvider archiveProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(_formatTime(_getCurrentDisplayDuration(archiveProvider))),
          Text(_formatTime(archiveProvider.totalDuration)),
        ],
      ),
    );
  }

  Widget _buildControlButtons(BuildContext context, ArchiveProvider archiveProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildControlButton(
            context,
            AppIcons.skipPrevious,
            () => _onSkipPrevious(archiveProvider),
          ),
          _buildControlButton(
            context,
            AppIcons.rewindBackward,
            () => _onRewind(archiveProvider),
          ),
          _buildPlayPauseButton(context, archiveProvider),
          _buildControlButton(
            context,
            AppIcons.rewindForward,
            () => _onFastForward(archiveProvider),
          ),
          _buildControlButton(
            context,
            AppIcons.skipForward,
            () => _onSkipNext(archiveProvider),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton(BuildContext context, IconData icon, VoidCallback onTap) {
    return IconButton.filledTonal(
      onPressed: onTap,
      icon: Icon(
        icon,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }

  Widget _buildPlayPauseButton(BuildContext context, ArchiveProvider archiveProvider) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(30),
      ),
      child: IconButton(
        icon: Icon(
          archiveProvider.audioPlayerIsPlaying ? AppIcons.pause : AppIcons.playFill,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        iconSize: _playButtonSize,
        onPressed: () => archiveProvider.pauseOrResume(),
      ),
    );
  }

  // Méthodes utilitaires
  void _updateVinylAnimation(bool isPlaying) {
    if (isPlaying) {
      _vinylController.repeat();
    } else {
      _vinylController.stop();
    }
  }

  String _formatTime(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  double _getMaxSliderValue(ArchiveProvider archiveProvider) {
    return archiveProvider.totalDuration.inSeconds > 0
        ? archiveProvider.totalDuration.inSeconds.toDouble()
        : 1.0;
  }

  double _getSliderValue(ArchiveProvider archiveProvider) {
    if (_sliderValue != null) return _sliderValue!;
    
    final current = archiveProvider.currentDuration.inSeconds.toDouble();
    final total = archiveProvider.totalDuration.inSeconds.toDouble();
    
    if (total <= 0) return 0.0;
    if (current > total) return 0.0;
    
    return current;
  }

  Duration _getCurrentDisplayDuration(ArchiveProvider archiveProvider) {
    return _sliderValue != null
        ? Duration(seconds: _sliderValue!.toInt())
        : archiveProvider.currentDuration;
  }

  // Gestionnaires d'événements du slider
  void _onSliderChangeStart(double value) {
    setState(() => _sliderValue = value);
  }

  void _onSliderChanged(double value) {
    setState(() => _sliderValue = value);
  }

  void _onSliderChangeEnd(double value, ArchiveProvider archiveProvider) {
    archiveProvider.seek(Duration(seconds: value.toInt()));
    setState(() => _sliderValue = null);
  }

  // Gestionnaires des boutons de contrôle (à implémenter selon tes besoins)
  void _onSkipPrevious(ArchiveProvider archiveProvider) {
    // TODO: Implémenter la logique de piste précédente
    archiveProvider.playNextArchive();
  }

  void _onRewind(ArchiveProvider archiveProvider) {
    // TODO: Implémenter la logique de retour arrière (ex: -15 secondes)
  }

  void _onFastForward(ArchiveProvider archiveProvider) {
    // TODO: Implémenter la logique d'avance rapide (ex: +15 secondes)
  }

  void _onSkipNext(ArchiveProvider archiveProvider) {
    // TODO: Implémenter la logique de piste suivante
    archiveProvider.playNextArchive();
  }
}