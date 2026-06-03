import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:blog_app/Core/Common/Cubits/AppUser/app_user_cubit.dart';
import 'package:blog_app/Core/Common/Cubits/LogOut/logout_user_cubit.dart';
import 'package:blog_app/Core/Themes/app_pallate.dart';
import 'package:blog_app/Features/Auth/Presentation/Pages/signin_page.dart';
import 'package:blog_app/Features/VideoBlog/Presentation/pages/profile_page.dart';

class AuthActions extends StatelessWidget {
  const AuthActions({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppUserCubit, AppUserState>(
      builder: (context, userState) {
        if (userState is AppUserLoggedIn) {
          final user = userState.user;
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfilePage()),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: _buildAvatar(user.avatarUrl, user.name),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.logout),
                tooltip: 'Sign out',
                onPressed: () => context.read<LogoutUserCubit>().logOutUSer(),
              ),
            ],
          );
        }
        return IconButton(
          icon: const Icon(Icons.lock_outline),
          tooltip: 'Sign in',
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SigninPage()),
          ),
        );
      },
    );
  }

  Widget _buildAvatar(String? url, String name) {
    if (url != null && url.isNotEmpty) {
      return CircleAvatar(radius: 16, backgroundImage: NetworkImage(url));
    }
    return CircleAvatar(
      radius: 16,
      backgroundColor: AppPallate.gradient1,
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: const TextStyle(color: Colors.white, fontSize: 14),
      ),
    );
  }
}
