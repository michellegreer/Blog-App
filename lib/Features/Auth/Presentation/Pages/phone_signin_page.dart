import 'package:blog_app/Core/Utils/show_snackbar.dart';
import 'package:blog_app/Core/Common/Widgets/kittehs_scaffold.dart';
import 'package:blog_app/Features/Auth/Presentation/Widgets/auth_gradient_button.dart';
import 'package:blog_app/Features/Auth/Presentation/bloc/auth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PhoneSignInPage extends StatefulWidget {
  const PhoneSignInPage({super.key});

  @override
  State<PhoneSignInPage> createState() => _PhoneSignInPageState();
}

class _PhoneSignInPageState extends State<PhoneSignInPage> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _phoneFormKey = GlobalKey<FormState>();
  final _otpFormKey = GlobalKey<FormState>();

  // Kept locally so the OTP step survives bloc state transitions (e.g. AuthLoading)
  String? _sentToPhone;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  String _normalisePhone(String raw) {
    final digits = raw.replaceAll(RegExp(r'[^\d+]'), '');
    return digits.startsWith('+') ? digits : '+$digits';
  }

  @override
  Widget build(BuildContext context) {
    return KittehsScaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthFailure) {
            showSnackbar(context, state.message);
          }
          if (state is AuthPhoneOtpSent) {
            setState(() => _sentToPhone = state.phone);
          }
          if (state is AuthSuccess) {
            Navigator.of(context).pop();
          }
        },
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_sentToPhone != null) {
            return _OtpStep(
              phone: _sentToPhone!,
              controller: _otpController,
              formKey: _otpFormKey,
              onVerify: () {
                if (_otpFormKey.currentState!.validate()) {
                  context.read<AuthBloc>().add(PhoneOtpVerified(
                    phone: _sentToPhone!,
                    token: _otpController.text.trim(),
                  ));
                }
              },
              onResend: () {
                _otpController.clear();
                context.read<AuthBloc>().add(
                  PhoneOtpRequested(phone: _sentToPhone!),
                );
              },
              onBack: () => setState(() {
                _sentToPhone = null;
                _otpController.clear();
              }),
            );
          }

          return _PhoneStep(
            controller: _phoneController,
            formKey: _phoneFormKey,
            onSend: () {
              if (_phoneFormKey.currentState!.validate()) {
                context.read<AuthBloc>().add(PhoneOtpRequested(
                  phone: _normalisePhone(_phoneController.text.trim()),
                ));
              }
            },
            onBack: () => Navigator.of(context).pop(),
          );
        },
      ),
    );
  }
}

// ── Step 1: enter phone number ────────────────────────────────────────────────

class _PhoneStep extends StatelessWidget {
  final TextEditingController controller;
  final GlobalKey<FormState> formKey;
  final VoidCallback onSend;
  final VoidCallback onBack;

  const _PhoneStep({
    required this.controller,
    required this.formKey,
    required this.onSend,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Sign in with phone',
                  style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 12),
              Text(
                'Enter your number with country code and we\'ll text you a code.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.all(8),
                child: TextFormField(
                  controller: controller,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: 'Phone number (e.g. +1 555 123 4567)',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Phone number is required';
                    }
                    final digits =
                        value.replaceAll(RegExp(r'[^\d]'), '');
                    if (digits.length < 7) {
                      return 'Enter a valid phone number';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 20),
              AuthGradientButton(textt: 'Send code', onPressed: onSend),
              const SizedBox(height: 10),
              TextButton(onPressed: onBack, child: const Text('Back to sign in')),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Step 2: enter OTP ─────────────────────────────────────────────────────────

class _OtpStep extends StatelessWidget {
  final String phone;
  final TextEditingController controller;
  final GlobalKey<FormState> formKey;
  final VoidCallback onVerify;
  final VoidCallback onResend;
  final VoidCallback onBack;

  const _OtpStep({
    required this.phone,
    required this.controller,
    required this.formKey,
    required this.onVerify,
    required this.onResend,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Enter your code',
                  style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 12),
              Text(
                'We sent a 6-digit code to $phone.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.all(8),
                child: TextFormField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    letterSpacing: 12,
                  ),
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(
                    hintText: '000000',
                    counterText: '',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().length != 6) {
                      return 'Enter the 6-digit code';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 20),
              AuthGradientButton(textt: 'Verify', onPressed: onVerify),
              const SizedBox(height: 10),
              TextButton(onPressed: onResend, child: const Text('Resend code')),
              TextButton(onPressed: onBack, child: const Text('Use a different number')),
            ],
          ),
        ),
      ),
    );
  }
}
