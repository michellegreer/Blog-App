import 'package:fpdart/fpdart.dart';
import 'package:blog_app/Core/Errors/failure.dart';
import 'package:blog_app/Features/Comments/Domain/Entities/comment.dart';

abstract interface class CommentRepository {
  Future<Either<Failure, List<Comment>>> getComments(String videoPostId);
  Future<Either<Failure, Comment>> addComment({
    required String videoPostId,
    required String userId,
    required String userName,
    String? userAvatarUrl,
    required String content,
  });
}
