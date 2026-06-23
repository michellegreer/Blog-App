import 'package:blog_app/Core/Themes/app_pallate.dart';
import 'package:blog_app/Features/Invite/Domain/UseCases/send_invite.dart';
import 'package:blog_app/init_dependencies.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> showInviteDialog(
  BuildContext context, {
  String? circleId,
  String? circleType,
  String? circleLabel,
}) {
  return showDialog(
    context: context,
    barrierDismissible: true,
    builder: (_) => _InviteDialog(
      circleId: circleId,
      circleType: circleType,
      circleLabel: circleLabel,
    ),
  );
}

class _InviteDialog extends StatefulWidget {
  final String? circleId;
  final String? circleType;
  final String? circleLabel;

  const _InviteDialog({this.circleId, this.circleType, this.circleLabel});

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

    try {
      // Record the circle invite in DB if a target circle was specified
      if (widget.circleId != null && widget.circleType != null) {
        final supabase = serviceLocater<SupabaseClient>();
        final userId = supabase.auth.currentUser?.id;
        if (userId != null) {
          await supabase.from('circle_invites').insert({
            'invited_by': userId,
            'invited_email': _emailController.text.trim(),
            'target_circle_type': widget.circleType,
            'target_circle_id': widget.circleId,
            'status': 'pending',
          });
        }
      }

      final result = await serviceLocater<SendInvite>().call(
        email: _emailController.text.trim(),
        name: _nameController.text.trim(),
        circleId: widget.circleId,
      );

      if (!mounted) return;
      result.fold(
        (failure) => setState(() { _loading = false; _error = failure.message; }),
        (_) => setState(() { _loading = false; _sent = true; }),
      );
    } catch (e) {
      if (mounted) setState(() { _loading = false; _error = e.toString(); });
    }
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
          child: _sent
              ? _SuccessView(
                  email: _emailController.text.trim(),
                  circleLabel: widget.circleLabel,
                )
              : _FormView(
                  formKey: _formKey,
                  emailController: _emailController,
                  nameController: _nameController,
                  loading: _loading,
                  error: _error,
                  circleLabel: widget.circleLabel,
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
  final String? circleLabel;
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
    this.circleLabel,
  });

  @override
  Widget build(BuildContext context) {
    final description = circleLabel != null
        ? "They'll get an email invite. Once they confirm their account they'll be added to $circleLabel."
        : "They'll get an email with a link to join. You can share a specific video with them once they're in.";

    return Form(
      key: formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            circleLabel != null ? 'Invite to $circleLabel' : 'Invite someone',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 6),
          Text(description, style: const TextStyle(color: Colors.white60, fontSize: 13)),
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
            Text(
              error!,
              style: const TextStyle(color: AppPallate.errorColor, fontSize: 13),
            ),
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
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
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
  final String? circleLabel;

  const _SuccessView({required this.email, this.circleLabel});

  @override
  Widget build(BuildContext context) {
    final message = circleLabel != null
        ? "We sent an invite to $email. Once they confirm their account, they'll be added to $circleLabel."
        : "We sent an invite to $email. They'll get a link to join Kitties FTW.";

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.check_circle_outline,
            color: AppPallate.coralColor, size: 48),
        const SizedBox(height: 16),
        Text(
          'Invite sent!',
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(color: Colors.white),
        ),
        const SizedBox(height: 8),
        Text(
          message,
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
