import 'package:blog_app/Core/Common/Cubits/AppUser/app_user_cubit.dart';
import 'package:blog_app/Core/Common/Enteties/user_enteties.dart';
import 'package:blog_app/Core/Themes/app_pallate.dart';
import 'package:blog_app/Core/Utils/show_snackbar.dart';
import 'package:blog_app/Features/Auth/Presentation/Widgets/auth_gradient_button.dart';
import 'package:blog_app/init_dependencies.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CompleteProfilePage extends StatefulWidget {
  const CompleteProfilePage({super.key});

  @override
  State<CompleteProfilePage> createState() => _CompleteProfilePageState();
}

class _CompleteProfilePageState extends State<CompleteProfilePage> {
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final user = Supabase.instance.client.auth.currentUser;
    final metaName = user?.userMetadata?['name'] as String?;
    if (metaName != null && metaName.isNotEmpty) {
      _nameController.text = metaName;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final supabase = serviceLocater<SupabaseClient>();
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      setState(() => _loading = false);
      return;
    }

    final name = _nameController.text.trim();

    String? error;
    try {
      await supabase
          .from('profiles')
          .upsert({'id': userId, 'name': name});
    } catch (e) {
      error = e.toString();
    }

    if (!mounted) return;
    setState(() => _loading = false);

    if (error != null) {
      showSnackbar(context, 'Could not save profile: $error');
      return;
    }

    final userCubit = context.read<AppUserCubit>();
    final currentState = userCubit.state;
    if (currentState is AppUserLoggedIn) {
      userCubit.updateUser(UserEnteties(
        id: currentState.user.id,
        email: currentState.user.email,
        name: name,
        isAdmin: currentState.user.isAdmin,
        avatarUrl: currentState.user.avatarUrl,
        bio: currentState.user.bio,
      ));
    }

    if (mounted) context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPallate.backgroundColor,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('🐱', style: TextStyle(fontSize: 40)),
                  const SizedBox(height: 16),
                  Text('Welcome to Kitties FTW!',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white)),
                  const SizedBox(height: 8),
                  const Text(
                    'Before you dive in, set your display name.',
                    style: TextStyle(color: Colors.white60, fontSize: 14, height: 1.5),
                  ),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _nameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'Display name (e.g. Grandma Loretta)',
                      labelText: 'Display name',
                      labelStyle: TextStyle(color: Colors.white60),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Display name is required' : null,
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: _loading
                        ? const Center(child: CircularProgressIndicator())
                        : AuthGradientButton(textt: "Let's go", onPressed: _save),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
