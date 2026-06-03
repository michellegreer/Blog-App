import 'package:fpdart/fpdart.dart';
import 'package:blog_app/Core/Errors/failure.dart';
import 'package:blog_app/Core/UseCAses/usecase.dart';
import 'package:blog_app/Features/VideoBlog/Domain/Entities/video_post.dart';
import 'package:blog_app/Features/VideoBlog/Domain/Repositories/video_post_repository.dart';

class GetAllVideoPosts implements UseCase<List<VideoPost>, NoParams> {
  final VideoPostRepository repository;
  const GetAllVideoPosts(this.repository);

  @override
  Future<Either<Failure, List<VideoPost>>> call(NoParams params) {
    return repository.getAllVideoPosts();
  }
}
