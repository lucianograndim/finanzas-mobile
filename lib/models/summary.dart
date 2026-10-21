class Summary {
  final num totalIngresos;
  final num totalGastos;
  final num saldo;
  final Map<String, num> gastosPorCategoria;
  final Map<String, num> ingresosPorSource;

  Summary({
    required this.totalIngresos,
    required this.totalGastos,
    required this.saldo,
    required this.gastosPorCategoria,
    required this.ingresosPorSource,
  });

  factory Summary.fromJson(Map<String, dynamic> json) {
    return Summary(
      totalIngresos: json['totalIngresos'] ?? 0,
      totalGastos: json['totalGastos'] ?? 0,
      saldo: json['saldo'] ?? 0,
      gastosPorCategoria: json['gastosPorCategoria'] != null
          ? Map<String, num>.from(json['gastosPorCategoria'])
          : {},
      ingresosPorSource: json['ingresosPorSource'] != null
          ? Map<String, num>.from(json['ingresosPorSource'])
          : {},
    );
  }
}

class Balance {
  final num totalIngresos;
  final num totalGastos;
  final num saldo;

  Balance({
    required this.totalIngresos,
    required this.totalGastos,
    required this.saldo,
  });

  factory Balance.fromJson(Map<String, dynamic> json) {
    return Balance(
      totalIngresos: json['totalIngresos'] ?? 0,
      totalGastos: json['totalGastos'] ?? 0,
      saldo: json['saldo'] ?? 0,
    );
  }
}
