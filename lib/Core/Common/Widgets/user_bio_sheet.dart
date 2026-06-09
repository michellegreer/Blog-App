import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:blog_app/Core/Themes/app_pallate.dart';

void showUserBio(
  BuildContext context, {
  required String userId,
  required String userName,
  String? avatarUrl,
}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: const Color.fromRGBO(34, 34, 44, 1),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) => _UserBioSheet(
      userId: userId,
      userName: userName,
      avatarUrl: avatarUrl,
    ),
  );
}

class _UserBioSheet extends StatefulWidget {
  final String userId;
  final String userName;
  final String? avatarUrl;

  const _UserBioSheet({
    required this.userId,
    required this.userName,
    this.avatarUrl,
  });

  @override
  State<_UserBioSheet> createState() => _UserBioSheetState();
}

class _UserBioSheetState extends State<_UserBioSheet> {
  String? _bio;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    try {
      final data = await Supabase.instance.client
          .from('profiles')
          .select('bio')
          .eq('id', widget.userId)
          .single();
      if (mounted) setState(() { _bio = data['bio'] as String?; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[600],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildAvatar(),
              const SizedBox(width: 12),
              Text(
                widget.userName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_loading)
            const CircularProgressIndicator()
          else
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _bio != null && _bio!.isNotEmpty
                    ? _bio!
                    : 'No bio yet.',
                style: TextStyle(
                  color: _bio != null && _bio!.isNotEmpty
                      ? Colors.white70
                      : Colors.grey,
                  fontSize: 15,
                  height: 1.6,
                ),
              ),
            ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    if (widget.avatarUrl != null && widget.avatarUrl!.isNotEmpty) {
      return CircleAvatar(
          radius: 24, backgroundImage: NetworkImage(widget.avatarUrl!));
    }
    return CircleAvatar(
      radius: 24,
      backgroundColor: AppPallate.gradient1,
      child: Text(
        widget.userName.isNotEmpty ? widget.userName[0].toUpperCase() : '?',
        style: const TextStyle(
            color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}
