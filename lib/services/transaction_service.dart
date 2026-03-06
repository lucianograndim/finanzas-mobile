import 'package:dio/dio.dart';
import '../models/transaction.dart';
import '../models/summary.dart';
import '../models/monthly_history.dart';
import 'api_client.dart';

class TransactionService {
  static final Dio _dio = ApiClient.instance;

  static Future<List<Transaction>> getTransactions({
    String? month,
    String? year,
    String? type,
  }) async {
    final params = <String, dynamic>{};
    if (month != null) params['month'] = month;
    if (year != null) params['year'] = year;
    if (type != null && type.isNotEmpty) params['type'] = type;

    final response =
        await _dio.get('/transactions', queryParameters: params);
    return (response.data as List)
        .map((t) => Transaction.fromJson(t))
        .toList();
  }

  static Future<Transaction> createTransaction(
      Map<String, dynamic> data) async {
    final response = await _dio.post('/transactions', data: data);
    return Transaction.fromJson(response.data);
  }

  static Future<Transaction> updateTransaction(
      String id, Map<String, dynamic> data) async {
    final response = await _dio.patch('/transactions/$id', data: data);
    return Transaction.fromJson(response.data);
  }

  static Future<void> deleteTransaction(String id) async {
    await _dio.delete('/transactions/$id');
  }

  static Future<Summary> getSummary(String month, String year) async {
    final response = await _dio.get('/transactions/summary',
        queryParameters: {'month': month, 'year': year});
    return Summary.fromJson(response.data);
  }

  static Future<Balance> getBalance() async {
    final response = await _dio.get('/transactions/balance');
    return Balance.fromJson(response.data);
  }

  static Future<List<MonthlyHistory>> getHistory() async {
    final response = await _dio.get('/transactions/history');
    return (response.data as List)
        .map((h) => MonthlyHistory.fromJson(h))
        .toList();
  }
}
