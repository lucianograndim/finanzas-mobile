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
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      ownerId: json['ownerId'] ?? '',
      members: json['members'] != null
          ? (json['members'] as List)
              .map((m) => GroupMember.fromJson(m))
              .toList()
          : null,
    );
  }
}

class GroupMember {
  final String name;
  final String email;

  GroupMember({required this.name, required this.email});

  factory GroupMember.fromJson(Map<String, dynamic> json) {
    return GroupMember(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
    );
  }
}
