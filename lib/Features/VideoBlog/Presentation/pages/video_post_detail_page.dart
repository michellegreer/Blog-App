import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart'
    show YoutubePlayer, YoutubePlayerController, YoutubePlayerParams;
import 'package:blog_app/Core/Common/Cubits/AppUser/app_user_cubit.dart';
import 'package:blog_app/Core/Common/Utils/slug_utils.dart';
import 'package:blog_app/Core/Themes/app_pallate.dart';
import 'package:blog_app/Features/Invite/Presentation/Widgets/invite_dialog.dart';
import 'package:blog_app/Features/Comments/Domain/UseCases/get_comments.dart';
import 'package:blog_app/Features/Comments/Domain/UseCases/add_comment.dart';
import 'package:blog_app/Features/Comments/Presentation/Bloc/comment_bloc.dart';
import 'package:blog_app/Features/Comments/Presentation/Widgets/comment_section.dart';
import 'package:blog_app/Core/Common/Widgets/kittehs_scaffold.dart';
import 'package:blog_app/Core/Common/Widgets/user_bio_sheet.dart';
import 'package:blog_app/Features/VideoBlog/Domain/Entities/video_post.dart';
import 'package:blog_app/Features/VideoBlog/Domain/UseCases/get_video_by_id_prefix.dart';
import 'package:blog_app/init_dependencies.dart';

class VideoPostDetailPage extends StatefulWidget {
  final String slug;
  final VideoPost? post;

  const VideoPostDetailPage({super.key, required this.slug, this.post});

  @override
  State<VideoPostDetailPage> createState() => _VideoPostDetailPageState();
}

class _VideoPostDetailPageState extends State<VideoPostDetailPage> {
  YoutubePlayerController? _controller;
  CommentBloc? _commentBloc;
  VideoPost? _post;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.post != null) {
      _initPost(widget.post!);
    } else {
      _loadFromSlug();
    }
  }

  void _initPost(VideoPost post) {
    final videoId =
        YoutubePlayerController.convertUrlToId(post.youtubeUrl) ?? '';
    _controller = YoutubePlayerController.fromVideoId(
      videoId: videoId,
      autoPlay: false,
      params: const YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: true,
        mute: false,
      ),
    );
    _commentBloc = CommentBloc(
      getComments: serviceLocater<GetComments>(),
      addComment: serviceLocater<AddComment>(),
    );
    _commentBloc!.add(FetchComments(post.id));
    if (mounted) setState(() { _post = post; _loading = false; });
  }

  Future<void> _loadFromSlug() async {
    final idPrefix = idPrefixFromSlug(widget.slug);
    final result = await serviceLocater<GetVideoByIdPrefix>().call(idPrefix);
    result.fold(
      (failure) {
        if (mounted) setState(() { _error = failure.message; _loading = false; });
      },
      (post) => _initPost(post),
    );
  }

  @override
  void dispose() {
    _controller?.close();
    _commentBloc?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return KittehsScaffold(
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null || _post == null) {
      return KittehsScaffold(
        body: Center(
          child: Text(_error ?? 'Video not found',
              style: const TextStyle(color: Colors.white)),
        ),
      );
    }

    return BlocProvider.value(
      value: _commentBloc!,
      child: KittehsScaffold(
        extraActions: [
          BlocBuilder<AppUserCubit, AppUserState>(
            builder: (context, userState) {
              if (userState is! AppUserLoggedIn) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.person_add_outlined),
                tooltip: 'Invite someone',
                onPressed: () => showInviteDialog(context),
              );
            },
          ),
        ],
        body: LayoutBuilder(builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= 900;
          final hPad = (constraints.maxWidth * 0.06).clamp(16.0, 100.0);
          if (isDesktop) {
            return _DesktopLayout(
                post: _post!, controller: _controller!, hPad: hPad);
          }
          return _MobileLayout(
              post: _post!, controller: _controller!, hPad: hPad);
        }),
      ),
    );
  }
}

// ── Desktop: video left, content+comments right ──────────────────────────────

class _DesktopLayout extends StatelessWidget {
  final VideoPost post;
  final YoutubePlayerController controller;
  final double hPad;
  const _DesktopLayout(
      {required this.post, required this.controller, required this.hPad});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: YoutubePlayer(controller: controller),
                ),
                const SizedBox(height: 16),
                Text(post.title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold)),
                if (post.postedByName != null) ...[
                  const SizedBox(height: 10),
                  _PostedByRow(post: post),
                ],
                if (post.commentary != null &&
                    post.commentary!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(post.commentary!,
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 15, height: 1.6)),
                ],
              ],
            ),
          ),
          const SizedBox(width: 28),
          SizedBox(
            width: 380,
            child: CommentSection(videoPostId: post.id),
          ),
        ],
      ),
    );
  }
}

// ── Mobile: single column ─────────────────────────────────────────────────────

class _MobileLayout extends StatelessWidget {
  final VideoPost post;
  final YoutubePlayerController controller;
  final double hPad;
  const _MobileLayout(
      {required this.post, required this.controller, required this.hPad});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: YoutubePlayer(controller: controller),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(hPad, 16, hPad, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(post.title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
                if (post.postedByName != null) ...[
                  const SizedBox(height: 10),
                  _PostedByRow(post: post),
                ],
                if (post.commentary != null &&
                    post.commentary!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(post.commentary!,
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 15, height: 1.6)),
                ],
                const SizedBox(height: 8),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: hPad),
            child: CommentSection(videoPostId: post.id),
          ),
        ],
      ),
    );
  }
}

// ── Shared widgets ────────────────────────────────────────────────────────────

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
      child: Row(children: [
        _buildAvatar(),
        const SizedBox(width: 10),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Posted by',
              style: TextStyle(color: Colors.grey, fontSize: 12)),
          Text(post.postedByName!,
              style: const TextStyle(
                  color: AppPallate.coralColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 14)),
        ]),
      ]),
    );
  }

  Widget _buildAvatar() {
    final url = post.posterAvatarUrl;
    final name = post.postedByName ?? '';
    if (url != null && url.isNotEmpty) {
      return CircleAvatar(radius: 18, backgroundImage: NetworkImage(url));
    }
    return CircleAvatar(
      radius: 18,
      backgroundColor: AppPallate.gradient1,
      child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold)),
    );
  }
}
