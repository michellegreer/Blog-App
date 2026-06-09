import 'package:flutter/material.dart';
import 'package:blog_app/Core/Common/Widgets/user_bio_sheet.dart';
import 'package:blog_app/Core/Themes/app_pallate.dart';
import 'package:blog_app/Features/VideoBlog/Domain/Entities/video_post.dart';
import 'package:blog_app/Features/VideoBlog/Presentation/pages/video_post_detail_page.dart';

class VideoPostCard extends StatelessWidget {
  final VideoPost post;
  const VideoPostCard({super.key, required this.post});

  String _getYoutubeThumbnail(String url) {
    final uri = Uri.tryParse(url);
    String? videoId;
    if (uri != null) {
      if (uri.host.contains('youtu.be')) {
        videoId = uri.pathSegments.isNotEmpty ? uri.pathSegments.first : null;
      } else {
        videoId = uri.queryParameters['v'];
      }
    }
    if (videoId != null) {
      return 'https://img.youtube.com/vi/$videoId/hqdefault.jpg';
    }
    return 'https://img.youtube.com/vi/invalid/hqdefault.jpg';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => VideoPostDetailPage(post: post)),
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Image.network(
                  _getYoutubeThumbnail(post.youtubeUrl),
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 200,
                    color: Colors.grey[800],
                    child: const Icon(Icons.videocam, size: 48, color: Colors.grey),
                  ),
                ),
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.play_arrow, color: Colors.white, size: 32),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.title,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (post.commentary != null && post.commentary!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      post.commentary!,
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 10),
                  // Posted by row
                  if (post.postedByName != null) _PostedByRow(post: post),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PostedByRow extends StatelessWidget {
  final VideoPost post;
  const _PostedByRow({required this.post});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: post.postedById == null
          ? null
          : () => showUserBio(
                context,
                userId: post.postedById!,
                userName: post.postedByName ?? '',
                avatarUrl: post.posterAvatarUrl,
              ),
      child: Row(
        children: [
          _Avatar(
            avatarUrl: post.posterAvatarUrl,
            name: post.postedByName ?? '',
            radius: 14,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Posted by ${post.postedByName}',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppPallate.coralColor),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String? avatarUrl;
  final String name;
  final double radius;

  const _Avatar({required this.avatarUrl, required this.name, this.radius = 16});

  @override
  Widget build(BuildContext context) {
    if (avatarUrl != null && avatarUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: NetworkImage(avatarUrl!),
      );
    }
    return CircleAvatar(
      radius: radius,
      backgroundColor: AppPallate.gradient1,
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: TextStyle(
          color: Colors.white,
          fontSize: radius * 0.85,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
