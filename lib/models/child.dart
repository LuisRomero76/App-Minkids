class ChildModel {
  final int userId;
  final String name;
  final String email;
  final String? code;

  ChildModel({
    required this.userId,
    required this.name,
    required this.email,
    this.code,
  });

  factory ChildModel.fromJson(Map<String, dynamic> json) {
    final child = json['child'] ?? json;
    return ChildModel(
      userId: child['user_id'] ?? child['id'] ?? 0,
      name: child['name'] ?? '',
      email: child['email'] ?? '',
      code: child['code']?.toString(),
    );
  }
}
