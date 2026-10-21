import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../models/category.dart';

class CategoryTile extends StatefulWidget {
  final Category category;
  final Future<void> Function(String name) onRename;
  final Future<void> Function() onDelete;
  final Future<void> Function(String sub) onAddSub;
  final Future<void> Function(String sub) onRemoveSub;

  const CategoryTile({
    super.key,
    required this.category,
    required this.onRename,
    required this.onDelete,
    required this.onAddSub,
    required this.onRemoveSub,
  });

  @override
  State<CategoryTile> createState() => _CategoryTileState();
}

class _CategoryTileState extends State<CategoryTile> {
  bool _editing = false;
  final _editController = TextEditingController();
  final _subController = TextEditingController();

  @override
  void dispose() {
    _editController.dispose();
    _subController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            if (_editing) ...[
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _editController,
                      autofocus: true,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      if (_editController.text.trim().isNotEmpty) {
                        await widget.onRename(_editController.text.trim());
                      }
                      setState(() => _editing = false);
                    },
                    child: const Text('Guardar'),
                  ),
                  TextButton(
                    onPressed: () => setState(() => _editing = false),
                    child: const Text('Cancelar',
                        style: TextStyle(color: AppColors.textSecondary)),
                  ),
                ],
              ),
            ] else ...[
              Row(
                children: [
                  Expanded(
                    child: Text(widget.category.name,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                  GestureDetector(
                    onTap: () {
                      _editController.text = widget.category.name;
                      setState(() => _editing = true);
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Text('Renombrar',
                          style: TextStyle(
                              fontSize: 12, color: AppColors.primaryLight)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          backgroundColor: AppColors.surface,
                          title: const Text('Eliminar categoria'),
                          content: Text(
                              'Eliminar "${widget.category.name}"?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('Cancelar'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(ctx);
                                widget.onDelete();
                              },
                              child: const Text('Eliminar',
                                  style:
                                      TextStyle(color: AppColors.expense)),
                            ),
                          ],
                        ),
                      );
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Text('Eliminar',
                          style: TextStyle(
                              fontSize: 12, color: AppColors.expense)),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 10),

            // Subcategories
            if (widget.category.subcategories.isEmpty)
              const Text('Sin subcategorias',
                  style: TextStyle(
                      fontSize: 12, color: AppColors.textSecondary))
            else
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: widget.category.subcategories.map((sub) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(sub, style: const TextStyle(fontSize: 12)),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () => widget.onRemoveSub(sub),
                          child: const Icon(Icons.close,
                              size: 14, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            const SizedBox(height: 10),

            // Add subcategory
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _subController,
                    decoration: const InputDecoration(
                      hintText: 'Nueva subcategoria',
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      isDense: true,
                    ),
                    onSubmitted: (_) async {
                      if (_subController.text.trim().isNotEmpty) {
                        await widget.onAddSub(_subController.text.trim());
                        _subController.clear();
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () async {
                    if (_subController.text.trim().isNotEmpty) {
                      await widget.onAddSub(_subController.text.trim());
                      _subController.clear();
                    }
                  },
                  child: const Text('Agregar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
