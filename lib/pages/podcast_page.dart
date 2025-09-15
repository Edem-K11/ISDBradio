
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:webfeed/webfeed.dart';
import 'package:just_audio/just_audio.dart';

class PodcastPage extends StatefulWidget {
  const PodcastPage({super.key});

  @override
  State<PodcastPage> createState() => _PodcastPageState();
}

class _PodcastPageState extends State<PodcastPage> {
  late final AudioPlayer _player;
  RssFeed? _feed;
  bool _loading = true;

  static const String feedUrl =
      "https://radiofrance-podcast.net/podcast09/rss_10076.xml"; // Exemple France Inter

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _loadFeed();
  }

  Future<void> _loadFeed() async {
    try {
      final response = await http.get(Uri.parse(feedUrl));
      if (response.statusCode == 200) {
        final feed = RssFeed.parse(response.body);
        print(feed.title);
        setState(() {
          _feed = feed;
          _loading = false;
        });
      } else {
        throw Exception("Erreur serveur: ${response.statusCode}");
      }
    } catch (e) {
      setState(() => _loading = false);
      debugPrint("Erreur chargement RSS: $e");
    }
  }

  Future<void> _playEpisode(String url) async {
    try {
      await _player.setUrl(url);
      _player.play();
    } catch (e) {
      debugPrint("Erreur lecture: $e");
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Podcast France Inter")),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _feed == null
              ? const Center(child: Text("Impossible de charger le flux RSS"))
              : ListView.builder(
                  itemCount: _feed!.items!.length,
                  itemBuilder: (context, index) {
                    final item = _feed!.items![index];
                    final audioUrl = item.enclosure?.url ?? "";

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 6, horizontal: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                      child: ListTile(
                        title: Text(
                          item.title ?? "Épisode sans titre",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          item.pubDate?.toString() ?? "Date inconnue",
                          style: const TextStyle(fontSize: 12),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.play_arrow),
                          onPressed: audioUrl.isNotEmpty
                              ? () => _playEpisode(audioUrl)
                              : null,
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}


