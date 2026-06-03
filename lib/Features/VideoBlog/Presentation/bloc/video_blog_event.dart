part of 'video_blog_bloc.dart';

@immutable
sealed class VideoBlogEvent {}

final class VideoBlogFetchAll extends VideoBlogEvent {}

final class VideoBlogChangePage extends VideoBlogEvent {
  final int page;
  VideoBlogChangePage(this.page);
}

final class VideoBlogCreate extends VideoBlogEvent {
  final String title;
  final String youtubeUrl;
  final String? commentary;
  final String? postedByName;
  final String? postedById;
  final String? posterAvatarUrl;

  VideoBlogCreate({
    required this.title,
    required this.youtubeUrl,
    this.commentary,
    this.postedByName,
    this.postedById,
    this.posterAvatarUrl,
  });
}

final class VideoBlogUpdate extends VideoBlogEvent {
  final String id;
  final String title;
  final String youtubeUrl;
  final String? commentary;
  VideoBlogUpdate({required this.id, required this.title, required this.youtubeUrl, this.commentary});
}

final class VideoBlogDelete extends VideoBlogEvent {
  final String id;
  VideoBlogDelete(this.id);
}
