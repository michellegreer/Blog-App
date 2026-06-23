import 'package:go_router/go_router.dart';
import 'package:blog_app/Features/Auth/Presentation/Pages/complete_profile_page.dart';
import 'package:blog_app/Features/Auth/Presentation/Pages/reset_password_page.dart';
import 'package:blog_app/Features/Invite/Presentation/Pages/circles_page.dart';
import 'package:blog_app/Features/VideoBlog/Domain/Entities/video_post.dart';
import 'package:blog_app/Features/VideoBlog/Presentation/pages/user_profile_page.dart';
import 'package:blog_app/Features/VideoBlog/Presentation/pages/video_post_list_page.dart';
import 'package:blog_app/Features/VideoBlog/Presentation/pages/video_post_detail_page.dart';

final appRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      pageBuilder: (context, state) => const NoTransitionPage(
        child: VideoPostListPage(),
      ),
    ),
    GoRoute(
      path: '/video/:slug',
      pageBuilder: (context, state) {
        final slug = state.pathParameters['slug']!;
        final post = state.extra as VideoPost?;
        return NoTransitionPage(
          child: VideoPostDetailPage(slug: slug, post: post),
        );
      },
    ),
    GoRoute(
      path: '/reset-password',
      pageBuilder: (context, state) => const NoTransitionPage(
        child: ResetPasswordPage(),
      ),
    ),
    GoRoute(
      path: '/complete-profile',
      pageBuilder: (context, state) => const NoTransitionPage(
        child: CompleteProfilePage(),
      ),
    ),
    GoRoute(
      path: '/circles',
      pageBuilder: (context, state) => const NoTransitionPage(
        child: CirclesPage(),
      ),
    ),
    // Must be last — catches /:username after all fixed routes
    GoRoute(
      path: '/:username',
      pageBuilder: (context, state) {
        final username = state.pathParameters['username']!;
        return NoTransitionPage(
          child: UserProfilePage(username: username),
        );
      },
    ),
  ],
);
