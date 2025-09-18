
class Archive {
  final String title;
  final String audioUrl;
  final String? imageUrl;
  final String? author;
  final DateTime? publicationDate;
  final Duration? duration;

  Archive({
    required this.title,
    required this.audioUrl,
    this.imageUrl,
    this.author,
    this.publicationDate,
    this.duration,
  });

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