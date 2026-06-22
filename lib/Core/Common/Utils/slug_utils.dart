import 'package:blog_app/Features/VideoBlog/Domain/Entities/video_post.dart';

String slugify(String text) {
  return text
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9\s]'), '')
      .trim()
      .replaceAll(RegExp(r'\s+'), '-')
      .replaceAll(RegExp(r'-+'), '-');
}

String videoSlug(VideoPost post) {
  final slug = slugify(post.title);
  final idPrefix = post.id.substring(0, 8);
  return '$slug-$idPrefix';
}

String idPrefixFromSlug(String slug) {
  return slug.split('-').last;
}
