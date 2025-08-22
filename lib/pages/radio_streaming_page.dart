
import 'package:flutter/material.dart';
import 'package:isdb_radio/models/navigation_provider.dart';
import 'package:isdb_radio/widgets/audio_animation.dart';
import 'package:isdb_radio/widgets/my_drawer.dart';
import 'package:provider/provider.dart';

class RadioStreamingPage extends StatefulWidget {
const RadioStreamingPage({ super.key });

  @override
  State<RadioStreamingPage> createState() => _RadioStreamingPageState();
}

class _RadioStreamingPageState extends State<RadioStreamingPage>
    with TickerProviderStateMixin {

  late AnimationController _vinylController;
  late AnimationController _waveController;
  late AnimationController _audioWaveController;
  bool _isPlaying = false;

  void togglePlay() {
    setState(() {
      _isPlaying = !_isPlaying;
      if (_isPlaying) {
        _vinylController.repeat();
      } else {
        _vinylController.stop();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    
    _vinylController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    
    _waveController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    
    _audioWaveController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _vinylController.dispose();
    _waveController.dispose();
    _audioWaveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context){
    return Consumer<NavigationProvider>(
      builder: (context, navigationProvider, child) {
        return Scaffold(
          appBar: AppBar(
              backgroundColor: Colors.transparent,
              foregroundColor: Theme.of(context).colorScheme.onSurface,
              elevation: 0,
              leading: Builder(
                builder: (BuildContext innerContext) {
                  return IconButton(
                    onPressed: () {
                      Scaffold.of(innerContext).openDrawer();
                    },
                    icon: const Icon(Icons.menu),
                  );
                },
              ),
          ),  
          drawer: const MyDrawer(),
          body: Column(
            children: [
        
              // Header with title
              _buildStationInfo(context),
        
              SizedBox(height: 10.0),
              
              RadioWavyLineAndVynilRotation(
                waveController: _waveController, 
                isPlaying: _isPlaying, 
                vinylController: _vinylController, 
              ),
        
              SizedBox(height: 10.0),

              AudioWaveAndLiveIndicator(
                audioWaveController: _audioWaveController, 
                isPlaying: _isPlaying
              ),
        
              // Play button with volume control
              _buildPlayButtonWithVolumeControl(context),
            ],
          ),
        );
      }
    );
  }

  Widget _buildStationInfo(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'INSTITUT SUPERIEUR DON BOSCO',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 15),
            Container(
              height: 2,
              width: 200.0,
              color: Colors.black54,
            ),
      
          ],
        ),
      ),
    );
  }

  /// Construit le bouton de lecture avec contrôles de volume
  Widget _buildPlayButtonWithVolumeControl (BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Speaker icon gauche
          const SizedBox(
            width: 28,
            height: 28,
            ),
          
          // Play/Pause button central
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                  spreadRadius: 2,
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(40),
                onTap: togglePlay ,// streamingProvider.toggleStreaming,
                child: Center(
                  child: _isPlaying
                  // streamingProvider.isLoading
                  //   ? const SizedBox(
                  //       width: 30,
                  //       height: 30,
                  //       child: CircularProgressIndicator(
                  //         color: Colors.white,
                  //         strokeWidth: 3,
                  //       ),
                  //     )
                  //   : Icon(
                  //       streamingProvider.isStreaming
                  //           ? Icons.pause
                  //           : Icons.play_arrow,
                  //       color: Colors.white,
                  //       size: 40,
                  //     ),
                  ? Icon(
                      Icons.pause,
                      color: Colors.white,
                      size: 30,
                    )
                  : Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 30,
                    ),
                  )
                ),
              ),
            ),

               // Volume icon droit
          GestureDetector(
            onTap: () {
              // setState(() {
              //   showVolumeSlider = !showVolumeSlider;
              // });
            },
            child: const Icon(
              Icons.volume_up,
              size: 28,
              color: Colors.grey,
            ),
          ),
        ],
      ),
      );
  
  }


}


