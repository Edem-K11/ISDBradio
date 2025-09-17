import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:isdb_radio/pages/listen_archive_page.dart';
import 'package:isdb_radio/pages/research_archive_page.dart';
import 'package:isdb_radio/providers/archive_provider.dart';
import 'package:isdb_radio/widgets/archive_record_tile.dart';
import 'package:provider/provider.dart';

class ArchiveListPage extends StatelessWidget {
const ArchiveListPage({ super.key });

/// Navigate to song page and set current episode
  void _goToEpisode(BuildContext context, int archiveIndex) {
    final archiveProvider = Provider.of<ArchiveProvider>(context, listen: false);
    archiveProvider.setCurrentArchiveIndex(archiveIndex);
    print('Navigating to episode index: $archiveIndex');
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ListenArchivePage(),
      ),
    );
  }

/// Rafraîchir le podcast
  Future<void> _refreshArchive(BuildContext context) async {
    final archiveProvider = Provider.of<ArchiveProvider>(context, listen: false);
    await archiveProvider.refreshArchivesList();
  }

  @override
  Widget build(BuildContext context){
    return Consumer<ArchiveProvider>(
      builder: (context, archiveProvider, child) {
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
              SliverFillRemaining(
                child: _buildBody(context, archiveProvider),
              ),
            ]
          ),
        );
      }
    );
  }

  /// Construit le corps principal selon l'état
  Widget _buildBody(BuildContext context, ArchiveProvider archiveProvider) {
    if (archiveProvider.isLoading) {
      return _buildLoadingState();
    }
    
    if (archiveProvider.errorMessage != null) {
      return _buildErrorState(context, archiveProvider);
    }
    
    if (archiveProvider.playlist.isEmpty) {
      return _buildEmptyState();
    }
    
    return _buildEpisodesList(context, archiveProvider);
  }

  /// État de chargement
  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Chargement des épisodes...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  /// État d'erreur
  Widget _buildErrorState(BuildContext context, ArchiveProvider archiveProvider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            const Text(
              'Erreur de chargement',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              archiveProvider.errorMessage ?? 'Une erreur inconnue s\'est produite',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => _refreshArchive(context),
              child: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }

  /// État vide
  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_open,
            size: 80,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'Aucun épisode disponible',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Le podcast ne contient pas d\'épisodes',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  // Liste des Archives
  Widget _buildEpisodesList(BuildContext context, ArchiveProvider archiveProvider) {
    return RefreshIndicator(
      onRefresh: () => _refreshArchive(context),
      child: Column(
        children: [
          Expanded(
            child: ListView.separated(
              itemCount: archiveProvider.playlist.length,
              padding: const EdgeInsets.all(8.0),
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final archive = archiveProvider.playlist[index];
                final isCurrentArchive = archiveProvider.currentArchiveIndex == index;
                
                return Card(
                  elevation: isCurrentArchive ? 4 : 1,
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: _buildEpisodeImage(archive, archiveProvider),
                    title: Text(
                      archive.title,
                      style: TextStyle(
                        fontWeight: isCurrentArchive ? FontWeight.bold : FontWeight.normal,
                        color: isCurrentArchive 
                            ? Theme.of(context).colorScheme.primary 
                            : null,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (archive.author != null) ...[
                          Text(
                            archive.author!,
                            style: TextStyle(
                              color: isCurrentArchive 
                                  ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.7)
                                  : Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                        ],
                        Row(
                          children: [
                            if (archive.publicationDate != null) ...[
                              Text(
                                _formatDate(archive.publicationDate!),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[500],
                                ),
                              ),
                              if (archive.duration != null) ...[
                                const Text(' • ', style: TextStyle(color: Colors.grey)),
                                Text(
                                  'archive.duration',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ] else if (archive.duration != null) ...[
                              Text(
                                'archive.duration',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                    trailing: isCurrentArchive
                        ? Icon(
                            archiveProvider.audioPlayerIsPlaying ? Icons.pause : Icons.play_arrow,
                            color: Theme.of(context).colorScheme.primary,
                          )
                        : const Icon(Icons.play_arrow, color: Colors.grey),
                    onTap: () => _goToEpisode(context, index),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Formate une date pour l'affichage
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Aujourd\'hui';
    } else if (difference.inDays == 1) {
      return 'Hier';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} jours';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks semaine${weeks > 1 ? 's' : ''}';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months mois';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years an${years > 1 ? 's' : ''}';
    }
  }


  /// Image d'un épisode
  Widget _buildEpisodeImage(archive, ArchiveProvider archiveProvider) {
    final imageUrl = archive.imageUrl;
    
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: imageUrl != null
          ? CachedNetworkImage(
              imageUrl: imageUrl,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                width: 60,
                height: 60,
                color: Colors.grey[300],
                child: const Icon(Icons.image, color: Colors.white70),
              ),
              errorWidget: (context, url, error) => Container(
                width: 60,
                height: 60,
                color: Colors.grey[300],
                child: const Icon(Icons.broken_image, color: Colors.white70),
              ),
            )
          : Container(
              width: 60,
              height: 60,
              color: Colors.grey[300],
              child: const Icon(Icons.image, color: Colors.white70),
            ),
    ); 
  }
}