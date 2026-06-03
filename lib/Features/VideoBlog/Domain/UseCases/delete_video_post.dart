import 'package:fpdart/fpdart.dart';
import 'package:blog_app/Core/Errors/failure.dart';
import 'package:blog_app/Core/UseCAses/usecase.dart';
import 'package:blog_app/Features/VideoBlog/Domain/Repositories/video_post_repository.dart';

class DeleteVideoPost implements UseCase<Unit, String> {
  final VideoPostRepository repository;
  const DeleteVideoPost(this.repository);

  @override
  Future<Either<Failure, Unit>> call(String id) {
    return repository.deleteVideoPost(id);
  }
}
