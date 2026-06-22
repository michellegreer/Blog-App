import 'package:fpdart/fpdart.dart';
import 'package:blog_app/Core/Errors/failure.dart';
import 'package:blog_app/Core/UseCAses/usecase.dart';
import 'package:blog_app/Features/VideoBlog/Domain/Entities/video_post.dart';
import 'package:blog_app/Features/VideoBlog/Domain/Repositories/video_post_repository.dart';

class GetVideoByIdPrefix implements UseCase<VideoPost, String> {
  final VideoPostRepository repository;
  const GetVideoByIdPrefix(this.repository);

  @override
  Future<Either<Failure, VideoPost>> call(String idPrefix) {
    return repository.getVideoByIdPrefix(idPrefix);
  }
}
