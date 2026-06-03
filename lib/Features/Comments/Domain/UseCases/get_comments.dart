import 'package:fpdart/fpdart.dart';
import 'package:blog_app/Core/Errors/failure.dart';
import 'package:blog_app/Core/UseCAses/usecase.dart';
import 'package:blog_app/Features/Comments/Domain/Entities/comment.dart';
import 'package:blog_app/Features/Comments/Domain/Repositories/comment_repository.dart';

class GetComments implements UseCase<List<Comment>, String> {
  final CommentRepository repository;
  const GetComments(this.repository);

  @override
  Future<Either<Failure, List<Comment>>> call(String videoPostId) {
    return repository.getComments(videoPostId);
  }
}
