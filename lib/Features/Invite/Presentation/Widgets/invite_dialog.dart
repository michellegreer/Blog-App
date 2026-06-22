import 'package:blog_app/Core/Themes/app_pallate.dart';
import 'package:blog_app/Features/Invite/Domain/UseCases/send_invite.dart';
import 'package:blog_app/init_dependencies.dart';
import 'package:flutter/material.dart';

Future<void> showInviteDialog(BuildContext context) {
  return showDialog(
    context: context,
    barrierDismissible: true,
    builder: (_) => const _InviteDialog(),
  );
}

class _InviteDialog extends StatefulWidget {
  const _InviteDialog();

  @override
  State<_InviteDialog> createState() => _InviteDialogState();
}

class _InviteDialogState extends State<_InviteDialog> {
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;
  String? _error;
  bool _sent = false;

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });

    final result = await serviceLocater<SendInvite>().call(
      email: _emailController.text.trim(),
      name: _nameController.text.trim(),
    );

    if (!mounted) return;
    result.fold(
      (failure) => setState(() { _loading = false; _error = failure.message; }),
      (_) => setState(() { _loading = false; _sent = true; }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppPallate.backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppPallate.borderColor),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: _sent ? _SuccessView(email: _emailController.text.trim()) : _FormView(
            formKey: _formKey,
            emailController: _emailController,
            nameController: _nameController,
            loading: _loading,
            error: _error,
            onSend: _send,
            onCancel: () => Navigator.of(context).pop(),
          ),
        ),
      ),
    );
  }
}

class _FormView extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController nameController;
  final bool loading;
  final String? error;
  final VoidCallback onSend;
  final VoidCallback onCancel;

  const _FormView({
    required this.formKey,
    required this.emailController,
    required this.nameController,
    required this.loading,
    required this.error,
    required this.onSend,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Invite someone', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white)),
          const SizedBox(height: 6),
          Text(
            "They'll get an email with a link to join. You can share a specific video with them once they're in.",
            style: const TextStyle(color: Colors.white60, fontSize: 13),
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: nameController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(hintText: 'Their name (optional)'),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(hintText: 'Email address'),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Email is required';
              if (!v.contains('@')) return 'Enter a valid email';
              return null;
            },
          ),
          if (error != null) ...[
            const SizedBox(height: 12),
            Text(error!, style: const TextStyle(color: AppPallate.errorColor, fontSize: 13)),
          ],
          const SizedBox(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(onPressed: onCancel, child: const Text('Cancel')),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: loading ? null : onSend,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppPallate.coralColor,
                  foregroundColor: Colors.white,
                  shape: const StadiumBorder(),
                ),
                child: loading
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Send invite'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SuccessView extends StatelessWidget {
  final String email;
  const _SuccessView({required this.email});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.check_circle_outline, color: AppPallate.coralColor, size: 48),
        const SizedBox(height: 16),
        Text('Invite sent!', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white)),
        const SizedBox(height: 8),
        Text(
          'We sent an invite to $email. They\'ll get a link to join Kitties FTW.',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white60, fontSize: 13),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppPallate.coralColor,
            foregroundColor: Colors.white,
            shape: const StadiumBorder(),
          ),
          child: const Text('Done'),
        ),
      ],
    );
  }
}
