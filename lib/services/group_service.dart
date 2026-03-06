import 'package:dio/dio.dart';
import '../models/group.dart';
import 'api_client.dart';

class GroupService {
  static final Dio _dio = ApiClient.instance;

  static Future<({String token, Group group})> createGroup(String name) async {
    final response = await _dio.post('/groups', data: {'name': name});
    return (
      token: response.data['access_token'] as String,
      group: Group.fromJson(response.data['group']),
    );
  }

  static Future<({String token, Group group})> joinGroup(String code) async {
    final response = await _dio.post('/groups/join', data: {'code': code});
    return (
      token: response.data['access_token'] as String,
      group: Group.fromJson(response.data['group']),
    );
  }

  static Future<Group?> getMyGroup() async {
    final response = await _dio.get('/groups/mine');
    if (response.data == null) return null;
    return Group.fromJson(response.data);
  }
}
