
import 'package:flutter/material.dart';
import 'package:isdb_radio/widgets/archive_record_tile.dart';
import 'package:isdb_radio/widgets/recent_research.dart';

class ResearchArchivePage extends StatelessWidget {
const ResearchArchivePage({ super.key });

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 40.0,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: TextField(
              decoration: InputDecoration(
                suffixIcon: Icon(Icons.close, color: Theme.of(context).colorScheme.onSurface),
                hintText: 'Rechercher émission, sujet, mot-clé...',
                hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha:0.6)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.0),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4), // bordure claire quand inactif
                    width: 1.0,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.0),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.onSurface, // bordure bien blanche quand focus
                    width: 1.5,
                  ),
                ),
              ),
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface), // pour le texte saisi
              cursorColor: Theme.of(context).colorScheme.onSurface, // curseur blanc
            ),
          ),
      
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Recherches récentes', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: () {
                    // Action pour effacer les recherches récentes
                  },
                  child: Text('Tout effacer', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
                ),
              ],
            ),
          ),
      
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
            child: SizedBox(
              height: 50.0,
              child: ListView(
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                children: [
                  RecentResearch(text: 'Education'),
                  RecentResearch(text: 'Health'),
                  RecentResearch(text: 'Development'),
                  RecentResearch(text: 'Economy'),
                  RecentResearch(text: 'Agriculture'),
                  RecentResearch(text: 'Technology'),
                ],
              ),
            ),
          ),
      
          SizedBox(height: 10.0),
          Expanded(
            child: ListView.builder(
              itemCount: 10, // Remplacez par le nombre d'éléments de recherche récents
              itemBuilder: (context, index) {
                return ArchiveRecordTile();
              },
            ),
          ),
        ],
      ),
    );
  }
}