import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:blog_app/Core/Common/Cubits/AppUser/app_user_cubit.dart';
import 'package:blog_app/Core/Common/Widgets/kittehs_scaffold.dart';
import 'package:blog_app/Core/Themes/app_pallate.dart';
import 'package:blog_app/Features/Auth/Presentation/Pages/signin_page.dart';
import 'package:blog_app/Features/Auth/Presentation/Pages/signup_page.dart';
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
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(value: bloc, child: const VideoAdminPage()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userState = context.watch<AppUserCubit>().state;
    final loggedInUser =
        userState is AppUserLoggedIn ? userState.user : null;

    return KittehsScaffold(
      extraActions: [
        if (loggedInUser?.isAdmin == true)
          IconButton(
            icon: const Icon(Icons.admin_panel_settings_outlined),
            tooltip: 'Admin',
            onPressed: () => _navigateToAdmin(context),
          ),
      ],
      body: Column(
        children: [
          if (loggedInUser == null) const _GuestHero(),
          Expanded(
            child: BlocBuilder<VideoBlogBloc, VideoBlogState>(
              builder: (context, state) {
                if (state is VideoBlogLoading || state is VideoBlogInitial) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is VideoBlogFailure) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: Colors.red),
                        const SizedBox(height: 12),
                        Text(state.error),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () =>
                              context.read<VideoBlogBloc>().add(VideoBlogFetchAll()),
                          child: const Text('Try again'),
                        ),
                      ],
                    ),
                  );
                }
                if (state is VideoBlogSuccess) {
                  if (state.allPosts.isEmpty) {
                    return _EmptyState(isGuest: loggedInUser == null);
                  }
                  return Column(
                    children: [
                      if (loggedInUser == null)
                        const Padding(
                          padding: EdgeInsets.fromLTRB(16, 20, 16, 4),
                          child: Row(
                            children: [
                              Icon(Icons.public, size: 16, color: Colors.white38),
                              SizedBox(width: 6),
                              Text(
                                'Public videos',
                                style: TextStyle(
                                  color: Colors.white38,
                                  fontSize: 12,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                        ),
                      Expanded(child: _VideoGrid(posts: state.currentPosts)),
                      if (state.totalPages > 1) _PaginationBar(state: state),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Guest hero ────────────────────────────────────────────────────────────────

class _GuestHero extends StatelessWidget {
  const _GuestHero();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2D1A4A),
            Color(0xFF1A1A2E),
          ],
        ),
        border: Border(
          bottom: BorderSide(color: AppPallate.borderColor),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 600;
          return isWide
              ? _HeroWide()
              : _HeroNarrow();
        },
      ),
    );
  }
}

class _HeroWide extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: _HeroText()),
        const SizedBox(width: 32),
        _HeroCtas(),
      ],
    );
  }
}

class _HeroNarrow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _HeroText(),
        const SizedBox(height: 20),
        _HeroCtas(),
      ],
    );
  }
}

class _HeroText extends StatelessWidget {
  const _HeroText();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('🐱', style: TextStyle(fontSize: 36)),
        const SizedBox(height: 8),
        Text(
          'A private corner of the internet\nfor the people you love.',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                height: 1.35,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Share videos with your family and friends — no algorithm, no strangers.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white54,
                height: 1.5,
              ),
        ),
      ],
    );
  }
}

class _HeroCtas extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 10,
      children: [
        FilledButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SignupPage()),
          ),
          style: FilledButton.styleFrom(
            backgroundColor: AppPallate.gradient1,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: const StadiumBorder(),
          ),
          child: const Text('Join the family', style: TextStyle(fontWeight: FontWeight.w600)),
        ),
        OutlinedButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SigninPage()),
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white70,
            side: const BorderSide(color: Colors.white24),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: const StadiumBorder(),
          ),
          child: const Text('Sign in'),
        ),
      ],
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final bool isGuest;
  const _EmptyState({required this.isGuest});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('😿', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text(
              isGuest ? 'No public videos yet.' : 'No kitty videos yet!',
              style: const TextStyle(fontSize: 18, color: Colors.white70),
            ),
            if (isGuest) ...[
              const SizedBox(height: 8),
              const Text(
                'Sign up to see the full family feed.',
                style: TextStyle(color: Colors.white38, fontSize: 14),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SignupPage()),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: AppPallate.gradient1,
                  shape: const StadiumBorder(),
                ),
                child: const Text('Sign up'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Feed grid ─────────────────────────────────────────────────────────────────

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

// ── Pagination ────────────────────────────────────────────────────────────────

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
                ? () => context
                    .read<VideoBlogBloc>()
                    .add(VideoBlogChangePage(state.currentPage - 1))
                : null,
          ),
          ...List.generate(state.totalPages, (i) {
            final page = i + 1;
            final isCurrent = page == state.currentPage;
            return TextButton(
              onPressed: isCurrent
                  ? null
                  : () => context
                      .read<VideoBlogBloc>()
                      .add(VideoBlogChangePage(page)),
              style: TextButton.styleFrom(
                foregroundColor:
                    isCurrent ? Colors.white : AppPallate.coralColor,
                minimumSize: const Size(36, 36),
                padding: EdgeInsets.zero,
              ),
              child: Text(
                '$page',
                style: TextStyle(
                  fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                  decoration: isCurrent ? TextDecoration.underline : null,
                ),
              ),
            );
          }),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: state.currentPage < state.totalPages
                ? () => context
                    .read<VideoBlogBloc>()
                    .add(VideoBlogChangePage(state.currentPage + 1))
                : null,
          ),
        ],
      ),
    );
  }
}
