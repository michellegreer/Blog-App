import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:blog_app/Core/Common/Cubits/AppUser/app_user_cubit.dart';
import 'package:blog_app/Core/Common/Cubits/LogOut/logout_user_cubit.dart';
import 'package:blog_app/Core/Common/Widgets/kittehs_scaffold.dart';
import 'package:blog_app/Core/Themes/app_pallate.dart';
import 'package:blog_app/Features/VideoBlog/Data/Models/video_post_model.dart';
import 'package:blog_app/Features/VideoBlog/Presentation/pages/profile_page.dart';
import 'package:blog_app/Features/VideoBlog/Presentation/widgets/video_post_card.dart';
import 'package:blog_app/init_dependencies.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserProfilePage extends StatefulWidget {
  final String username;
  const UserProfilePage({super.key, required this.username});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  Map<String, dynamic>? _profile;
  List<VideoPostModel> _posts = [];
  bool _loading = true;
  bool _notFound = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final supabase = serviceLocater<SupabaseClient>();
    try {
      final profileRows = await supabase
          .from('profiles')
          .select()
          .eq('username', widget.username)
          .limit(1);

      if (profileRows.isEmpty) {
        if (mounted) setState(() { _notFound = true; _loading = false; });
        return;
      }

      final profile = profileRows[0];
      final profileId = profile['id'] as String;

      final postRows = await supabase
          .from('video_posts')
          .select()
          .eq('posted_by_id', profileId)
          .order('created_at', ascending: false);

      if (!mounted) return;
      setState(() {
        _profile = profile;
        _posts = postRows
            .map((r) => VideoPostModel.fromJson(r))
            .toList();
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() { _notFound = true; _loading = false; });
    }
  }

  bool _isOwnProfile(String? currentUserId) =>
      currentUserId != null && _profile?['id'] == currentUserId;

  @override
  Widget build(BuildContext context) {
    final userState = context.watch<AppUserCubit>().state;

    // Auth guard — redirect logged-out visitors to home
    if (userState is AppUserInitial) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go('/');
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final currentUserId =
        userState is AppUserLoggedIn ? userState.user.id : null;

    if (_loading) {
      return const KittehsScaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_notFound || _profile == null) {
      return KittehsScaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🙀', style: TextStyle(fontSize: 56)),
              const SizedBox(height: 16),
              Text(
                '@${widget.username} not found.',
                style: const TextStyle(color: Colors.white70, fontSize: 18),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => context.go('/'),
                child: const Text('← Go home'),
              ),
            ],
          ),
        ),
      );
    }

    final profile = _profile!;
    final isOwn = _isOwnProfile(currentUserId);

    return BlocListener<LogoutUserCubit, LogoutUserState>(
      listener: (context, state) {
        if (state is LogOutUserSuccess) {
          context.read<AppUserCubit>().updateUser(null);
          context.go('/');
        }
      },
      child: KittehsScaffold(
        body: LayoutBuilder(
          builder: (context, constraints) {
            final contentW = (constraints.maxWidth * 0.70).clamp(300.0, 640.0);
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: SizedBox(
                  width: contentW,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _ProfileHeader(
                        profile: profile,
                        isOwn: isOwn,
                        onEditProfile: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const ProfilePage()),
                        ),
                        onSignOut: () =>
                            context.read<LogoutUserCubit>().logOutUSer(),
                      ),
                      if (_posts.isNotEmpty) ...[
                        const SizedBox(height: 32),
                        const Divider(),
                        const SizedBox(height: 16),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            isOwn ? 'Your posts' : 'Posts',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(fontSize: 16),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ..._posts.map((post) => Padding(
                              padding:
                                  const EdgeInsets.only(bottom: 24),
                              child: VideoPostCard(post: post),
                            )),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final Map<String, dynamic> profile;
  final bool isOwn;
  final VoidCallback onEditProfile;
  final VoidCallback onSignOut;

  const _ProfileHeader({
    required this.profile,
    required this.isOwn,
    required this.onEditProfile,
    required this.onSignOut,
  });

  @override
  Widget build(BuildContext context) {
    final name = profile['name'] as String? ?? '';
    final username = profile['username'] as String? ?? '';
    final bio = profile['bio'] as String?;
    final avatarUrl = profile['avatar_url'] as String?;
    final isAdmin = profile['is_admin'] as bool? ?? false;

    return Column(
      children: [
        // Avatar
        (avatarUrl != null && avatarUrl.isNotEmpty)
            ? CircleAvatar(
                radius: 56,
                backgroundImage: NetworkImage(avatarUrl),
              )
            : CircleAvatar(
                radius: 56,
                backgroundColor: AppPallate.gradient1,
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : '?',
                  style: const TextStyle(fontSize: 40, color: Colors.white),
                ),
              ),
        const SizedBox(height: 20),

        // Name
        Text(name, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 4),

        // @username
        Text(
          '@$username',
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: Colors.white54),
        ),
        const SizedBox(height: 8),

        // Role badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: isAdmin
                ? AppPallate.gradient1.withValues(alpha: 0.2)
                : AppPallate.borderColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            isAdmin ? 'Admin' : 'Member',
            style: TextStyle(
              color: isAdmin ? AppPallate.gradient1 : AppPallate.coralColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        // Bio
        if (bio != null && bio.isNotEmpty) ...[
          const SizedBox(height: 20),
          Text(
            bio,
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Colors.white70, height: 1.5),
          ),
        ],

        // Own-profile controls
        if (isOwn) ...[
          const SizedBox(height: 28),
          Wrap(
            spacing: 12,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: [
              OutlinedButton.icon(
                onPressed: onEditProfile,
                icon: const Icon(Icons.edit_outlined, size: 16),
                label: const Text('Edit Profile'),
              ),
              OutlinedButton.icon(
                onPressed: onSignOut,
                icon: const Icon(Icons.logout, color: Colors.redAccent, size: 16),
                label: const Text('Sign Out',
                    style: TextStyle(color: Colors.redAccent)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.redAccent),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
