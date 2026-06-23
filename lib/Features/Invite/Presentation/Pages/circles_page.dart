import 'package:flutter/material.dart';
import 'package:blog_app/Core/Common/Cubits/AppUser/app_user_cubit.dart';
import 'package:blog_app/Core/Common/Widgets/kittehs_scaffold.dart';
import 'package:blog_app/Core/Themes/app_pallate.dart';
import 'package:blog_app/Features/Invite/Presentation/Widgets/invite_dialog.dart';
import 'package:blog_app/init_dependencies.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

// ── Domain types ──────────────────────────────────────────────────────────────

class _Member {
  final String profileId;
  final String name;
  final String? avatarUrl;
  final String? username;
  final String? badge; // membership_type, relationship_label, etc.

  const _Member({
    required this.profileId,
    required this.name,
    this.avatarUrl,
    this.username,
    this.badge,
  });
}

class _CircleData {
  final String familyCircleId;
  final String familyCircleName;
  final String registrantId;
  final String? coRegistrantId;
  final String? extFamilyCircleId;
  final String? friendsCircleId;
  final bool isManager;
  final List<_Member> familyMembers;
  final List<_Member> extFamilyMembers;
  final List<_Member> friendsMembers;

  const _CircleData({
    required this.familyCircleId,
    required this.familyCircleName,
    required this.registrantId,
    this.coRegistrantId,
    this.extFamilyCircleId,
    this.friendsCircleId,
    required this.isManager,
    required this.familyMembers,
    required this.extFamilyMembers,
    required this.friendsMembers,
  });
}

// ── Page ─────────────────────────────────────────────────────────────────────

class CirclesPage extends StatefulWidget {
  const CirclesPage({super.key});

  @override
  State<CirclesPage> createState() => _CirclesPageState();
}

