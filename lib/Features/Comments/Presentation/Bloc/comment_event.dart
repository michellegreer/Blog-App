part of 'comment_bloc.dart';

@immutable
sealed class CommentEvent {}

final class FetchComments extends CommentEvent {
  final String videoPostId;
  FetchComments(this.videoPostId);
}

final class SubmitComment extends CommentEvent {
  final String videoPostId;
  final String userId;
  final String userName;
  final String? userAvatarUrl;
  final String content;

  SubmitComment({
    required this.videoPostId,
    required this.userId,
    required this.userName,
    this.userAvatarUrl,
    required this.content,
  });
}
