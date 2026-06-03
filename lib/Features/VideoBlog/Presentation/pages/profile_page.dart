import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:blog_app/Core/Common/Cubits/AppUser/app_user_cubit.dart';
import 'package:blog_app/Core/Common/Cubits/LogOut/logout_user_cubit.dart';
import 'package:blog_app/Core/Common/Widgets/kittehs_scaffold.dart';
import 'package:blog_app/Core/Themes/app_pallate.dart';
import 'package:blog_app/Features/Auth/Data/Modals/user_modal.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _uploading = false;
  bool _savingBio = false;
  late TextEditingController _bioController;

  @override
  void initState() {
    super.initState();
    final userState = context.read<AppUserCubit>().state;
    final bio = userState is AppUserLoggedIn ? userState.user.bio : null;
    _bioController = TextEditingController(text: bio ?? '');
  }

  @override
  void dispose() {
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadAvatar() async {
    final userState = context.read<AppUserCubit>().state;
    if (userState is! AppUserLoggedIn) return;

    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );
    if (picked == null) return;

    setState(() => _uploading = true);
    try {
      final Uint8List bytes = await picked.readAsBytes();
      final ext = picked.name.split('.').last.toLowerCase();
      final path = '${userState.user.id}/avatar.$ext';
      final supabase = Supabase.instance.client;

      await supabase.storage
          .from('avatars')
          .uploadBinary(path, bytes, fileOptions: FileOptions(upsert: true));

      final publicUrl = supabase.storage.from('avatars').getPublicUrl(path);
      await supabase
          .from('profiles')
          .update({'avatar_url': publicUrl}).eq('id', userState.user.id);

      final updated = (userState.user as UserModel).copyWith(avatarUrl: publicUrl);
      if (mounted) {
        context.read<AppUserCubit>().updateUser(updated);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Avatar updated!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Future<void> _saveBio() async {
    final userState = context.read<AppUserCubit>().state;
    if (userState is! AppUserLoggedIn) return;

    setState(() => _savingBio = true);
    try {
      final newBio = _bioController.text.trim();
      final supabase = Supabase.instance.client;
      await supabase
          .from('profiles')
          .update({'bio': newBio.isEmpty ? null : newBio})
          .eq('id', userState.user.id);

      final updated = (userState.user as UserModel)
          .copyWith(bio: newBio.isEmpty ? null : newBio);
      if (mounted) {
        context.read<AppUserCubit>().updateUser(updated);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bio saved!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Save failed: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _savingBio = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userState = context.watch<AppUserCubit>().state;
    if (userState is! AppUserLoggedIn) return const SizedBox.shrink();

    final user = userState.user;
    final screenW = MediaQuery.sizeOf(context).width;
    final contentW = (screenW * 0.70).clamp(300.0, 600.0);

    return BlocListener<LogoutUserCubit, LogoutUserState>(
      listener: (context, state) {
        if (state is LogOutUserSuccess) {
          context.read<AppUserCubit>().updateUser(null);
          Navigator.of(context).pop();
        }
      },
      child: KittehsScaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Center(
            child: SizedBox(
              width: contentW,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Avatar
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      _uploading
                          ? const CircleAvatar(
                              radius: 56,
                              child: CircularProgressIndicator())
                          : (user.avatarUrl != null && user.avatarUrl!.isNotEmpty)
                              ? CircleAvatar(
                                  radius: 56,
                                  backgroundImage: NetworkImage(user.avatarUrl!))
                              : CircleAvatar(
                                  radius: 56,
                                  backgroundColor: AppPallate.gradient1,
                                  child: Text(
                                    user.name.isNotEmpty
                                        ? user.name[0].toUpperCase()
                                        : '?',
                                    style: const TextStyle(
                                        fontSize: 40, color: Colors.white),
                                  ),
                                ),
                      if (!_uploading)
                        GestureDetector(
                          onTap: _pickAndUploadAvatar,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: AppPallate.coralColor,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.camera_alt,
                                size: 18, color: Colors.white),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Name + email + role badge
                  Text(user.name,
                      style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 4),
                  Text(user.email,
                      style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: user.isAdmin
                          ? AppPallate.gradient1.withValues(alpha: 0.2)
                          : AppPallate.borderColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      user.isAdmin ? 'Admin' : 'Member',
                      style: TextStyle(
                        color: user.isAdmin
                            ? AppPallate.gradient1
                            : AppPallate.coralColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                  const Divider(),
                  const SizedBox(height: 16),

                  // Bio section
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Bio',
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(fontSize: 16)),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _bioController,
                    maxLines: 4,
                    maxLength: 280,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'Tell people a little about yourself...',
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          _bioController.text = user.bio ?? '';
                          setState(() {});
                        },
                        child: const Text('Reset',
                            style: TextStyle(color: Colors.grey)),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _savingBio ? null : _saveBio,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppPallate.coralColor,
                          foregroundColor: Colors.white,
                          shape: const StadiumBorder(),
                        ),
                        child: _savingBio
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white))
                            : const Text('Save Bio'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 24),

                  // Avatar + sign out buttons
                  OutlinedButton.icon(
                    onPressed: _uploading ? null : _pickAndUploadAvatar,
                    icon: const Icon(Icons.photo_library_outlined),
                    label: const Text('Change Avatar'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () =>
                        context.read<LogoutUserCubit>().logOutUSer(),
                    icon: const Icon(Icons.logout, color: Colors.redAccent),
                    label: const Text('Sign Out',
                        style: TextStyle(color: Colors.redAccent)),
                    style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.redAccent)),
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
