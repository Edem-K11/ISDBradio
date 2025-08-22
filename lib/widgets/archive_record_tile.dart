
import 'package:flutter/material.dart';
import 'package:isdb_radio/pages/listen_archive_page.dart';

class ArchiveRecordTile extends StatelessWidget {
const ArchiveRecordTile({ super.key });

  @override
  Widget build(BuildContext context){

    final logoProvider = AssetImage('assets/images/logo_isdb.png');

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        padding: const EdgeInsets.all(8.0),
        // margin: const EdgeInsets.only(bottom: 2.0),
        // height: 70.0,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Row(
          children: [
            // Image de l'archive
            CircleAvatar(
              backgroundImage: logoProvider,
              radius: 30.0,
            ),
            SizedBox(width: 16.0),
            
            // Détails de l'archive
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Titre de l\'archive avec beaucoup de détails pour donner un aperçu de son contenu.',
                    style: TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 2.0),
                  Text(
                    'Description de l\'archive',
                    style: TextStyle(
                      fontSize: 14.0,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 2.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Samedi 09 novembre 2024',
                        style: TextStyle(
                          fontSize: 10.0,
                          color: Colors.grey[500],
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            '30 min',
                            style: TextStyle(
                              fontSize: 10.0,
                              color: Colors.grey[500],
                            ),
                          ),
                          SizedBox(width: 8.0),
                          CircleAvatar(
                            radius: 14.0,
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            child: IconButton(
                              icon: Icon(
                                Icons.play_arrow,
                                color: Theme.of(context).colorScheme.surface,
                                size: 12,
                              ),
                              onPressed: () {
                                // Action pour écouter l'archive
                                Navigator.push(
                                  context, 
                                  MaterialPageRoute(
                                    builder: (context) => ListenArchivePage(),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ]
        ),
      ),
    );
  }
}