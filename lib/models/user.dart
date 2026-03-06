class User {
  final String name;
  final String email;
  final String? groupId;
  final String? groupName;
  final String? groupCode;

  User({
    required this.name,
    required this.email,
    this.groupId,
    this.groupName,
    this.groupCode,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      groupId: json['groupId'],
      groupName: json['groupName'],
      groupCode: json['groupCode'],
    );
  }

  bool get hasGroup => groupId != null && groupId!.isNotEmpty;
}
