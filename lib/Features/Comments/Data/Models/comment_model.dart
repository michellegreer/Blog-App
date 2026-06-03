import 'package:blog_app/Features/Comments/Domain/Entities/comment.dart';

class CommentModel extends Comment {
  const CommentModel({
    required super.id,
    required super.videoPostId,
    required super.userId,
    required super.userName,
    super.userAvatarUrl,
    required super.content,
    required super.createdAt,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'] as String,
      videoPostId: json['video_post_id'] as String,
      userId: json['user_id'] as String,
      userName: json['user_name'] as String,
      userAvatarUrl: json['user_avatar_url'] as String?,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
