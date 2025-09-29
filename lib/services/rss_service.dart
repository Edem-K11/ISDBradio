import 'dart:async';
import 'dart:isolate';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:isdb_radio/models/archive.dart';
import 'package:webfeed/domain/rss_feed.dart';
import 'package:webfeed/domain/rss_item.dart';

class RssService {
  static const String _defaultFeedUrl =
      "https://radiofrance-podcast.net/podcast09/rss_10076.xml";
  
  static const String isdbImage = 'assets/images/logo_isdb.png';
  
  // Cache pour éviter les rechargements
  List<Archive>? _cachedArchives;
  DateTime? _lastCacheTime;
  static const Duration _cacheTimeout = Duration(minutes: 15);
  
  // Stream controller pour les mises à jour progressives
  final StreamController<List<Archive>> _archivesController = 
      StreamController<List<Archive>>.broadcast();
  
  Stream<List<Archive>> get archivesStream => _archivesController.stream;

  Future<List<Archive>?> fetchFeed(String? url) async {
    final feedUrl = url ?? _defaultFeedUrl;

    try {
      // Vérifier le cache d'abord
      if (_cachedArchives != null && _lastCacheTime != null) {
        if (DateTime.now().difference(_lastCacheTime!) < _cacheTimeout) {
          debugPrint("Utilisation du cache RSS");
          return _cachedArchives;
        }
      }

      debugPrint("Chargement RSS depuis le réseau...");
      final response = await http.get(Uri.parse(feedUrl));
      
      if (response.statusCode == 200) {
        // Parse en arrière-plan pour ne pas bloquer l'UI
        final archives = await _parseRssFeedInBackground(response.body);
        
        // Mettre à jour le cache
        _cachedArchives = archives;
        _lastCacheTime = DateTime.now();
        
        // Précharger les métadonnées audio en arrière-plan
        // _preloadAudioMetadata(archives);
        
        return archives;
      } else {
        throw Exception("Erreur serveur: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Erreur chargement RSS: $e");
      
      // Retourner le cache en cas d'erreur réseau
      if (_cachedArchives != null) {
        debugPrint("Utilisation du cache en cas d'erreur");
        return _cachedArchives;
      }
      return null;
    }
  }

  // Parse RSS en arrière-plan pour éviter de bloquer l'UI
  Future<List<Archive>> _parseRssFeedInBackground(String xmlContent) async {
    if (kIsWeb) {
      // Sur le web, exécuter directement (les isolates ne sont pas supportés)
      return _parseRssContent(xmlContent);
    } else {
      // Sur mobile, utiliser un isolate
      return await compute(_parseRssContent, xmlContent);
    }
  }

  // Fonction statique pour le parsing (nécessaire pour compute/isolate)
  static List<Archive> _parseRssContent(String xmlContent) {
    try {
      final feed = RssFeed.parse(xmlContent);
      final items = feed.items ?? [];

      return items.map((RssItem item) {
        final title = item.title ?? "Sans titre";
        final audioUrl = item.enclosure?.url ?? "";
        final imageUrl = item.itunes?.image?.href ?? isdbImage;
        final author = item.itunes?.author ?? item.author;
        final publicationDate = item.pubDate;
        final durationStr = item.itunes?.duration;

        return Archive(
          title: title,
          audioUrl: audioUrl,
          imageUrl: imageUrl,
          author: author,
          publicationDate: publicationDate,
          duration: durationStr,
        );
      }).toList();
    } catch (e) {
      debugPrint("Erreur parsing RSS: $e");
      return [];
    }
  }

  // Précharger les métadonnées audio en arrière-plan
  void _preloadAudioMetadata(List<Archive> archives) {
    // Précharger seulement les 10 premiers épisodes pour éviter la surcharge
    final archivesToPreload = archives.take(10).toList();
    
    for (int i = 0; i < archivesToPreload.length; i++) {
      final archive = archivesToPreload[i];
      
      // Délai progressif pour éviter de surcharger le réseau
      Timer(Duration(milliseconds: i * 500), () {
        _preloadSingleArchive(archive);
      });
    }
  }

  // Précharger une archive individuelle
  Future<void> _preloadSingleArchive(Archive archive) async {
    try {
      if (archive.audioUrl.isNotEmpty) {
        // Faire une requête HEAD pour récupérer les métadonnées sans télécharger le fichier
        final response = await http.head(
          Uri.parse(archive.audioUrl),
          headers: {'Range': 'bytes=0-1023'}, // Juste les premiers octets
        ).timeout(Duration(seconds: 5));
        
        if (response.statusCode == 206 || response.statusCode == 200) {
          debugPrint("Métadonnées préchargées pour: ${archive.title}");
          
          // Optionnel: Extraire les métadonnées réelles du fichier audio
          // (taille, durée exacte, etc.)
          final contentLength = response.headers['content-length'];
          if (contentLength != null) {
            // Stocker les informations de taille, etc.
          }
        }
      }
    } catch (e) {
      debugPrint("Erreur préchargement ${archive.title}: $e");
      // Continuer silencieusement, ce n'est pas critique
    }
  }

  // Précharger les images
  Future<void> preloadImages(List<Archive> archives, BuildContext context) async {
    final imagesToPreload = archives.take(20).toList(); // Précharger 20 images
    
    for (int i = 0; i < imagesToPreload.length; i++) {
      final archive = imagesToPreload[i];
      
      Timer(Duration(milliseconds: i * 200), () {
        if (archive.imageUrl != null && archive.imageUrl!.startsWith('http')) {
          // Utiliser le cache d'images de Flutter
          precacheImage(NetworkImage(archive.imageUrl!), context)
              .catchError((error) {
            debugPrint("Erreur préchargement image ${archive.title}: $error");
          });
        }
      });
    }
  }

  // Nettoyer le cache si nécessaire
  void clearCache() {
    _cachedArchives = null;
    _lastCacheTime = null;
    debugPrint("Cache RSS nettoyé");
  }

  // Obtenir des métadonnées de base d'un fichier audio
  Future<Map<String, dynamic>?> getAudioMetadata(String audioUrl) async {
    try {
      final response = await http.head(Uri.parse(audioUrl))
          .timeout(Duration(seconds: 3));
      
      if (response.statusCode == 200) {
        return {
          'contentLength': response.headers['content-length'],
          'contentType': response.headers['content-type'],
          'lastModified': response.headers['last-modified'],
        };
      }
    } catch (e) {
      debugPrint("Erreur métadonnées audio dans Rss: $e");
    }
    return null;
  }

  void dispose() {
    _archivesController.close();
  }
}