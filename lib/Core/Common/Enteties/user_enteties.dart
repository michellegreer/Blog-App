class UserEnteties {
  final String id;
  final String email;
  final String name;
  final bool isAdmin;
  final String? username;
  final String? phone;
  final String? avatarUrl;
  final String? bio;

  UserEnteties({
    required this.id,
    required this.email,
    required this.name,
    this.isAdmin = false,
    this.username,
    this.phone,
    this.avatarUrl,
    this.bio,
  });
}
