import 'package:blog_app/Core/Themes/app_pallate.dart';
import 'package:blog_app/Core/Utils/show_snackbar.dart';
import 'package:blog_app/Core/Common/Widgets/kittehs_scaffold.dart';
import 'package:blog_app/Features/Auth/Presentation/Pages/signin_page.dart';
import 'package:blog_app/Features/Auth/Presentation/Widgets/auth_feilds.dart';
import 'package:blog_app/Features/Auth/Presentation/Widgets/auth_gradient_button.dart';
import 'package:blog_app/Features/Auth/Presentation/bloc/auth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final nameController = TextEditingController();
  final passwordController = TextEditingController();
  final emailController = TextEditingController();
  final bioController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool isVisible = true;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    bioController.dispose();
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
            Navigator.of(context).pop();
          }
        },
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Form(
            key: formKey,
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Sign Up .',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 30),
                    AuthFeilds(hint: 'Name', controller: nameController),
                    const SizedBox(height: 15),
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
                    const SizedBox(height: 15),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        controller: bioController,
                        style: const TextStyle(color: Colors.white),
                        maxLines: 3,
                        maxLength: 280,
                        decoration: const InputDecoration(
                          hintText: 'Bio — tell us a little about yourself',
                          alignLabelWithHint: true,
                        ),
                        validator: (value) => (value == null || value.trim().isEmpty)
                            ? 'Bio is required'
                            : null,
                      ),
                    ),
                    const SizedBox(height: 20),
                    AuthGradientButton(
                      textt: 'Sign Up',
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          context.read<AuthBloc>().add(
                            SignedUpButonPressed(
                              name: nameController.text.trim(),
                              email: emailController.text.trim(),
                              password: passwordController.text.trim(),
                              bio: bioController.text.trim(),
                            ),
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Already have an account?'),
                        TextButton(
                          onPressed: () => Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (_) => const SigninPage()),
                          ),
                          child: Text(
                            'Sign In',
                            style: Theme.of(context).textTheme.bodyLarge!
                                .copyWith(color: AppPallate.gradient2),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
