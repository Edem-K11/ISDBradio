import 'package:flutter/material.dart';
import 'package:isdb_radio/pages/research_archive_page.dart';
import 'package:isdb_radio/widgets/archive_record_tile.dart';

class CustomScrollPage extends StatelessWidget {
const CustomScrollPage({ super.key });

  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 100.0,
            toolbarHeight: 60.0,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text('Archive'),
              titlePadding: EdgeInsets.all(16.0),
            ),
          ),

          SliverAppBar(
            flexibleSpace: FlexibleSpaceBar(
              background: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Réécouter toutes émissions préférées en replay/podcast sur Radio ISDB',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.0,
                  ),
                ),
              ),
            ),
          ),
          
          SliverAppBar(
            toolbarHeight: 50.0,
            expandedHeight: 50.0,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: GestureDetector(
                onTap: () {
                  // Handle search tap
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ResearchArchivePage()),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    height: 40.0,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.search, color: Theme.of(context).colorScheme.onPrimary),
                        SizedBox(width: 8.0),
                        Text(
                          'Podcasts and Archives',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return ArchiveRecordTile();
              },
              childCount: 20, // Number of items in the list
            ),
          ),
          // SliverGrid(),
          // SliverToBoxAdapter(),
          // SliverFillRemaining(),
          // SliverPadding()
        ]
      ),
    );
  }
}