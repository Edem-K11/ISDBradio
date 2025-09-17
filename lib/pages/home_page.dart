import 'package:flutter/material.dart';
import 'package:isdb_radio/providers/archive_provider.dart';
import 'package:isdb_radio/providers/navigation_provider.dart';
import 'package:isdb_radio/providers/streaming_provider.dart';
import 'package:isdb_radio/widgets/archive_mini_player.dart';
import 'package:isdb_radio/widgets/my_bottom_navigation_bar.dart';
import 'package:isdb_radio/widgets/streaming_mini_player.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  
  void initState() {
    super.initState();
    // rien ici pour precacheImage
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // ✅ Ici c’est safe : context est prêt
    precacheImage(const AssetImage('assets/images/logo_isdb.png'), context);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<NavigationProvider, StreamingProvider, ArchiveProvider>(
      builder: (context, navigationProvider, streamingProvider, archiveProvider, child) {
        int currentIndex = navigationProvider.currentIndex;
        Widget currentPage = navigationProvider.currentPage;
        
        // Logique pour afficher le mini player de streaming
        final shouldShowStreamingMiniPlayer =  currentIndex != 0 && streamingProvider.radioActive; // && !archiveProvider.playListIsOn;

        // Logique pour afficher le mini player d'archive
        final shouldShowArchiveMiniPlayer =  archiveProvider.playListIsOn; // Évite d'avoir les deux en même temps
        
        return SafeArea(
          child: Scaffold(
            body: Stack(
              children: [
                Positioned.fill(
                  bottom: 0,
                  child: currentPage
                ),

                if (shouldShowStreamingMiniPlayer)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: const StreamingMiniPlayer(),
                  ),
                
                if (shouldShowArchiveMiniPlayer)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: const ArchiveMiniPlayer(),
                  ),
              ],
            ),
            bottomNavigationBar: const MyBottomNavigationBarWidget(),
          ),
        );
      },
    );
  }
}
