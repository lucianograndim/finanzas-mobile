import 'package:dio/dio.dart';
import '../config/api_config.dart';
import 'storage_service.dart';

class ApiClient {
  static final Dio _dio = Dio(BaseOptions(
    baseUrl: ApiConfig.baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  static Function? onUnauthorized;

  static Dio get instance => _dio;

  static void init({Function? onUnauthorizedCallback}) {
    onUnauthorized = onUnauthorizedCallback;

    _dio.interceptors.clear();
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await StorageService.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        final groupId = await StorageService.getActiveGroupId();
        if (groupId != null) {
          options.headers['X-Group-Id'] = groupId;
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          await StorageService.deleteToken();
          onUnauthorized?.call();
        }
        handler.next(error);
      },
    ));
  }
}
