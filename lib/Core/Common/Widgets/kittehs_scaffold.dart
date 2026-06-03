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

    return Scaffold(
      floatingActionButton: floatingActionButton,
      appBar: AppBar(
        toolbarHeight: isWide ? 117 : 90,
        title: GestureDetector(
          onTap: () => Navigator.popUntil(context, (route) => route.isFirst),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Text('🐱', style: TextStyle(fontSize: isWide ? 32 : 20)),
                const SizedBox(width: 6),
                Text(
                  'Kittehs FTW',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isWide ? 40 : 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ]),
              Text(
                'Joyscrolling at its finest.',
                style: TextStyle(
                  color: AppPallate.coralColor,
                  fontSize: isWide ? 20 : 13,
                ),
              ),
            ],
          ),
        ),
        actions: [
          // "Create a New Post" pill button — always visible
          BlocBuilder<AppUserCubit, AppUserState>(
            builder: (context, userState) {
              final isLoggedIn = userState is AppUserLoggedIn;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                child: ElevatedButton(
                  onPressed: () {
                    if (isLoggedIn) {
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
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SignupPage()),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppPallate.coralColor,
                    foregroundColor: Colors.white,
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 0),
                    elevation: 0,
                  ),
                  child: Text(
                    isWide ? 'Create a New Post' : 'New Post',
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                ),
              );
            },
          ),
          // "About Kittehs FTW" — same color/size as byline, left of Admin
          TextButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AboutPage()),
            ),
            child: Text(
              'About Kittehs FTW',
              style: TextStyle(
                color: AppPallate.coralColor,
                fontSize: isWide ? 20 : 13,
              ),
            ),
          ),
          // Page-specific actions (e.g. Admin button on home page)
          ...extraActions,
          const AuthActions(),
        ],
      ),
      body: body,
    );
  }
}
