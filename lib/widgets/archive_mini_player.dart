

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:isdb_radio/providers/archive_provider.dart';
import 'package:isdb_radio/pages/listen_archive_page.dart';
import 'package:provider/provider.dart';

import '../themes/theme.dart';

class ArchiveMiniPlayer extends StatelessWidget {
  const ArchiveMiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ArchiveProvider>(
      builder: (context, archiveProvider, child) {
        // Ne pas afficher le mini player s'il n'y a pas de chanson en cours
        if (archiveProvider.currentArchiveIndex == null) {
          return SizedBox.shrink();
        }

        final currentArchive = archiveProvider.currentArchive!;
        
        return Container(
          height: 70,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 4,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                // Navigation vers la page de la chanson
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ListenArchivePage()),
                );
              },
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    // Image de l'album
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: currentArchive.imageUrl!.isNotEmpty
                              ? CachedNetworkImageProvider(currentArchive.imageUrl!)
                              : AssetImage('assets/images/logo_isdb.png') as ImageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    
                    SizedBox(width: 12),
                    
                    // Informations de la chanson
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            currentArchive.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 2),
                          Text(
                            currentArchive.author ?? 'Inconnu',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    
                    // Boutons de contrôle
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            archiveProvider.audioPlayerIsPlaying
                                ? AppIcons.pauseFill 
                                : AppIcons.play,
                            size: 28,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          onPressed: () {
                            archiveProvider.pauseOrResume();
                          },
                        ),
                        
                        IconButton(
                          icon: Icon(
                            AppIcons.skipForward, 
                            size: 28,
                            color: Theme.of(context).colorScheme.primary,),
                          onPressed: () {
                            archiveProvider.playNextArchive();
                          },
                        ),
                      ],
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