class _CirclesPageState extends State<CirclesPage> {
  _CircleData? _data;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    final supabase = serviceLocater<SupabaseClient>();
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      setState(() { _loading = false; _error = 'Not logged in'; });
      return;
    }

    try {
      // Get the user's family circle
      final fcRows = await supabase
          .from('family_circles')
          .select('id, name, registrant_id, co_registrant_id')
          .or('registrant_id.eq.$userId,co_registrant_id.eq.$userId')
          .limit(1);

      String? fcId;
      String? fcName;
      String? registrantId;
      String? coRegistrantId;

      if (fcRows.isEmpty) {
        // Check if member (not registrant)
        final memberRows = await supabase
            .from('family_circle_members')
            .select('family_circle_id, family_circles(id, name, registrant_id, co_registrant_id)')
            .eq('profile_id', userId)
            .limit(1);

        if (memberRows.isEmpty) {
          setState(() { _loading = false; });
          return;
        }
        final fc = memberRows[0]['family_circles'] as Map<String, dynamic>;
        fcId = fc['id'] as String;
        fcName = fc['name'] as String;
        registrantId = fc['registrant_id'] as String;
        coRegistrantId = fc['co_registrant_id'] as String?;
      } else {
        fcId = fcRows[0]['id'] as String;
        fcName = fcRows[0]['name'] as String;
        registrantId = fcRows[0]['registrant_id'] as String;
        coRegistrantId = fcRows[0]['co_registrant_id'] as String?;
      }

      final isManager = userId == registrantId || userId == coRegistrantId;

      // Load family members + linked circle IDs in parallel
      final familyMemberRowsFuture = supabase
          .from('family_circle_members')
          .select('profile_id, membership_type, profiles(name, avatar_url, username)')
          .eq('family_circle_id', fcId);
      final efcRowsFuture = supabase
          .from('extended_family_circles')
          .select('id')
          .eq('family_circle_id', fcId)
          .limit(1);
      final frcRowsFuture = supabase
          .from('friends_circles')
          .select('id')
          .eq('family_circle_id', fcId)
          .limit(1);

      final familyMemberRows = await familyMemberRowsFuture;
      final efcRows = await efcRowsFuture;
      final frcRows = await frcRowsFuture;

      final efcId = efcRows.isNotEmpty ? efcRows[0]['id'] as String? : null;
      final frcId = frcRows.isNotEmpty ? frcRows[0]['id'] as String? : null;

      final familyMembers = familyMemberRows.map((r) {
        final p = r['profiles'] as Map<String, dynamic>;
        return _Member(
          profileId: r['profile_id'] as String,
          name: p['name'] as String? ?? '',
          avatarUrl: p['avatar_url'] as String?,
          username: p['username'] as String?,
          badge: r['membership_type'] as String?,
        );
      }).toList();

      List<_Member> extFamilyMembers = [];
      List<_Member> friendsMembers = [];

      if (efcId != null) {
        final rows = await supabase
            .from('extended_family_circle_members')
            .select('profile_id, relationship_label, profiles(name, avatar_url, username)')
            .eq('extended_family_circle_id', efcId);
        extFamilyMembers = rows.map((r) {
          final p = r['profiles'] as Map<String, dynamic>;
          return _Member(
            profileId: r['profile_id'] as String,
            name: p['name'] as String? ?? '',
            avatarUrl: p['avatar_url'] as String?,
            username: p['username'] as String?,
            badge: r['relationship_label'] as String?,
          );
        }).toList();
      }

      if (frcId != null) {
        final rows = await supabase
            .from('friends_circle_members')
            .select('profile_id, profiles(name, avatar_url, username)')
            .eq('friends_circle_id', frcId);
        friendsMembers = rows.map((r) {
          final p = r['profiles'] as Map<String, dynamic>;
          return _Member(
            profileId: r['profile_id'] as String,
            name: p['name'] as String? ?? '',
            avatarUrl: p['avatar_url'] as String?,
            username: p['username'] as String?,
          );
        }).toList();
      }

      if (!mounted) return;
      setState(() {
        _loading = false;
        _data = _CircleData(
          familyCircleId: fcId!,
          familyCircleName: fcName!,
          registrantId: registrantId!,
          coRegistrantId: coRegistrantId,
          extFamilyCircleId: efcId,
          friendsCircleId: frcId,
          isManager: isManager,
          familyMembers: familyMembers,
          extFamilyMembers: extFamilyMembers,
          friendsMembers: friendsMembers,
        );
      });
    } catch (e) {
      if (mounted) setState(() { _loading = false; _error = e.toString(); });
    }
  }

  Future<void> _removeMember({
    required String table,
    required String idColumn,
    required String circleId,
    required String profileId,
  }) async {
    final supabase = serviceLocater<SupabaseClient>();
    await supabase
        .from(table)
        .delete()
        .eq(idColumn, circleId)
        .eq('profile_id', profileId);
    await _load();
  }

  Future<void> _addExistingMember({
    required String table,
    required String idColumn,
    required String circleId,
    required _Member member,
    Map<String, dynamic> extra = const {},
  }) async {
    final supabase = serviceLocater<SupabaseClient>();
    await supabase.from(table).insert({
      idColumn: circleId,
      'profile_id': member.profileId,
      ...extra,
    });
    await _load();
  }

  Future<void> _createCircle(String name) async {
    final supabase = serviceLocater<SupabaseClient>();
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    setState(() => _loading = true);
    try {
      // Generate the ID client-side so we can skip RETURNING.
      // PostgREST applies the SELECT policy to RETURNING rows in the same
      // statement, and the STABLE my_family_circle_ids() function doesn't
      // see the just-inserted row yet — causing a spurious 42501.
      final fcId = const Uuid().v4();

      await supabase.from('family_circles').insert({
        'id': fcId,
        'name': name,
        'registrant_id': userId,
      });

      await Future.wait([
        supabase.from('extended_family_circles')
            .insert({'family_circle_id': fcId}),
        supabase.from('friends_circles')
            .insert({'family_circle_id': fcId}),
        supabase.from('family_circle_members').insert({
          'family_circle_id': fcId,
          'profile_id': userId,
          'membership_type': 'adult',
        }),
      ]);

      await _load();
    } catch (e) {
      if (mounted) setState(() { _loading = false; _error = e.toString(); });
    }
  }

  void _showCreateCircleDialog() {
    final controller = TextEditingController(text: 'The Family');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppPallate.backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppPallate.borderColor),
        ),
        title: const Text('Create your circle',
            style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(hintText: 'Circle name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isEmpty) return;
              Navigator.pop(ctx);
              await _createCircle(name);
            },
            child: const Text('Create',
                style: TextStyle(color: AppPallate.coralColor)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return KittehsScaffold(
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    if (_error != null) {
      return Center(child: Text(_error!, style: const TextStyle(color: Colors.red)));
    }

    if (_data == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🐱', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 16),
              const Text(
                "You're not in any circles yet.",
                style: TextStyle(color: Colors.white70, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Start your own, or ask someone to invite you.',
                style: TextStyle(color: Colors.white38, fontSize: 13),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _showCreateCircleDialog,
                icon: const Icon(Icons.add),
                label: const Text('Create my circle'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppPallate.coralColor,
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final data = _data!;
    final currentUserId =
        (context.read<AppUserCubit>().state as AppUserLoggedIn?)?.user.id;

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Header
          Text(
            data.familyCircleName,
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          if (!data.isManager)
            const Text(
              'You can view circle members.',
              style: TextStyle(color: Colors.white38, fontSize: 12),
            ),
          const SizedBox(height: 24),

          _CircleSection(
            title: 'Family',
            icon: Icons.home_rounded,
            cap: 6,
            members: data.familyMembers,
            isManager: data.isManager,
            currentUserId: currentUserId,
            onAdd: data.isManager
                ? () => _showAddSheet(
                      context: context,
                      circleId: data.familyCircleId,
                      circleType: 'family',
                      circleLabel: 'Family',
                      existingIds:
                          data.familyMembers.map((m) => m.profileId).toSet(),
                      onAddExisting: (member) => _addExistingMember(
                        table: 'family_circle_members',
                        idColumn: 'family_circle_id',
                        circleId: data.familyCircleId,
                        member: member,
                        extra: {'membership_type': 'adult'},
                      ),
                    )
                : null,
            onRemove: data.isManager
                ? (member) => _removeMember(
                      table: 'family_circle_members',
                      idColumn: 'family_circle_id',
                      circleId: data.familyCircleId,
                      profileId: member.profileId,
                    )
                : null,
          ),

          const SizedBox(height: 32),

          _CircleSection(
            title: 'Extended Family',
            icon: Icons.people_rounded,
            cap: 60,
            members: data.extFamilyMembers,
            isManager: data.isManager,
            currentUserId: currentUserId,
            onAdd: (data.isManager && data.extFamilyCircleId != null)
                ? () => _showAddSheet(
                      context: context,
                      circleId: data.extFamilyCircleId!,
                      circleType: 'extended_family',
                      circleLabel: 'Extended Family',
                      existingIds: data.extFamilyMembers
                          .map((m) => m.profileId)
                          .toSet(),
                      onAddExisting: (member) => _addExistingMember(
                        table: 'extended_family_circle_members',
                        idColumn: 'extended_family_circle_id',
                        circleId: data.extFamilyCircleId!,
                        member: member,
                      ),
                    )
                : null,
            onRemove: (data.isManager && data.extFamilyCircleId != null)
                ? (member) => _removeMember(
                      table: 'extended_family_circle_members',
                      idColumn: 'extended_family_circle_id',
                      circleId: data.extFamilyCircleId!,
                      profileId: member.profileId,
                    )
                : null,
          ),

          const SizedBox(height: 32),

          _CircleSection(
            title: 'Friends',
            icon: Icons.favorite_rounded,
            cap: 140,
            members: data.friendsMembers,
            isManager: data.isManager,
            currentUserId: currentUserId,
            onAdd: (data.isManager && data.friendsCircleId != null)
                ? () => _showAddSheet(
                      context: context,
                      circleId: data.friendsCircleId!,
                      circleType: 'friends',
                      circleLabel: 'Friends',
                      existingIds:
                          data.friendsMembers.map((m) => m.profileId).toSet(),
                      onAddExisting: (member) => _addExistingMember(
                        table: 'friends_circle_members',
                        idColumn: 'friends_circle_id',
                        circleId: data.friendsCircleId!,
                        member: member,
                      ),
                    )
                : null,
            onRemove: (data.isManager && data.friendsCircleId != null)
                ? (member) => _removeMember(
                      table: 'friends_circle_members',
                      idColumn: 'friends_circle_id',
                      circleId: data.friendsCircleId!,
                      profileId: member.profileId,
                    )
                : null,
          ),
        ],
      ),
    );
  }

  void _showAddSheet({
    required BuildContext context,
    required String circleId,
    required String circleType,
    required String circleLabel,
    required Set<String> existingIds,
    required Future<void> Function(_Member) onAddExisting,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppPallate.backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        side: BorderSide(color: AppPallate.borderColor),
      ),
      builder: (_) => _AddMemberSheet(
        circleId: circleId,
        circleType: circleType,
        circleLabel: circleLabel,
        existingIds: existingIds,
        onAddExisting: onAddExisting,
        onRefresh: _load,
      ),
    );
  }
}

// ── Circle section ────────────────────────────────────────────────────────────

class _CircleSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final int cap;
  final List<_Member> members;
  final bool isManager;
  final String? currentUserId;
  final VoidCallback? onAdd;
  final void Function(_Member)? onRemove;

  const _CircleSection({
    required this.title,
    required this.icon,
    required this.cap,
    required this.members,
    required this.isManager,
    this.currentUserId,
    this.onAdd,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: AppPallate.coralColor),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(color: Colors.white),
            ),
            const SizedBox(width: 8),
            Text(
              '${members.length}/$cap',
              style: const TextStyle(color: Colors.white38, fontSize: 12),
            ),
            const Spacer(),
            if (onAdd != null)
              TextButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add'),
                style: TextButton.styleFrom(
                  foregroundColor: AppPallate.coralColor,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        const Divider(height: 1),
        if (members.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: Text(
                'No members yet.',
                style: TextStyle(color: Colors.white24, fontSize: 13),
              ),
            ),
          )
        else
          ...members.map((m) => _MemberTile(
                member: m,
                isCurrentUser: m.profileId == currentUserId,
                canRemove: onRemove != null && m.profileId != currentUserId,
                onRemove: onRemove == null ? null : () => onRemove!(m),
              )),
      ],
    );
  }
}

