import 'package:dio/dio.dart';
import '../models/group.dart';
import 'api_client.dart';

class GroupService {
  static final Dio _dio = ApiClient.instance;

  static Future<Group> createGroup(String name) async {
    final response = await _dio.post('/groups', data: {'name': name});
    return Group.fromJson(response.data['group']);
  }

  static Future<Group> joinGroup(String code) async {
    final response = await _dio.post('/groups/join', data: {'code': code});
    return Group.fromJson(response.data['group']);
  }

  static Future<Group> switchActive(String groupId) async {
    final response =
        await _dio.patch('/groups/active', data: {'groupId': groupId});
    return Group.fromJson(response.data);
  }

  static Future<void> leaveGroup(String groupId) async {
    await _dio.post('/groups/$groupId/leave');
  }

  static Future<List<GroupMember>> getGroupMembers(String groupId) async {
    final response = await _dio.get('/groups/$groupId/members');
    return (response.data as List)
        .map((m) => GroupMember.fromJson(m))
        .toList();
  }
}
