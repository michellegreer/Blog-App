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
  final String? visibilityCircleType;
  final String? visibilityCircleId;
  final bool isPublic;

  VideoBlogCreate({
    required this.title,
    required this.youtubeUrl,
    this.commentary,
    this.postedByName,
    this.postedById,
    this.posterAvatarUrl,
    this.visibilityCircleType,
    this.visibilityCircleId,
    this.isPublic = false,
  });
}

final class VideoBlogUpdate extends VideoBlogEvent {
  final String id;
  final String title;
  final String youtubeUrl;
  final String? commentary;
  final String? visibilityCircleType;
  final String? visibilityCircleId;
  final bool isPublic;

  VideoBlogUpdate({
    required this.id,
    required this.title,
    required this.youtubeUrl,
    this.commentary,
    this.visibilityCircleType,
    this.visibilityCircleId,
    this.isPublic = false,
  });
}

final class VideoBlogDelete extends VideoBlogEvent {
  final String id;
  VideoBlogDelete(this.id);
}
