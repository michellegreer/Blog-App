import 'package:blog_app/Core/Common/Enteties/user_enteties.dart';

class UserModel extends UserEnteties {
  UserModel({
    required super.id,
    required super.email,
    required super.name,
    super.role,
    super.isApproved,
    super.avatarUrl,
    super.bio,
  });

  factory UserModel.fromJson(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? map['raw_user_meta_data']?['name'] ?? '',
      role: map['role'] ?? 'user',
      isApproved: map['is_approved'] ?? false,
      avatarUrl: map['avatar_url'] as String?,
      bio: map['bio'] as String?,
    );
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? role,
    bool? isApproved,
    String? avatarUrl,
    String? bio,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      isApproved: isApproved ?? this.isApproved,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
    );
  }
}
