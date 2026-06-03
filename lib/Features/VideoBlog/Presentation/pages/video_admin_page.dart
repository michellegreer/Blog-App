import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:blog_app/Core/Common/Cubits/AppUser/app_user_cubit.dart';
import 'package:blog_app/Core/Common/Widgets/kittehs_scaffold.dart';
import 'package:blog_app/Features/VideoBlog/Domain/Entities/video_post.dart';
import 'package:blog_app/Features/VideoBlog/Presentation/bloc/video_blog_bloc.dart';
import 'package:blog_app/Features/VideoBlog/Presentation/pages/video_post_form_page.dart';

class VideoAdminPage extends StatefulWidget {
  const VideoAdminPage({super.key});

  @override
  State<VideoAdminPage> createState() => _VideoAdminPageState();
}

class _VideoAdminPageState extends State<VideoAdminPage> {
  @override
  void initState() {
    super.initState();
    context.read<VideoBlogBloc>().add(VideoBlogFetchAll());
  }

  void _confirmDelete(BuildContext context, VideoPost post) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete post?'),
        content: Text('Delete "${post.title}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<VideoBlogBloc>().add(VideoBlogDelete(post.id));
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _navigateToEdit(BuildContext context, VideoPost post) {
    final bloc = context.read<VideoBlogBloc>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: bloc,
          child: VideoPostFormPage(post: post),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userState = context.watch<AppUserCubit>().state;
    final currentUser =
        userState is AppUserLoggedIn ? userState.user : null;
    final isAdmin = currentUser?.isAdmin ?? false;

    return KittehsScaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final bloc = context.read<VideoBlogBloc>();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: bloc,
                child: const VideoPostFormPage(),
              ),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('New Post'),
      ),
      body: BlocConsumer<VideoBlogBloc, VideoBlogState>(
        listener: (context, state) {
          if (state is VideoBlogFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(state.error), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          if (state is VideoBlogLoading || state is VideoBlogInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is VideoBlogSuccess) {
            if (state.allPosts.isEmpty) {
              return const Center(
                  child: Text('No posts yet. Tap + to add one!'));
            }
            return ListView.builder(
              padding: const EdgeInsets.only(bottom: 80),
              itemCount: state.allPosts.length,
              itemBuilder: (context, index) {
                final post = state.allPosts[index];
                final canEdit = isAdmin ||
                    (currentUser != null &&
                        post.postedById == currentUser.id);

                return ListTile(
                  leading: const Text('🐱', style: TextStyle(fontSize: 24)),
                  title: Text(post.title,
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: Text(
                    post.postedByName != null
                        ? 'by ${post.postedByName}'
                        : post.commentary ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (canEdit)
                        IconButton(
                          icon: const Icon(Icons.edit_outlined),
                          onPressed: () => _navigateToEdit(context, post),
                        ),
                      // Only admin can delete
                      if (isAdmin)
                        IconButton(
                          icon: const Icon(Icons.delete_outline,
                              color: Colors.red),
                          onPressed: () => _confirmDelete(context, post),
                        ),
                    ],
                  ),
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
