class MonthlyHistory {
  final String month;
  final int year;
  final num ingresos;
  final num gastos;

  MonthlyHistory({
    required this.month,
    required this.year,
    required this.ingresos,
    required this.gastos,
  });

  factory MonthlyHistory.fromJson(Map<String, dynamic> json) {
    return MonthlyHistory(
      month: json['month'] ?? '',
      year: json['year'] ?? 0,
      ingresos: json['ingresos'] ?? 0,
      gastos: json['gastos'] ?? 0,
    );
  }
}
