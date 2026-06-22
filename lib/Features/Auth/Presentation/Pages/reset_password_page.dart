import 'package:blog_app/Core/Utils/show_snackbar.dart';
import 'package:blog_app/Core/Common/Widgets/kittehs_scaffold.dart';
import 'package:blog_app/Features/Auth/Presentation/Pages/signin_page.dart';
import 'package:blog_app/Features/Auth/Presentation/Widgets/auth_feilds.dart';
import 'package:blog_app/Features/Auth/Presentation/Widgets/auth_gradient_button.dart';
import 'package:blog_app/Features/Auth/Presentation/bloc/auth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _passwordVisible = false;
  bool _confirmVisible = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
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
          if (state is AuthPasswordResetSuccess) {
            showSnackbar(context, 'Password updated — please sign in.');
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const SigninPage()),
              (route) => route.isFirst,
            );
          }
        },
        builder: (context, state) {
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
                      'Set new password',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 30),
                    AuthFeilds(
                      hint: 'New password',
                      controller: _passwordController,
                      isVisible: !_passwordVisible,
                      visibilityIcon: _passwordVisible
                          ? Icons.visibility_off
                          : Icons.visibility,
                      callback: () =>
                          setState(() => _passwordVisible = !_passwordVisible),
                      validator: (value) {
                        if (value == null || value.length < 8) {
                          return 'Password must be at least 8 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
                    AuthFeilds(
                      hint: 'Confirm password',
                      controller: _confirmController,
                      isVisible: !_confirmVisible,
                      visibilityIcon: _confirmVisible
                          ? Icons.visibility_off
                          : Icons.visibility,
                      callback: () =>
                          setState(() => _confirmVisible = !_confirmVisible),
                      validator: (value) {
                        if (value != _passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    AuthGradientButton(
                      textt: 'Update password',
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          context.read<AuthBloc>().add(
                            ResetPasswordRequested(
                              newPassword: _passwordController.text.trim(),
                            ),
                          );
                        }
                      },
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
