class Group {
  final String id;
  final String name;
  final String code;
  final String ownerId;
  final List<GroupMember>? members;

  Group({
    required this.id,
    required this.name,
    required this.code,
    required this.ownerId,
    this.members,
  });

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      id: json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      ownerId: json['ownerId']?.toString() ?? '',
      members: json['members'] is List
          ? (json['members'] as List)
              .whereType<Map<String, dynamic>>()
              .map((m) => GroupMember.fromJson(m))
              .toList()
          : null,
    );
  }
}

class GroupMember {
  final String name;
  final String email;
  final String? role;

  GroupMember({required this.name, required this.email, this.role});

  factory GroupMember.fromJson(Map<String, dynamic> json) {
    return GroupMember(
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      role: json['role']?.toString(),
    );
  }
}
