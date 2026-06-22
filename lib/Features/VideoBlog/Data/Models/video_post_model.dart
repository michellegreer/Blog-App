import 'package:blog_app/Features/VideoBlog/Domain/Entities/video_post.dart';

class VideoPostModel extends VideoPost {
  const VideoPostModel({
    required super.id,
    required super.title,
    required super.youtubeUrl,
    super.commentary,
    required super.createdAt,
    super.postedByName,
    super.postedById,
    super.posterAvatarUrl,
    super.visibilityCircleType,
    super.visibilityCircleId,
    super.isPublic,
  });

  factory VideoPostModel.fromJson(Map<String, dynamic> json) {
    return VideoPostModel(
      id: json['id'] as String,
      title: json['title'] as String,
      youtubeUrl: json['youtube_url'] as String,
      commentary: json['commentary'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      postedByName: json['posted_by_name'] as String?,
      postedById: json['posted_by_id'] as String?,
      posterAvatarUrl: json['poster_avatar_url'] as String?,
      visibilityCircleType:
          CircleType.fromDb(json['visibility_circle_type'] as String?),
      visibilityCircleId: json['visibility_circle_id'] as String?,
      isPublic: json['is_public'] as bool? ?? false,
    );
  }
}
