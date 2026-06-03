import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:blog_app/Features/Comments/Domain/Entities/comment.dart';
import 'package:blog_app/Features/Comments/Domain/UseCases/get_comments.dart';
import 'package:blog_app/Features/Comments/Domain/UseCases/add_comment.dart';

part 'comment_event.dart';
part 'comment_state.dart';

class CommentBloc extends Bloc<CommentEvent, CommentState> {
  final GetComments _getComments;
  final AddComment _addComment;

  CommentBloc({
    required GetComments getComments,
    required AddComment addComment,
  })  : _getComments = getComments,
        _addComment = addComment,
        super(CommentInitial()) {
    on<FetchComments>(_onFetch);
    on<SubmitComment>(_onSubmit);
  }

  Future<void> _onFetch(FetchComments event, Emitter<CommentState> emit) async {
    emit(CommentLoading());
    final result = await _getComments(event.videoPostId);
    result.fold(
      (failure) => emit(CommentError(failure.message)),
      (comments) => emit(CommentLoaded(comments)),
    );
  }

  Future<void> _onSubmit(SubmitComment event, Emitter<CommentState> emit) async {
    final current = state;
    if (current is! CommentLoaded) return;
    final result = await _addComment(AddCommentParams(
      videoPostId: event.videoPostId,
      userId: event.userId,
      userName: event.userName,
      userAvatarUrl: event.userAvatarUrl,
      content: event.content,
    ));
    result.fold(
      (failure) => emit(CommentError(failure.message)),
      (comment) => emit(CommentLoaded([...current.comments, comment])),
    );
  }
}
