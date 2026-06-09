import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:blog_app/Core/Common/Cubits/AppUser/app_user_cubit.dart';
import 'package:blog_app/Core/Common/Widgets/auth_actions.dart';
import 'package:blog_app/Core/Themes/app_pallate.dart';
import 'package:blog_app/Features/About/about_page.dart';
import 'package:blog_app/Features/Auth/Presentation/Pages/signup_page.dart';
import 'package:blog_app/Features/VideoBlog/Presentation/bloc/video_blog_bloc.dart';
import 'package:blog_app/Features/VideoBlog/Presentation/pages/video_post_form_page.dart';

class KittehsScaffold extends StatelessWidget {
  final Widget body;
  final List<Widget> extraActions;
  final Widget? floatingActionButton;

  const KittehsScaffold({
    super.key,
    required this.body,
    this.extraActions = const [],
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final isWide = w >= 700;

    return isWide
        ? _WideScaffold(
            body: body,
            extraActions: extraActions,
            floatingActionButton: floatingActionButton,
          )
        : _NarrowScaffold(
            body: body,
            extraActions: extraActions,
            floatingActionButton: floatingActionButton,
          );
  }
}

// ── Desktop: single-row nav ───────────────────────────────────────────────────

class _WideScaffold extends StatelessWidget {
  final Widget body;
  final List<Widget> extraActions;
  final Widget? floatingActionButton;
  const _WideScaffold({required this.body, required this.extraActions, this.floatingActionButton});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: floatingActionButton,
      appBar: AppBar(
        toolbarHeight: 117,
        title: _Logo(isWide: true),
        actions: [
          _AboutButton(isWide: true),
          _NewPostButton(isWide: true),
          ...extraActions,
          const AuthActions(),
        ],
      ),
      body: body,
    );
  }
}

// ── Mobile: two-row nav ───────────────────────────────────────────────────────

class _NarrowScaffold extends StatelessWidget {
  final Widget body;
  final List<Widget> extraActions;
  final Widget? floatingActionButton;
  const _NarrowScaffold({required this.body, required this.extraActions, this.floatingActionButton});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: floatingActionButton,
      appBar: AppBar(
        toolbarHeight: 64,
        title: _Logo(isWide: false),
        actions: [
          ...extraActions,
          const AuthActions(),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: AppPallate.backgroundColor,
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                _AboutButton(isWide: false),
                const SizedBox(width: 8),
                _NewPostButton(isWide: false),
              ],
            ),
          ),
        ),
      ),
      body: body,
    );
  }
}

// ── Shared pieces ─────────────────────────────────────────────────────────────

class _Logo extends StatelessWidget {
  final bool isWide;
  const _Logo({required this.isWide});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.popUntil(context, (route) => route.isFirst),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text('🐱', style: TextStyle(fontSize: isWide ? 32 : 20)),
            const SizedBox(width: 6),
            Text('Kitties FTW', style: TextStyle(
              color: Colors.white,
              fontSize: isWide ? 40 : 24,
              fontWeight: FontWeight.bold,
            )),
          ]),
          Text('Joyscrolling at its finest.', style: TextStyle(
            color: AppPallate.coralColor,
            fontSize: isWide ? 20 : 12,
          )),
        ],
      ),
    );
  }
}

class _AboutButton extends StatelessWidget {
  final bool isWide;
  const _AboutButton({required this.isWide});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AboutPage()),
      ),
      child: Text('About', style: TextStyle(
        color: AppPallate.coralColor,
        fontSize: isWide ? 20 : 14,
      )),
    );
  }
}

class _NewPostButton extends StatelessWidget {
  final bool isWide;
  const _NewPostButton({required this.isWide});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppUserCubit, AppUserState>(
      builder: (context, userState) {
        final isLoggedIn = userState is AppUserLoggedIn;
        return Padding(
          padding: EdgeInsets.symmetric(vertical: isWide ? 10 : 6, horizontal: 4),
          child: ElevatedButton(
            onPressed: () {
              if (isLoggedIn) {
                final bloc = context.read<VideoBlogBloc>();
                Navigator.push(context, MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: bloc,
                    child: const VideoPostFormPage(),
                  ),
                ));
              } else {
                Navigator.push(context, MaterialPageRoute(
                  builder: (_) => const SignupPage(),
                ));
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppPallate.coralColor,
              foregroundColor: Colors.white,
              shape: const StadiumBorder(),
              padding: EdgeInsets.symmetric(
                horizontal: isWide ? 18 : 14,
                vertical: 0,
              ),
              elevation: 0,
            ),
            child: Text(
              isWide ? 'Create a New Post' : 'New Post',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ),
        );
      },
    );
  }
}
