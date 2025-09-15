
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

  @override
  String toString() {
    return 'Archive(title: $title, audioUrl: $audioUrl, imageUrl: $imageUrl, author: $author, publicationDate: $publicationDate, duration: $duration)';
  }
}