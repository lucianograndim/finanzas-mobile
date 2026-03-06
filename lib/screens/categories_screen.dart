import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/categories_provider.dart';
import '../widgets/category_tile.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      context.read<CategoriesProvider>().load();
    });
  }

  Future<void> _create() async {
    if (_nameController.text.trim().isEmpty) return;
    await context
        .read<CategoriesProvider>()
        .createCategory(_nameController.text.trim());
    _nameController.clear();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CategoriesProvider>(
      builder: (context, provider, _) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        hintText: 'Nueva categoria',
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                      ),
                      onSubmitted: (_) => _create(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _create,
                    child: const Text('Agregar'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: provider.loading && provider.categories.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : provider.categories.isEmpty
                      ? const Center(
                          child: Text('No hay categorias',
                              style: TextStyle(
                                  color: AppColors.textSecondary)))
                      : RefreshIndicator(
                          onRefresh: provider.load,
                          child: ListView.builder(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: provider.categories.length,
                            itemBuilder: (_, i) {
                              final cat = provider.categories[i];
                              return CategoryTile(
                                category: cat,
                                onRename: (name) =>
                                    provider.renameCategory(cat.id, name),
                                onDelete: () =>
                                    provider.deleteCategory(cat.id),
                                onAddSub: (sub) =>
                                    provider.addSubcategory(cat.id, cat, sub),
                                onRemoveSub: (sub) => provider
                                    .removeSubcategory(cat.id, cat, sub),
                              );
                            },
                          ),
                        ),
            ),
          ],
        );
      },
    );
  }
}
