
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:isdb_radio/models/archive.dart';
import 'package:webfeed/domain/rss_feed.dart';
import 'package:webfeed/domain/rss_item.dart';

class RssService {
  static const String _defaultFeedUrl =
      "https://radiofrance-podcast.net/podcast09/rss_10076.xml"; // Exemple France Inter
  
  static const String isdbImage = 'assets/images/logo_isdb.png';

  Future<List<Archive>?> fetchFeed(String? url) async {
    final feedUrl = url ?? _defaultFeedUrl;

    try {
      final response = await http.get(Uri.parse(feedUrl));
      if (response.statusCode == 200) {
        final feed = RssFeed.parse(response.body);
        print("Renvoie des archives à archive provider");
        final listArchive = _getArchives(feed);
        print("Voici la liste des archives obtenue : $listArchive");
        return listArchive;
        
      } else {
        throw Exception("Erreur serveur: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Erreur chargement RSS: $e");
      return null;
    }
    
  }

  List<Archive> _getArchives(RssFeed feed) {
    final items = feed.items ?? [];

    return items.map((RssItem item) {
      final title = item.title ?? "Sans titre";
      final audioUrl = item.enclosure?.url ?? "";
      final imageUrl = item.itunes?.image?.href ?? isdbImage;
      final author = item.itunes?.author ?? item.author;
      final publicationDate = item.pubDate;
      final durationStr = item.itunes?.duration;

      // if (durationStr != null && durationStr is String) {
      //   final parts = durationStr.split(':').map(int.parse).toList();
      //   if (parts.length == 3) {
      //     duration = Duration(
      //       hours: parts[0],
      //       minutes: parts[1],
      //       seconds: parts[2],
      //     );
      //   } else if (parts.length == 2) {
      //     duration = Duration(
      //       minutes: parts[0],
      //       seconds: parts[1],
      //     );
      //   } else if (parts.length == 1) {
      //     duration = Duration(seconds: parts[0]);
      //   }
      // }

      return Archive(
        title: title,
        audioUrl: audioUrl,
        imageUrl: imageUrl,
        author: author,
        publicationDate: publicationDate,
        duration: durationStr);
    }).toList();
  }

}