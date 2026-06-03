import 'package:flutter/material.dart';
import 'package:blog_app/Core/Common/Widgets/kittehs_scaffold.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:blog_app/Core/Common/Cubits/AppUser/app_user_cubit.dart';
import 'package:blog_app/Features/VideoBlog/Domain/Entities/video_post.dart';
import 'package:blog_app/Features/VideoBlog/Presentation/bloc/video_blog_bloc.dart';

class VideoPostFormPage extends StatefulWidget {
  final VideoPost? post;
  const VideoPostFormPage({super.key, this.post});

  @override
  State<VideoPostFormPage> createState() => _VideoPostFormPageState();
}

class _VideoPostFormPageState extends State<VideoPostFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _urlController;
  late final TextEditingController _commentaryController;

  bool get _isEditing => widget.post != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.post?.title ?? '');
    _urlController = TextEditingController(text: widget.post?.youtubeUrl ?? '');
    _commentaryController = TextEditingController(text: widget.post?.commentary ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _urlController.dispose();
    _commentaryController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final title = _titleController.text.trim();
    final url = _urlController.text.trim();
    final commentary = _commentaryController.text.trim();

    if (_isEditing) {
      context.read<VideoBlogBloc>().add(VideoBlogUpdate(
            id: widget.post!.id,
            title: title,
            youtubeUrl: url,
            commentary: commentary.isEmpty ? null : commentary,
          ));
    } else {
      final appUserState = context.read<AppUserCubit>().state;
      String? posterName;
      String? posterId;
      String? posterAvatar;
      if (appUserState is AppUserLoggedIn) {
        posterName = appUserState.user.name;
        posterId = appUserState.user.id;
        posterAvatar = appUserState.user.avatarUrl;
      }
      context.read<VideoBlogBloc>().add(VideoBlogCreate(
            title: title,
            youtubeUrl: url,
            commentary: commentary.isEmpty ? null : commentary,
            postedByName: posterName,
            postedById: posterId,
            posterAvatarUrl: posterAvatar,
          ));
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return KittehsScaffold(
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                hintText: 'e.g. Mr. Whiskers discovers a box',
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
                  (value == null || value.trim().isEmpty) ? 'Title is required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _urlController,
              decoration: const InputDecoration(
                labelText: 'YouTube URL',
                hintText: 'https://www.youtube.com/watch?v=...',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.url,
              validator: (value) {
                if (value == null || value.trim().isEmpty) return 'YouTube URL is required';
                if (!value.contains('youtube.com') && !value.contains('youtu.be')) {
                  return 'Please enter a valid YouTube URL';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _commentaryController,
              decoration: const InputDecoration(
                labelText: 'Commentary (optional)',
                hintText: 'Your thoughts on this video...',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 5,
              textAlignVertical: TextAlignVertical.top,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _submit,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  _isEditing ? 'Save Changes' : 'Publish Post',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
