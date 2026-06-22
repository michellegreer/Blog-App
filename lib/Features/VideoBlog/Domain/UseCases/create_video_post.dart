import 'package:fpdart/fpdart.dart';
import 'package:blog_app/Core/Errors/failure.dart';
import 'package:blog_app/Core/UseCAses/usecase.dart';
import 'package:blog_app/Features/VideoBlog/Domain/Entities/video_post.dart';
import 'package:blog_app/Features/VideoBlog/Domain/Repositories/video_post_repository.dart';

class CreateVideoPostParams {
  final String title;
  final String youtubeUrl;
  final String? commentary;
  final String? postedByName;
  final String? postedById;
  final String? posterAvatarUrl;
  final String? visibilityCircleType;
  final String? visibilityCircleId;
  final bool isPublic;

  const CreateVideoPostParams({
    required this.title,
    required this.youtubeUrl,
    this.commentary,
    this.postedByName,
    this.postedById,
    this.posterAvatarUrl,
    this.visibilityCircleType,
    this.visibilityCircleId,
    this.isPublic = false,
  });
}

class CreateVideoPost implements UseCase<VideoPost, CreateVideoPostParams> {
  final VideoPostRepository repository;
  const CreateVideoPost(this.repository);

  @override
  Future<Either<Failure, VideoPost>> call(CreateVideoPostParams params) {
    return repository.createVideoPost(
      title: params.title,
      youtubeUrl: params.youtubeUrl,
      commentary: params.commentary,
      postedByName: params.postedByName,
      postedById: params.postedById,
      posterAvatarUrl: params.posterAvatarUrl,
      visibilityCircleType: params.visibilityCircleType,
      visibilityCircleId: params.visibilityCircleId,
      isPublic: params.isPublic,
    );
  }
}
