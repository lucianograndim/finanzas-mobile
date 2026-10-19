class GroupInfo {
  final String id;
  final String name;
  final String code;
  final String role;
  final bool isActive;

  GroupInfo({
    required this.id,
    required this.name,
    required this.code,
    required this.role,
    required this.isActive,
  });

  factory GroupInfo.fromJson(Map<String, dynamic> json) {
    return GroupInfo(
      id: json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      role: json['role']?.toString() ?? 'member',
      isActive: json['isActive'] == true,
    );
  }
}

class User {
  final String name;
  final String email;
  final String? activeGroupId;
  final String? activeGroupName;
  final List<GroupInfo> groups;

  User({
    required this.name,
    required this.email,
    this.activeGroupId,
    this.activeGroupName,
    this.groups = const [],
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      activeGroupId: json['activeGroupId']?.toString(),
      activeGroupName: json['activeGroupName']?.toString(),
      groups: json['groups'] is List
          ? (json['groups'] as List)
              .whereType<Map<String, dynamic>>()
              .map((g) => GroupInfo.fromJson(g))
              .toList()
          : [],
    );
  }

  bool get hasGroup =>
      activeGroupId != null && activeGroupId!.isNotEmpty;

  GroupInfo? get activeGroup {
    try {
      return groups.firstWhere((g) => g.isActive);
    } catch (_) {
      return null;
    }
  }
}
