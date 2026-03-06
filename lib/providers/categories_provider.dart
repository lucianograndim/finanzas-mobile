import 'package:flutter/material.dart';
import '../models/category.dart';
import '../services/category_service.dart';

class CategoriesProvider extends ChangeNotifier {
  List<Category> _categories = [];
  bool _loading = false;

  List<Category> get categories => _categories;
  bool get loading => _loading;

  Future<void> load() async {
    _loading = true;
    notifyListeners();

    try {
      _categories = await CategoryService.getCategories();
    } catch (_) {}

    _loading = false;
    notifyListeners();
  }

  Future<void> createCategory(String name) async {
    await CategoryService.createCategory(name);
    await load();
  }

  Future<void> renameCategory(String id, String name) async {
    await CategoryService.updateCategory(id, {'name': name});
    await load();
  }

  Future<void> deleteCategory(String id) async {
    await CategoryService.deleteCategory(id);
    await load();
  }

  Future<void> addSubcategory(String id, Category category, String sub) async {
    final updated = [...category.subcategories, sub];
    await CategoryService.updateCategory(id, {'subcategories': updated});
    await load();
  }

  Future<void> removeSubcategory(
      String id, Category category, String sub) async {
    final updated =
        category.subcategories.where((s) => s != sub).toList();
    await CategoryService.updateCategory(id, {'subcategories': updated});
    await load();
  }
}
