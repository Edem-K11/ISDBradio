
import 'package:flutter/material.dart';
import 'package:isdb_radio/widgets/audio_animation.dart';

class ListenArchivePage extends StatefulWidget {
const ListenArchivePage({ super.key });

  @override
  State<ListenArchivePage> createState() => _ListenArchivePageState();
}

class _ListenArchivePageState extends State<ListenArchivePage>
    with TickerProviderStateMixin {


  late AnimationController _vinylController;
  late AnimationController _waveController;
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
    
  }

  @override
  void dispose() {
    _vinylController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          iconSize: 40,
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: Theme.of(context).colorScheme.onSurface,),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: Column(
        children: [
          RadioWavyLineAndVynilRotation(
            waveController: _waveController, 
            isPlaying: _isPlaying, 
            vinylController: _vinylController
          ),

          SizedBox(height: 10.0),

          Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Emission",
                  style: TextStyle(
                    fontSize: 24,
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            
                Text(
                  "Réecoutez toutes vos emissions préférées",
                  style: TextStyle(
                    fontSize: 18,
                  ),
                )
              ],
            ),
          ),
          SizedBox(height: 5.0),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0  ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8),
                        overlayShape: RoundSliderOverlayShape(overlayRadius: 14),
                        inactiveTrackColor: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      child: Slider(
                        value: 0.5, 
                        onChanged: (index){},
                      )
                    ), 
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("0:00"),
                        Text("3:30"),
                      ],
                    ),
                  ],
                ),

                SizedBox(height: 30.0),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton.filledTonal(
                      onPressed: (){}, 
                      icon: Icon(Icons.skip_previous, color: Theme.of(context).colorScheme.onSurface,),
                    ),
                    IconButton.filledTonal(
                      onPressed: (){}, 
                      icon: Icon(Icons.skip_previous, color: Theme.of(context).colorScheme.onSurface,),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: IconButton(
                        icon: Icon(
                          _isPlaying ? Icons.pause : Icons.play_arrow,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        iconSize: 40,
                        onPressed: togglePlay,
                      ),
                    ),
                    IconButton.filledTonal(
                      onPressed: (){}, 
                      icon: Icon(Icons.skip_next, color: Theme.of(context).colorScheme.onSurface,),
                    ),
                    IconButton.filledTonal(
                      onPressed: (){}, 
                      icon: Icon(Icons.skip_next, color: Theme.of(context).colorScheme.onSurface,),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
        ],
      ),
    );
  }
}