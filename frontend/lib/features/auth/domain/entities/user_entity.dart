class UserEntity {
  final String id;
  final String name;
  final String email;
  final String? role;
  final String? token;

  UserEntity({
    required this.id,
    required this.name,
    required this.email,
    this.role,
    this.token,
  });

  UserEntity copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    String? token,
  }) {
    return UserEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      token: token ?? this.token,
    );
  }
}