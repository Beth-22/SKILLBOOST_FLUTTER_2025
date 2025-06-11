import 'package:skill_boost/features/auth/domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  final String? token;
  UserModel({
    required String id,
    required String name,
    required String email,
    String? role,
    this.token,
  }) : super(id: id, name: name, email: email, role: role, token: token);

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['_id'] ?? json['id'] ?? '',
    name: json['name'] ?? '',
    email: json['email'] ?? '',
    role: json['role'] ?? '',
    token: json['accessToken'] ?? '',
  );

  @override
  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    String? token,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      token: token ?? this.token,
    );
  }
}
