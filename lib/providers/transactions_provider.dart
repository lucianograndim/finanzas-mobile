import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../models/category.dart';
import '../services/transaction_service.dart';
import '../services/category_service.dart';

class TransactionsProvider extends ChangeNotifier {
  List<Transaction> _transactions = [];
  List<Category> _categories = [];
  bool _loading = false;
  int _month = DateTime.now().month;
  int _year = DateTime.now().year;
  String? _typeFilter;

  List<Transaction> get transactions => _transactions;
  List<Category> get categories => _categories;
  bool get loading => _loading;
  int get month => _month;
  int get year => _year;
  String? get typeFilter => _typeFilter;

  Future<void> load() async {
    _loading = true;
    notifyListeners();

    try {
      final results = await Future.wait([
        TransactionService.getTransactions(
          month: _month.toString(),
          year: _year.toString(),
          type: _typeFilter,
        ),
        CategoryService.getCategories(),
      ]);
      _transactions = results[0] as List<Transaction>;
      _categories = results[1] as List<Category>;
    } catch (_) {}

    _loading = false;
    notifyListeners();
  }

  void setFilters({int? month, int? year, String? type}) {
    if (month != null) _month = month;
    if (year != null) _year = year;
    _typeFilter = type;
    load();
  }

  Future<void> createTransaction(Map<String, dynamic> data) async {
    await TransactionService.createTransaction(data);
    await load();
  }

  Future<void> updateTransaction(
      String id, Map<String, dynamic> data) async {
    await TransactionService.updateTransaction(id, data);
    await load();
  }

  Future<void> deleteTransaction(String id) async {
    await TransactionService.deleteTransaction(id);
    await load();
  }
}
