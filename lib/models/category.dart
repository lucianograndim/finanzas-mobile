class Category {
  final String id;
  final String name;
  final List<String> subcategories;
  final int order;

  Category({
    required this.id,
    required this.name,
    required this.subcategories,
    required this.order,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      subcategories: json['subcategories'] != null
          ? List<String>.from(json['subcategories'])
          : [],
      order: json['order'] ?? 0,
    );
  }
}
