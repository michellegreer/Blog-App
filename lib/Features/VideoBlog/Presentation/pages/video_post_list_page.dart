import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:blog_app/Core/Common/Cubits/AppUser/app_user_cubit.dart';
import 'package:blog_app/Core/Common/Widgets/kittehs_scaffold.dart';
import 'package:blog_app/Core/Themes/app_pallate.dart';
import 'package:blog_app/Features/VideoBlog/Presentation/bloc/video_blog_bloc.dart';
import 'package:blog_app/Features/VideoBlog/Presentation/pages/video_admin_page.dart';
import 'package:blog_app/Features/VideoBlog/Presentation/widgets/video_post_card.dart';

class VideoPostListPage extends StatefulWidget {
  const VideoPostListPage({super.key});

  @override
  State<VideoPostListPage> createState() => _VideoPostListPageState();
}

class _VideoPostListPageState extends State<VideoPostListPage> {
  @override
  void initState() {
    super.initState();
    context.read<VideoBlogBloc>().add(VideoBlogFetchAll());
  }

  void _navigateToAdmin(BuildContext context) {
    final bloc = context.read<VideoBlogBloc>();
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => BlocProvider.value(value: bloc, child: const VideoAdminPage()),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return KittehsScaffold(
      extraActions: [
        BlocBuilder<AppUserCubit, AppUserState>(
          builder: (context, userState) {
            if (userState is AppUserLoggedIn && userState.user.isAdmin) {
              return IconButton(
                icon: const Icon(Icons.admin_panel_settings_outlined),
                tooltip: 'Admin',
                onPressed: () => _navigateToAdmin(context),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
      body: BlocBuilder<VideoBlogBloc, VideoBlogState>(
        builder: (context, state) {
          if (state is VideoBlogLoading || state is VideoBlogInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is VideoBlogFailure) {
            return Center(child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 12),
                Text(state.error),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => context.read<VideoBlogBloc>().add(VideoBlogFetchAll()),
                  child: const Text('Try again'),
                ),
              ],
            ));
          }
          if (state is VideoBlogSuccess) {
            if (state.allPosts.isEmpty) {
              return const Center(child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('😿', style: TextStyle(fontSize: 64)),
                  SizedBox(height: 16),
                  Text('No kitty videos yet!',
                      style: TextStyle(fontSize: 18, color: Colors.grey)),
                ],
              ));
            }
            return Column(children: [
              Expanded(child: _VideoGrid(posts: state.currentPosts)),
              if (state.totalPages > 1) _PaginationBar(state: state),
            ]);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _VideoGrid extends StatelessWidget {
  final List posts;
  const _VideoGrid({required this.posts});

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.sizeOf(context).width;
    final hPad = (screenW * 0.15).clamp(16.0, 220.0);

    return RefreshIndicator(
      onRefresh: () async =>
          context.read<VideoBlogBloc>().add(VideoBlogFetchAll()),
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(hPad, 24, hPad, 24),
        itemCount: posts.length,
        separatorBuilder: (_, __) => const SizedBox(height: 96),
        itemBuilder: (context, index) => VideoPostCard(post: posts[index]),
      ),
    );
  }
}

class _PaginationBar extends StatelessWidget {
  final VideoBlogSuccess state;
  const _PaginationBar({required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        color: AppPallate.backgroundColor,
        border: Border(top: BorderSide(color: AppPallate.borderColor)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: state.currentPage > 1
                ? () => context.read<VideoBlogBloc>().add(
                    VideoBlogChangePage(state.currentPage - 1))
                : null,
          ),
          ...List.generate(state.totalPages, (i) {
            final page = i + 1;
            final isCurrent = page == state.currentPage;
            return TextButton(
              onPressed: isCurrent
                  ? null
                  : () => context.read<VideoBlogBloc>().add(
                      VideoBlogChangePage(page)),
              style: TextButton.styleFrom(
                foregroundColor:
                    isCurrent ? Colors.white : AppPallate.coralColor,
                minimumSize: const Size(36, 36),
                padding: EdgeInsets.zero,
              ),
              child: Text('$page', style: TextStyle(
                fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                decoration: isCurrent ? TextDecoration.underline : null,
              )),
            );
          }),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: state.currentPage < state.totalPages
                ? () => context.read<VideoBlogBloc>().add(
                    VideoBlogChangePage(state.currentPage + 1))
                : null,
          ),
        ],
      ),
    );
  }
}
