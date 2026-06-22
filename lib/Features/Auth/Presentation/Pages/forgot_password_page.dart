import 'package:blog_app/Core/Utils/show_snackbar.dart';
import 'package:blog_app/Core/Common/Widgets/kittehs_scaffold.dart';
import 'package:blog_app/Features/Auth/Presentation/Widgets/auth_feilds.dart';
import 'package:blog_app/Features/Auth/Presentation/Widgets/auth_gradient_button.dart';
import 'package:blog_app/Features/Auth/Presentation/bloc/auth_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  String get _redirectTo {
    if (kIsWeb) {
      final base = Uri.base;
      return '${base.scheme}://${base.host}${base.port != 0 && base.port != 80 && base.port != 443 ? ':${base.port}' : ''}/reset-password';
    }
    return 'io.kittiesftw://reset-password';
  }

  @override
  Widget build(BuildContext context) {
    return KittehsScaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthFailure) {
            showSnackbar(context, state.message);
          }
        },
        builder: (context, state) {
          if (state is AuthPasswordResetEmailSent) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('📬', style: TextStyle(fontSize: 64)),
                    const SizedBox(height: 24),
                    Text(
                      'Check your email',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'We sent a password reset link to ${_emailController.text.trim()}.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 32),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Back to sign in'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is AuthLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Form(
            key: _formKey,
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Forgot password?',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Enter your email and we\'ll send you a reset link.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 30),
                    AuthFeilds(hint: 'Email', controller: _emailController),
                    const SizedBox(height: 20),
                    AuthGradientButton(
                      textt: 'Send reset link',
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          context.read<AuthBloc>().add(
                            ForgotPasswordRequested(
                              email: _emailController.text.trim(),
                              redirectTo: _redirectTo,
                            ),
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Back to sign in'),
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
