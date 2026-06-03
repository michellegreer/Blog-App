import 'package:fpdart/fpdart.dart';
import 'package:blog_app/Core/Errors/failure.dart';
import 'package:blog_app/Core/UseCAses/usecase.dart';
import 'package:blog_app/Features/Comments/Domain/Entities/comment.dart';
import 'package:blog_app/Features/Comments/Domain/Repositories/comment_repository.dart';

class AddCommentParams {
  final String videoPostId;
  final String userId;
  final String userName;
  final String? userAvatarUrl;
  final String content;

  const AddCommentParams({
    required this.videoPostId,
    required this.userId,
    required this.userName,
    this.userAvatarUrl,
    required this.content,
  });
}

class AddComment implements UseCase<Comment, AddCommentParams> {
  final CommentRepository repository;
  const AddComment(this.repository);

  @override
  Future<Either<Failure, Comment>> call(AddCommentParams params) {
    return repository.addComment(
      videoPostId: params.videoPostId,
      userId: params.userId,
      userName: params.userName,
      userAvatarUrl: params.userAvatarUrl,
      content: params.content,
    );
  }
}
