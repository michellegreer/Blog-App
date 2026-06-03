import 'package:blog_app/Core/Themes/app_pallate.dart';
import 'package:blog_app/Core/Utils/show_snackbar.dart';
import 'package:blog_app/Core/Common/Widgets/kittehs_scaffold.dart';
import 'package:blog_app/Features/Auth/Presentation/Pages/signup_page.dart';
import 'package:blog_app/Features/Auth/Presentation/Widgets/auth_feilds.dart';
import 'package:blog_app/Features/Auth/Presentation/Widgets/auth_gradient_button.dart';
import 'package:blog_app/Features/Auth/Presentation/bloc/auth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SigninPage extends StatefulWidget {
  const SigninPage({super.key});

  @override
  State<SigninPage> createState() => _SigninPageState();
}

class _SigninPageState extends State<SigninPage> {
  final passwordController = TextEditingController();
  final emailController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool isVisible = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return KittehsScaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthFailure) {
            showSnackbar(context, state.message);
          }
          if (state is AuthSuccess) {
            // Pop back to the public home (VideoPostListPage)
            Navigator.of(context).pop();
          }
        },
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Sign In .',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 30),
                AuthFeilds(hint: 'Email', controller: emailController),
                const SizedBox(height: 15),
                AuthFeilds(
                  hint: 'Password',
                  controller: passwordController,
                  isVisible: isVisible,
                  visibilityIcon:
                      isVisible ? Icons.visibility_off : Icons.visibility,
                  callback: () => setState(() => isVisible = !isVisible),
                ),
                const SizedBox(height: 20),
                AuthGradientButton(
                  textt: 'Sign In',
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      context.read<AuthBloc>().add(
                        LogedInButonPressed(
                          email: emailController.text.trim(),
                          password: passwordController.text.trim(),
                        ),
                      );
                    }
                  },
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('No account yet?'),
                    TextButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const SignupPage()),
                      ),
                      child: Text(
                        'Request one',
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          color: AppPallate.gradient2,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
