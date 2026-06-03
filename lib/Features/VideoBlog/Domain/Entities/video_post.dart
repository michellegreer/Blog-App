class VideoPost {
  final String id;
  final String title;
  final String youtubeUrl;
  final String? commentary;
  final DateTime createdAt;
  final String? postedByName;
  final String? postedById;
  final String? posterAvatarUrl;

  const VideoPost({
    required this.id,
    required this.title,
    required this.youtubeUrl,
    this.commentary,
    required this.createdAt,
    this.postedByName,
    this.postedById,
    this.posterAvatarUrl,
  });
}
