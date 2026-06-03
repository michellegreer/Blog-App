import 'package:fpdart/fpdart.dart';
import 'package:blog_app/Core/Errors/exceptions.dart';
import 'package:blog_app/Core/Errors/failure.dart';
import 'package:blog_app/Features/Comments/Data/DataSource/comment_remote_datasource.dart';
import 'package:blog_app/Features/Comments/Domain/Entities/comment.dart';
import 'package:blog_app/Features/Comments/Domain/Repositories/comment_repository.dart';

class CommentRepositoryImpl implements CommentRepository {
  final CommentRemoteDataSource remoteDataSource;
  CommentRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<Comment>>> getComments(String videoPostId) async {
    try {
      final comments = await remoteDataSource.getComments(videoPostId);
      return right(comments);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, Comment>> addComment({
    required String videoPostId,
    required String userId,
    required String userName,
    String? userAvatarUrl,
    required String content,
  }) async {
    try {
      final comment = await remoteDataSource.addComment(
        videoPostId: videoPostId,
        userId: userId,
        userName: userName,
        userAvatarUrl: userAvatarUrl,
        content: content,
      );
      return right(comment);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }
}
