class UserModel {
  final int? userId;
  final String name;
  final String email;
  final String rol;
  final String? code;

  UserModel({this.userId, required this.name, required this.email, required this.rol, this.code});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['user_id'] ?? json['id'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      rol: json['rol'] ?? json['role'] ?? 'hijo',
      code: json['code'] ?? json['codigo'] ?? json['code']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'name': name,
        'email': email,
        'rol': rol,
        'code': code,
      };
}
