part of 'video_blog_bloc.dart';

@immutable
sealed class VideoBlogState {}

final class VideoBlogInitial extends VideoBlogState {}
final class VideoBlogLoading extends VideoBlogState {}

final class VideoBlogSuccess extends VideoBlogState {
  final List<VideoPost> allPosts;
  final int currentPage;
  static const int pageSize = 8;

  VideoBlogSuccess(this.allPosts, {this.currentPage = 1});

  List<VideoPost> get currentPosts {
    final start = (currentPage - 1) * pageSize;
    final end = (start + pageSize).clamp(0, allPosts.length);
    return allPosts.isEmpty ? [] : allPosts.sublist(start, end);
  }

  int get totalPages => (allPosts.length / pageSize).ceil().clamp(1, 9999);

  VideoBlogSuccess copyWithPage(int page) =>
      VideoBlogSuccess(allPosts, currentPage: page);
}

final class VideoBlogFailure extends VideoBlogState {
  final String error;
  VideoBlogFailure(this.error);
}