// ── Member tile ───────────────────────────────────────────────────────────────

class _MemberTile extends StatelessWidget {
  final _Member member;
  final bool isCurrentUser;
  final bool canRemove;
  final VoidCallback? onRemove;

  const _MemberTile({
    required this.member,
    required this.isCurrentUser,
    required this.canRemove,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
      leading: _Avatar(avatarUrl: member.avatarUrl, name: member.name),
      title: Text(
        member.name + (isCurrentUser ? ' (you)' : ''),
        style: const TextStyle(color: Colors.white, fontSize: 14),
      ),
      subtitle: member.username != null || member.badge != null
          ? Text(
              [
                if (member.username != null) '@${member.username}',
                if (member.badge != null) member.badge!,
              ].join(' · '),
              style: const TextStyle(color: Colors.white38, fontSize: 12),
            )
          : null,
      trailing: canRemove
          ? IconButton(
              icon: const Icon(Icons.remove_circle_outline,
                  color: Colors.white24, size: 20),
              tooltip: 'Remove',
              onPressed: () => _confirmRemove(context),
            )
          : null,
    );
  }

  void _confirmRemove(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppPallate.backgroundColor,
        title: const Text('Remove member?',
            style: TextStyle(color: Colors.white)),
        content: Text(
          'Remove ${member.name} from this circle?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onRemove?.call();
            },
            child: const Text('Remove',
                style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}

// ── Add member sheet ──────────────────────────────────────────────────────────

class _AddMemberSheet extends StatefulWidget {
  final String circleId;
  final String circleType;
  final String circleLabel;
  final Set<String> existingIds;
  final Future<void> Function(_Member) onAddExisting;
  final Future<void> Function() onRefresh;

  const _AddMemberSheet({
    required this.circleId,
    required this.circleType,
    required this.circleLabel,
    required this.existingIds,
    required this.onAddExisting,
    required this.onRefresh,
  });

  @override
  State<_AddMemberSheet> createState() => _AddMemberSheetState();
}

class _AddMemberSheetState extends State<_AddMemberSheet>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppPallate.borderColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Add to ${widget.circleLabel}',
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(color: Colors.white),
            ),
          ),
          const SizedBox(height: 12),
          TabBar(
            controller: _tabs,
            tabs: const [
              Tab(text: 'Invite by email'),
              Tab(text: 'Add existing'),
            ],
            labelColor: AppPallate.coralColor,
            unselectedLabelColor: Colors.white38,
            indicatorColor: AppPallate.coralColor,
          ),
          SizedBox(
            height: 320,
            child: TabBarView(
              controller: _tabs,
              children: [
                _InviteTab(
                  circleId: widget.circleId,
                  circleType: widget.circleType,
                  circleLabel: widget.circleLabel,
                  onDone: () {
                    Navigator.pop(context);
                    widget.onRefresh();
                  },
                ),
                _AddExistingTab(
                  existingIds: widget.existingIds,
                  onAdd: (member) async {
                    await widget.onAddExisting(member);
                    if (context.mounted) Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Invite by email tab ───────────────────────────────────────────────────────

class _InviteTab extends StatelessWidget {
  final String circleId;
  final String circleType;
  final String circleLabel;
  final VoidCallback onDone;

  const _InviteTab({
    required this.circleId,
    required this.circleType,
    required this.circleLabel,
    required this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "They'll get an email invite. Once they confirm their account they'll be added to $circleLabel.",
            style: const TextStyle(color: Colors.white54, fontSize: 13, height: 1.5),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () async {
                Navigator.pop(context);
                await showInviteDialog(
                  context,
                  circleId: circleId,
                  circleType: circleType,
                  circleLabel: circleLabel,
                );
                onDone();
              },
              icon: const Icon(Icons.email_outlined),
              label: Text('Send invite to $circleLabel'),
              style: FilledButton.styleFrom(
                backgroundColor: AppPallate.coralColor,
                shape: const StadiumBorder(),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Add existing member tab ───────────────────────────────────────────────────

class _AddExistingTab extends StatefulWidget {
  final Set<String> existingIds;
  final Future<void> Function(_Member) onAdd;

  const _AddExistingTab({
    required this.existingIds,
    required this.onAdd,
  });

  @override
  State<_AddExistingTab> createState() => _AddExistingTabState();
}

class _AddExistingTabState extends State<_AddExistingTab> {
  final _searchController = TextEditingController();
  List<_Member> _results = [];
  bool _searching = false;
  String? _adding; // profileId being added

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _search(String query) async {
    if (query.trim().length < 2) {
      setState(() => _results = []);
      return;
    }
    setState(() => _searching = true);
    final supabase = serviceLocater<SupabaseClient>();
    final rows = await supabase
        .from('profiles')
        .select('id, name, avatar_url, username')
        .ilike('name', '%${query.trim()}%')
        .limit(10);
    if (!mounted) return;
    setState(() {
      _searching = false;
      _results = rows
          .where((r) => !widget.existingIds.contains(r['id'] as String))
          .map((r) => _Member(
                profileId: r['id'] as String,
                name: r['name'] as String? ?? '',
                avatarUrl: r['avatar_url'] as String?,
                username: r['username'] as String?,
              ))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            autofocus: true,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'Search by name…',
              prefixIcon: Icon(Icons.search, size: 18),
              isDense: true,
            ),
            onChanged: _search,
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _searching
                ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                : _results.isEmpty
                    ? Center(
                        child: Text(
                          _searchController.text.length < 2
                              ? 'Type a name to search'
                              : 'No members found',
                          style: const TextStyle(
                              color: Colors.white38, fontSize: 13),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _results.length,
                        itemBuilder: (context, i) {
                          final m = _results[i];
                          final isAdding = _adding == m.profileId;
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: _Avatar(
                                avatarUrl: m.avatarUrl, name: m.name),
                            title: Text(m.name,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 14)),
                            subtitle: m.username != null
                                ? Text('@${m.username}',
                                    style: const TextStyle(
                                        color: Colors.white38, fontSize: 12))
                                : null,
                            trailing: isAdding
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2))
                                : IconButton(
                                    icon: const Icon(Icons.add_circle,
                                        color: AppPallate.coralColor),
                                    onPressed: () async {
                                      setState(() => _adding = m.profileId);
                                      await widget.onAdd(m);
                                    },
                                  ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

// ── Shared avatar widget ──────────────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  final String? avatarUrl;
  final String name;

  const _Avatar({this.avatarUrl, required this.name});

  @override
  Widget build(BuildContext context) {
    if (avatarUrl != null && avatarUrl!.isNotEmpty) {
      return CircleAvatar(
          radius: 18, backgroundImage: NetworkImage(avatarUrl!));
    }
    return CircleAvatar(
      radius: 18,
      backgroundColor: AppPallate.gradient1,
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: const TextStyle(
            color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
      ),
    );
  }
}
