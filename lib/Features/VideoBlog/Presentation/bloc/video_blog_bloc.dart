import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:blog_app/Core/UseCAses/usecase.dart';
import 'package:blog_app/Features/VideoBlog/Domain/Entities/video_post.dart';
import 'package:blog_app/Features/VideoBlog/Domain/UseCases/get_all_video_posts.dart';
import 'package:blog_app/Features/VideoBlog/Domain/UseCases/create_video_post.dart';
import 'package:blog_app/Features/VideoBlog/Domain/UseCases/update_video_post.dart';
import 'package:blog_app/Features/VideoBlog/Domain/UseCases/delete_video_post.dart';

part 'video_blog_event.dart';
part 'video_blog_state.dart';

class VideoBlogBloc extends Bloc<VideoBlogEvent, VideoBlogState> {
  final GetAllVideoPosts _getAllVideoPosts;
  final CreateVideoPost _createVideoPost;
  final UpdateVideoPost _updateVideoPost;
  final DeleteVideoPost _deleteVideoPost;

  VideoBlogBloc({
    required GetAllVideoPosts getAllVideoPosts,
    required CreateVideoPost createVideoPost,
    required UpdateVideoPost updateVideoPost,
    required DeleteVideoPost deleteVideoPost,
  })  : _getAllVideoPosts = getAllVideoPosts,
        _createVideoPost = createVideoPost,
        _updateVideoPost = updateVideoPost,
        _deleteVideoPost = deleteVideoPost,
        super(VideoBlogInitial()) {
    on<VideoBlogFetchAll>(_onFetchAll);
    on<VideoBlogChangePage>(_onChangePage);
    on<VideoBlogCreate>(_onCreate);
    on<VideoBlogUpdate>(_onUpdate);
    on<VideoBlogDelete>(_onDelete);
  }

  Future<void> _onFetchAll(VideoBlogFetchAll event, Emitter<VideoBlogState> emit) async {
    emit(VideoBlogLoading());
    final result = await _getAllVideoPosts(NoParams());
    result.fold(
      (failure) => emit(VideoBlogFailure(failure.message)),
      (posts) => emit(VideoBlogSuccess(posts)),
    );
  }

  void _onChangePage(VideoBlogChangePage event, Emitter<VideoBlogState> emit) {
    final current = state;
    if (current is VideoBlogSuccess) {
      emit(current.copyWithPage(event.page));
    }
  }

  Future<void> _onCreate(VideoBlogCreate event, Emitter<VideoBlogState> emit) async {
    emit(VideoBlogLoading());
    final result = await _createVideoPost(CreateVideoPostParams(
      title: event.title,
      youtubeUrl: event.youtubeUrl,
      commentary: event.commentary,
      postedByName: event.postedByName,
      postedById: event.postedById,
      posterAvatarUrl: event.posterAvatarUrl,
    ));
    result.fold(
      (failure) => emit(VideoBlogFailure(failure.message)),
      (_) => add(VideoBlogFetchAll()),
    );
  }

  Future<void> _onUpdate(VideoBlogUpdate event, Emitter<VideoBlogState> emit) async {
    emit(VideoBlogLoading());
    final result = await _updateVideoPost(UpdateVideoPostParams(
      id: event.id,
      title: event.title,
      youtubeUrl: event.youtubeUrl,
      commentary: event.commentary,
    ));
    result.fold(
      (failure) => emit(VideoBlogFailure(failure.message)),
      (_) => add(VideoBlogFetchAll()),
    );
  }

  Future<void> _onDelete(VideoBlogDelete event, Emitter<VideoBlogState> emit) async {
    emit(VideoBlogLoading());
    final result = await _deleteVideoPost(event.id);
    result.fold(
      (failure) => emit(VideoBlogFailure(failure.message)),
      (_) => add(VideoBlogFetchAll()),
    );
  }
}
