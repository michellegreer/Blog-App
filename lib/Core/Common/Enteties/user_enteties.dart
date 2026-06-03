class UserEnteties {
  final String id;
  final String email;
  final String name;
  final String role;
  final bool isApproved;
  final String? avatarUrl;
  final String? bio;

  UserEnteties({
    required this.id,
    required this.email,
    required this.name,
    this.role = 'user',
    this.isApproved = false,
    this.avatarUrl,
    this.bio,
  });

  bool get isAdmin => role == 'admin' || email == 'michelle@michellesblog.net';
}
