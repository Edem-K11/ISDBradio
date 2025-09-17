
import 'package:flutter/material.dart';
import 'package:isdb_radio/providers/streaming_provider.dart';
import 'package:provider/provider.dart';

import '../themes/theme.dart';

class StreamingMiniPlayer extends StatelessWidget {
  const StreamingMiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<StreamingProvider>(
      builder: (context, streamingProvider, child) {
        // Ne pas afficher le mini player si le streaming n'est pas actif
        if (!streamingProvider.radioActive) {
          return const SizedBox.shrink();
        }
        
        return Container(
          height: 70,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha((0.1 * 255).toInt()),
                blurRadius: 4,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {},
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    // Image de la station
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: AssetImage(streamingProvider.stationImagePath),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 12),
                    
                    // Informations de la station
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            streamingProvider.stationName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          // Indicateur Live
                          if (streamingProvider.isLive)
                            Row(
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Text(
                                  'LIVE',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                    
                    // Bouton de contrôle
                    IconButton(
                      icon: Icon(
                        streamingProvider.radioIsPlaying 
                            ? AppIcons.pause 
                            : AppIcons.playFill,
                        size: 28,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      onPressed: () {
                        streamingProvider.toggleStreaming();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}