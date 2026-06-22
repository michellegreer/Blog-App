import 'package:flutter/material.dart';
import 'package:blog_app/Core/Common/Widgets/kittehs_scaffold.dart';
import 'package:blog_app/Core/Themes/app_pallate.dart';
import 'package:blog_app/init_dependencies.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:blog_app/Core/Common/Cubits/AppUser/app_user_cubit.dart';
import 'package:blog_app/Features/VideoBlog/Domain/Entities/video_post.dart';
import 'package:blog_app/Features/VideoBlog/Presentation/bloc/video_blog_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _UserCircles {
  final String? familyCircleId;
  final String? extendedFamilyCircleId;
  final String? friendsCircleId;

  const _UserCircles({
    this.familyCircleId,
    this.extendedFamilyCircleId,
    this.friendsCircleId,
  });

  bool get hasAnyCircle =>
      familyCircleId != null ||
      extendedFamilyCircleId != null ||
      friendsCircleId != null;
}

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

  _UserCircles? _circles;
  bool _circlesLoading = true;

  // null = public
  CircleType? _selectedCircleType;

  bool get _isEditing => widget.post != null;

  String? get _selectedCircleId => switch (_selectedCircleType) {
        CircleType.family => _circles?.familyCircleId,
        CircleType.extendedFamily => _circles?.extendedFamilyCircleId,
        CircleType.friends => _circles?.friendsCircleId,
        null => null,
      };

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.post?.title ?? '');
    _urlController = TextEditingController(text: widget.post?.youtubeUrl ?? '');
    _commentaryController =
        TextEditingController(text: widget.post?.commentary ?? '');

    if (_isEditing) {
      _selectedCircleType = widget.post!.visibilityCircleType;
    }

    _loadCircles();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _urlController.dispose();
    _commentaryController.dispose();
    super.dispose();
  }

  Future<void> _loadCircles() async {
    final userId = serviceLocater<SupabaseClient>().auth.currentUser?.id;
    if (userId == null) {
      setState(() => _circlesLoading = false);
      return;
    }

    final supabase = serviceLocater<SupabaseClient>();

    try {
      // Find any family circle the user belongs to (member or registrant)
      final memberRows = await supabase
          .from('family_circle_members')
          .select('family_circle_id')
          .eq('profile_id', userId)
          .limit(1);

      String? fcId;
      if (memberRows.isNotEmpty) {
        fcId = memberRows[0]['family_circle_id'] as String?;
      } else {
        final registrantRows = await supabase
            .from('family_circles')
            .select('id')
            .or('registrant_id.eq.$userId,co_registrant_id.eq.$userId')
            .limit(1);
        if (registrantRows.isNotEmpty) {
          fcId = registrantRows[0]['id'] as String?;
        }
      }

      if (fcId == null) {
        setState(() {
          _circles = const _UserCircles();
          _circlesLoading = false;
        });
        return;
      }

      final efcRows = await supabase
          .from('extended_family_circles')
          .select('id')
          .eq('family_circle_id', fcId)
          .limit(1);

      final frcRows = await supabase
          .from('friends_circles')
          .select('id')
          .eq('family_circle_id', fcId)
          .limit(1);

      final circles = _UserCircles(
        familyCircleId: fcId,
        extendedFamilyCircleId:
            efcRows.isNotEmpty ? efcRows[0]['id'] as String? : null,
        friendsCircleId:
            frcRows.isNotEmpty ? frcRows[0]['id'] as String? : null,
      );

      if (!mounted) return;
      setState(() {
        _circles = circles;
        _circlesLoading = false;
        // Default new posts to Family if available
        if (!_isEditing && circles.familyCircleId != null) {
          _selectedCircleType = CircleType.family;
        }
      });
    } catch (_) {
      if (mounted) setState(() => _circlesLoading = false);
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final title = _titleController.text.trim();
    final url = _urlController.text.trim();
    final commentary = _commentaryController.text.trim();
    final isPublic = _selectedCircleType == null;

    if (_isEditing) {
      context.read<VideoBlogBloc>().add(VideoBlogUpdate(
            id: widget.post!.id,
            title: title,
            youtubeUrl: url,
            commentary: commentary.isEmpty ? null : commentary,
            visibilityCircleType: _selectedCircleType?.dbValue,
            visibilityCircleId: _selectedCircleId,
            isPublic: isPublic,
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
            visibilityCircleType: _selectedCircleType?.dbValue,
            visibilityCircleId: _selectedCircleId,
            isPublic: isPublic,
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
                  (value == null || value.trim().isEmpty)
                      ? 'Title is required'
                      : null,
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
                if (value == null || value.trim().isEmpty) {
                  return 'YouTube URL is required';
                }
                if (!value.contains('youtube.com') &&
                    !value.contains('youtu.be')) {
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
            _VisibilityPicker(
              loading: _circlesLoading,
              circles: _circles,
              selected: _selectedCircleType,
              onChanged: (type) => setState(() => _selectedCircleType = type),
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

class _VisibilityPicker extends StatelessWidget {
  final bool loading;
  final _UserCircles? circles;
  final CircleType? selected;
  final ValueChanged<CircleType?> onChanged;

  const _VisibilityPicker({
    required this.loading,
    required this.circles,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Who can see this?',
          style: Theme.of(context)
              .textTheme
              .labelLarge
              ?.copyWith(color: Colors.white70),
        ),
        const SizedBox(height: 10),
        if (loading)
          const SizedBox(
            height: 40,
            child: Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          )
        else
          Wrap(
            spacing: 8,
            children: [
              if (circles?.familyCircleId != null)
                _Chip(
                  label: 'Family',
                  icon: Icons.home_rounded,
                  selected: selected == CircleType.family,
                  onTap: () => onChanged(CircleType.family),
                ),
              if (circles?.extendedFamilyCircleId != null)
                _Chip(
                  label: 'Extended Family',
                  icon: Icons.people_rounded,
                  selected: selected == CircleType.extendedFamily,
                  onTap: () => onChanged(CircleType.extendedFamily),
                ),
              if (circles?.friendsCircleId != null)
                _Chip(
                  label: 'Friends',
                  icon: Icons.favorite_rounded,
                  selected: selected == CircleType.friends,
                  onTap: () => onChanged(CircleType.friends),
                ),
              _Chip(
                label: 'Public',
                icon: Icons.public_rounded,
                selected: selected == null,
                onTap: () => onChanged(null),
              ),
            ],
          ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _Chip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? AppPallate.gradient1
              : AppPallate.backgroundColor.withValues(alpha: 0.0),
          border: Border.all(
            color: selected ? AppPallate.gradient1 : Colors.white30,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 16,
                color: selected ? Colors.white : Colors.white54),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : Colors.white54,
                fontSize: 13,
                fontWeight:
                    selected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
