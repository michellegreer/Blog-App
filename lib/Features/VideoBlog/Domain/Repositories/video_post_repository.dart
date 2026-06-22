import 'package:fpdart/fpdart.dart';
import 'package:blog_app/Core/Errors/failure.dart';
import 'package:blog_app/Features/VideoBlog/Domain/Entities/video_post.dart';

abstract interface class VideoPostRepository {
  Future<Either<Failure, List<VideoPost>>> getAllVideoPosts();
  Future<Either<Failure, VideoPost>> createVideoPost({
    required String title,
    required String youtubeUrl,
    String? commentary,
    String? postedByName,
    String? postedById,
    String? posterAvatarUrl,
    String? visibilityCircleType,
    String? visibilityCircleId,
    bool isPublic,
  });
  Future<Either<Failure, VideoPost>> updateVideoPost({
    required String id,
    required String title,
    required String youtubeUrl,
    String? commentary,
    String? visibilityCircleType,
    String? visibilityCircleId,
    bool isPublic,
  });
  Future<Either<Failure, Unit>> deleteVideoPost(String id);
  Future<Either<Failure, VideoPost>> getVideoByIdPrefix(String idPrefix);
}
