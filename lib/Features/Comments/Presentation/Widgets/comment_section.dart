import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:blog_app/Core/Common/Cubits/AppUser/app_user_cubit.dart';
import 'package:blog_app/Core/Themes/app_pallate.dart';
import 'package:blog_app/Core/Common/Widgets/user_bio_sheet.dart';
import 'package:blog_app/Features/Auth/Presentation/Pages/signin_page.dart';
import 'package:blog_app/Features/Auth/Presentation/Pages/signup_page.dart';
import 'package:blog_app/Features/Comments/Domain/Entities/comment.dart';
import 'package:blog_app/Features/Comments/Presentation/Bloc/comment_bloc.dart';

class CommentSection extends StatefulWidget {
  final String videoPostId;
  const CommentSection({super.key, required this.videoPostId});

  @override
  State<CommentSection> createState() => _CommentSectionState();
}

class _CommentSectionState extends State<CommentSection> {
  final _controller = TextEditingController();
  bool _inputFocused = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final content = _controller.text.trim();
    if (content.isEmpty) return;
    final userState = context.read<AppUserCubit>().state;
    if (userState is! AppUserLoggedIn) return;
    context.read<CommentBloc>().add(SubmitComment(
          videoPostId: widget.videoPostId,
          userId: userState.user.id,
          userName: userState.user.name,
          userAvatarUrl: userState.user.avatarUrl,
          content: content,
        ));
    _controller.clear();
    setState(() => _inputFocused = false);
  }

  @override
  Widget build(BuildContext context) {
    final userState = context.watch<AppUserCubit>().state;
    final isLoggedIn = userState is AppUserLoggedIn;

    return BlocBuilder<CommentBloc, CommentState>(
      builder: (context, state) {
        final commentCount =
            state is CommentLoaded ? state.comments.length : 0;

        return SingleChildScrollView(
         child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(thickness: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                '$commentCount Comment${commentCount == 1 ? '' : 's'}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // ── Comment input area ──────────────────────────────────────
            if (isLoggedIn) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Avatar(
                      avatarUrl: (userState).user.avatarUrl,
                      name: (userState).user.name,
                      radius: 18,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          TextField(
                            controller: _controller,
                            style: const TextStyle(color: Colors.white, fontSize: 14),
                            decoration: const InputDecoration(
                              hintText: 'Post a comment…',
                              hintStyle: TextStyle(color: Colors.grey),
                              border: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey),
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                              contentPadding: EdgeInsets.symmetric(vertical: 8),
                              filled: false,
                            ),
                            onTap: () => setState(() => _inputFocused = true),
                            onChanged: (_) => setState(() {}),
                          ),
                          if (_inputFocused) ...[
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () {
                                    _controller.clear();
                                    setState(() => _inputFocused = false);
                                  },
                                  child: const Text('Cancel',
                                      style: TextStyle(color: Colors.grey)),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: _controller.text.trim().isEmpty
                                      ? null
                                      : _submit,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppPallate.coralColor,
                                    foregroundColor: Colors.white,
                                    disabledBackgroundColor:
                                        AppPallate.borderColor,
                                    shape: const StadiumBorder(),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                  ),
                                  child: const Text('Comment',
                                      style: TextStyle(fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              // Not logged in CTA
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: AppPallate.borderColor),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Want to join the conversation?',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Create an account to post a comment.',
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        OutlinedButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const SigninPage()),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white),
                            shape: const StadiumBorder(),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                          ),
                          child: const Text('Sign in'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const SignupPage()),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppPallate.coralColor,
                            foregroundColor: Colors.white,
                            shape: const StadiumBorder(),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                          ),
                          child: const Text('Create account'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 8),

            // ── Comments list ───────────────────────────────────────────
            if (state is CommentLoading)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (state is CommentLoaded && state.comments.isEmpty)
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 32),
                child: Text(
                  'No comments yet. Be the first!',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              )
            else if (state is CommentLoaded)
              ...state.comments.map((c) => _CommentTile(comment: c))
            else if (state is CommentError)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(state.message,
                    style: const TextStyle(color: Colors.red)),
              ),

            const SizedBox(height: 32),
          ],
        ),
       );
      },
    );
  }
}

class _CommentTile extends StatelessWidget {
  final Comment comment;
  const _CommentTile({required this.comment});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => showUserBio(
              context,
              userId: comment.userId,
              userName: comment.userName,
              avatarUrl: comment.userAvatarUrl,
            ),
            child: _Avatar(
                avatarUrl: comment.userAvatarUrl,
                name: comment.userName,
                radius: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => showUserBio(
                        context,
                        userId: comment.userId,
                        userName: comment.userName,
                        avatarUrl: comment.userAvatarUrl,
                      ),
                      child: Text(
                        comment.userName,
                        style: const TextStyle(
                          color: AppPallate.coralColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _timeAgo(comment.createdAt),
                      style: const TextStyle(
                          color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  comment.content,
                  style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays > 365) return '${(diff.inDays / 365).floor()}y ago';
    if (diff.inDays > 30) return '${(diff.inDays / 30).floor()}mo ago';
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'just now';
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
          radius: radius, backgroundImage: NetworkImage(avatarUrl!));
    }
    return CircleAvatar(
      radius: radius,
      backgroundColor: AppPallate.gradient1,
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: TextStyle(
            color: Colors.white,
            fontSize: radius * 0.85,
            fontWeight: FontWeight.bold),
      ),
    );
  }
}
