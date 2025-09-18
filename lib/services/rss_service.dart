
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
        final listArchive = _getArchives(feed);
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