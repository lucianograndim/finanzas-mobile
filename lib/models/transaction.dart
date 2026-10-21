class Transaction {
  final String id;
  final String type;
  final num amount;
  final String date;
  final String description;
  final String? category;
  final String? subcategory;
  final String? source;
  final TransactionCreator? createdBy;
  final String? createdAt;

  Transaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.date,
    required this.description,
    this.category,
    this.subcategory,
    this.source,
    this.createdBy,
    this.createdAt,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['_id'] ?? '',
      type: json['type'] ?? '',
      amount: json['amount'] ?? 0,
      date: json['date'] ?? '',
      description: json['description'] ?? '',
      category: json['category'],
      subcategory: json['subcategory'],
      source: json['source'],
      createdBy: json['createdBy'] is Map
          ? TransactionCreator.fromJson(json['createdBy'])
          : json['createdBy'] is String
              ? TransactionCreator(id: '', name: json['createdBy'])
              : null,
      createdAt: json['createdAt'],
    );
  }

  bool get isIncome => type == 'ingreso';
  bool get isExpense => type == 'gasto';
}

class TransactionCreator {
  final String id;
  final String name;

  TransactionCreator({required this.id, required this.name});

  factory TransactionCreator.fromJson(Map<String, dynamic> json) {
    return TransactionCreator(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
    );
  }
}
