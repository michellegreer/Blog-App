import 'package:fpdart/fpdart.dart';
import 'package:blog_app/Core/Errors/failure.dart';
import 'package:blog_app/Core/UseCAses/usecase.dart';
import 'package:blog_app/Features/VideoBlog/Domain/Entities/video_post.dart';
import 'package:blog_app/Features/VideoBlog/Domain/Repositories/video_post_repository.dart';

class UpdateVideoPostParams {
  final String id;
  final String title;
  final String youtubeUrl;
  final String? commentary;
  const UpdateVideoPostParams({
    required this.id,
    required this.title,
    required this.youtubeUrl,
    this.commentary,
  });
}

class UpdateVideoPost implements UseCase<VideoPost, UpdateVideoPostParams> {
  final VideoPostRepository repository;
  const UpdateVideoPost(this.repository);

  @override
  Future<Either<Failure, VideoPost>> call(UpdateVideoPostParams params) {
    return repository.updateVideoPost(
      id: params.id,
      title: params.title,
      youtubeUrl: params.youtubeUrl,
      commentary: params.commentary,
    );
  }
}
