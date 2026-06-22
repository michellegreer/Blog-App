import 'package:blog_app/Core/Common/Enteties/user_enteties.dart';

class UserModel extends UserEnteties {
  UserModel({
    required super.id,
    required super.email,
    required super.name,
    super.isAdmin,
    super.username,
    super.phone,
    super.avatarUrl,
    super.bio,
  });

  factory UserModel.fromJson(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? map['raw_user_meta_data']?['name'] ?? '',
      isAdmin: map['is_admin'] as bool? ?? false,
      username: map['username'] as String?,
      phone: map['phone'] as String?,
      avatarUrl: map['avatar_url'] as String?,
      bio: map['bio'] as String?,
    );
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    bool? isAdmin,
    String? username,
    String? phone,
    String? avatarUrl,
    String? bio,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      isAdmin: isAdmin ?? this.isAdmin,
      username: username ?? this.username,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
    );
  }
}
