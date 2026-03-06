import 'package:dio/dio.dart';
import '../models/category.dart';
import 'api_client.dart';

class CategoryService {
  static final Dio _dio = ApiClient.instance;

  static Future<List<Category>> getCategories() async {
    final response = await _dio.get('/categories');
    return (response.data as List)
        .map((c) => Category.fromJson(c))
        .toList();
  }

  static Future<Category> createCategory(String name) async {
    final response = await _dio.post('/categories', data: {'name': name});
    return Category.fromJson(response.data);
  }

  static Future<Category> updateCategory(
      String id, Map<String, dynamic> data) async {
    final response = await _dio.patch('/categories/$id', data: data);
    return Category.fromJson(response.data);
  }

  static Future<void> deleteCategory(String id) async {
    await _dio.delete('/categories/$id');
  }
}
