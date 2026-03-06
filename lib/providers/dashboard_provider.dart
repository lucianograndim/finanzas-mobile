import 'package:flutter/material.dart';
import '../models/summary.dart';
import '../models/monthly_history.dart';
import '../services/transaction_service.dart';

class DashboardProvider extends ChangeNotifier {
  Balance? _balance;
  Summary? _summary;
  List<MonthlyHistory> _history = [];
  bool _loading = false;
  int _month = DateTime.now().month;
  int _year = DateTime.now().year;

  Balance? get balance => _balance;
  Summary? get summary => _summary;
  List<MonthlyHistory> get history => _history;
  bool get loading => _loading;
  int get month => _month;
  int get year => _year;

  Future<void> loadAll() async {
    _loading = true;
    notifyListeners();

    try {
      final results = await Future.wait([
        TransactionService.getBalance(),
        TransactionService.getSummary(_month.toString(), _year.toString()),
        TransactionService.getHistory(),
      ]);
      _balance = results[0] as Balance;
      _summary = results[1] as Summary;
      _history = results[2] as List<MonthlyHistory>;
    } catch (_) {}

    _loading = false;
    notifyListeners();
  }

  Future<void> changePeriod(int month, int year) async {
    _month = month;
    _year = year;
    notifyListeners();

    try {
      _summary = await TransactionService.getSummary(
          month.toString(), year.toString());
    } catch (_) {}

    notifyListeners();
  }
}
