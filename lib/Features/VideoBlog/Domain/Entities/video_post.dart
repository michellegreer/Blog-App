enum CircleType {
  family,
  extendedFamily,
  friends;

  String get dbValue => switch (this) {
        CircleType.family => 'family',
        CircleType.extendedFamily => 'extended_family',
        CircleType.friends => 'friends',
      };

  static CircleType? fromDb(String? value) => switch (value) {
        'family' => CircleType.family,
        'extended_family' => CircleType.extendedFamily,
        'friends' => CircleType.friends,
        _ => null,
      };

  String get label => switch (this) {
        CircleType.family => 'Family',
        CircleType.extendedFamily => 'Extended Family',
        CircleType.friends => 'Friends',
      };
}

class VideoPost {
  final String id;
  final String title;
  final String youtubeUrl;
  final String? commentary;
  final DateTime createdAt;
  final String? postedByName;
  final String? postedById;
  final String? posterAvatarUrl;
  final CircleType? visibilityCircleType;
  final String? visibilityCircleId;
  final bool isPublic;

  const VideoPost({
    required this.id,
    required this.title,
    required this.youtubeUrl,
    this.commentary,
    required this.createdAt,
    this.postedByName,
    this.postedById,
    this.posterAvatarUrl,
    this.visibilityCircleType,
    this.visibilityCircleId,
    this.isPublic = false,
  });
}
