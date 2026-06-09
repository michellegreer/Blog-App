import 'package:blog_app/Core/Common/Cubits/AppUser/app_user_cubit.dart';
import 'package:blog_app/Core/Common/Cubits/LogOut/logout_user_cubit.dart';
import 'package:blog_app/Core/Themes/theme.dart';
import 'package:blog_app/Features/Auth/Presentation/bloc/auth_bloc.dart';
import 'package:blog_app/Features/Blog/Presentation/bloc/blog_bloc.dart';
import 'package:blog_app/Features/VideoBlog/Presentation/bloc/video_blog_bloc.dart';
import 'package:blog_app/Features/VideoBlog/Presentation/pages/video_post_list_page.dart';
import 'package:blog_app/init_dependencies.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => serviceLocater<AppUserCubit>()),
        BlocProvider(create: (_) => serviceLocater<LogoutUserCubit>()),
        BlocProvider(create: (_) => serviceLocater<AuthBloc>()),
        BlocProvider(create: (_) => serviceLocater<BlogBloc>()),
        BlocProvider(create: (_) => serviceLocater<VideoBlogBloc>()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // Restore session on app start — updates AppUserCubit if already logged in
    context.read<AuthBloc>().add(AuthIsUserLoggedIn());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LogoutUserCubit, LogoutUserState>(
      listener: (context, state) {
        if (state is LogOutUserSuccess) {
          context.read<AppUserCubit>().updateUser(null);
        }
      },
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Kitties FTW',
        theme: AppTheme.darkThemeMode,
        home: const VideoPostListPage(),
      ),
    );
  }
}
