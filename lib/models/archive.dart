
import 'package:hive/hive.dart';

part 'archive.g.dart'; // Fichier généré automatiquement

@HiveType(typeId: 0) // ID unique pour ce type
class Archive extends HiveObject {
 @HiveField(0)
  final String title;
  
  @HiveField(1)
  final String audioUrl;
  
  @HiveField(2)
  final String? imageUrl;
  
  @HiveField(3)
  final String? author;
  
  @HiveField(4)
  final DateTime? publicationDate;
  
  @HiveField(5)
  final Duration? duration;
  
  @HiveField(6)
  final DateTime cachedAt; // Quand on l'a mis en cache

  Archive({
    required this.title,
    required this.audioUrl,
    this.imageUrl,
    this.author,
    this.publicationDate,
    this.duration,
    DateTime? cachedAt,
  }): cachedAt = cachedAt ?? DateTime.now();

  // Nouvelles propriétés pour le cache
  bool? _isImageCached;
  bool? _isAudioPreloaded;
  Map<String, dynamic>? _audioMetadata;
  
  // Getters pour optimisation
  bool get isImageCached => _isImageCached ?? false;
  bool get isAudioPreloaded => _isAudioPreloaded ?? false;
  Map<String, dynamic>? get audioMetadata => _audioMetadata;
  
  // Setters pour mise à jour du cache
  void markImageAsCached() => _isImageCached = true;
  void markAudioAsPreloaded(Map<String, dynamic> metadata) {
    _isAudioPreloaded = true;
    _audioMetadata = metadata;
  }

  @override
  String toString() {
    return 'Archive(title: $title, audioUrl: $audioUrl, imageUrl: $imageUrl, author: $author, publicationDate: $publicationDate, duration: $duration)';
  }
}