import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../models/transaction.dart' as model;
import '../models/category.dart';
import '../utils/clp_formatter.dart';
import '../utils/constants.dart';

class TransactionFormSheet extends StatefulWidget {
  final model.Transaction? transaction;
  final List<Category> categories;
  final Future<void> Function(Map<String, dynamic> data) onSave;

  const TransactionFormSheet({
    super.key,
    this.transaction,
    required this.categories,
    required this.onSave,
  });

  @override
  State<TransactionFormSheet> createState() => _TransactionFormSheetState();
}

class _TransactionFormSheetState extends State<TransactionFormSheet> {
  late String _type;
  late TextEditingController _amountController;
  late TextEditingController _descriptionController;
  late DateTime _date;
  String? _category;
  String? _subcategory;
  String? _source;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final t = widget.transaction;
    _type = t?.type ?? 'gasto';
    _amountController =
        TextEditingController(text: t != null ? t.amount.toString() : '');
    _descriptionController =
        TextEditingController(text: t?.description ?? '');
    _date = t != null ? DateTime.tryParse(t.date) ?? DateTime.now() : DateTime.now();
    _category = t?.category;
    _subcategory = t?.subcategory;
    _source = t?.source;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  List<String> get _subcategories {
    if (_category == null) return [];
    final cat =
        widget.categories.where((c) => c.name == _category).firstOrNull;
    return cat?.subcategories ?? [];
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              surface: AppColors.surface,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _date = picked);
    }
  }

  Future<void> _submit() async {
    final amount = int.tryParse(_amountController.text.replaceAll('.', ''));
    if (amount == null || amount <= 0) return;
    if (_descriptionController.text.trim().isEmpty) return;

    setState(() => _saving = true);

    final data = <String, dynamic>{
      'type': _type,
      'amount': amount,
      'date': _date.toIso8601String(),
      'description': _descriptionController.text.trim(),
    };

    if (_type == 'gasto') {
      if (_category != null) data['category'] = _category;
      if (_subcategory != null) data['subcategory'] = _subcategory;
    } else {
      if (_source != null) data['source'] = _source;
    }

    try {
      await widget.onSave(data);
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateStr =
        '${_date.day.toString().padLeft(2, '0')}/${_date.month.toString().padLeft(2, '0')}/${_date.year}';

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textSecondary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.transaction != null
                  ? 'Editar Transaccion'
                  : 'Nueva Transaccion',
              style:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Type toggle
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() {
                      _type = 'gasto';
                      _source = null;
                    }),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _type == 'gasto'
                            ? AppColors.expense.withValues(alpha: 0.2)
                            : AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _type == 'gasto'
                              ? AppColors.expense
                              : AppColors.border,
                        ),
                      ),
                      child: Center(
                        child: Text('Gasto',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: _type == 'gasto'
                                  ? AppColors.expense
                                  : AppColors.textSecondary,
                            )),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() {
                      _type = 'ingreso';
                      _category = null;
                      _subcategory = null;
                    }),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _type == 'ingreso'
                            ? AppColors.income.withValues(alpha: 0.2)
                            : AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _type == 'ingreso'
                              ? AppColors.income
                              : AppColors.border,
                        ),
                      ),
                      child: Center(
                        child: Text('Ingreso',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: _type == 'ingreso'
                                  ? AppColors.income
                                  : AppColors.textSecondary,
                            )),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Amount
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Monto',
                prefixIcon: const Icon(Icons.attach_money),
                hintText: '0',
                suffixText:
                    _amountController.text.isNotEmpty
                        ? formatCLP(
                            int.tryParse(_amountController.text.replaceAll('.', '')) ?? 0)
                        : null,
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),

            // Date
            GestureDetector(
              onTap: _pickDate,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Fecha',
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                child: Text(dateStr),
              ),
            ),
            const SizedBox(height: 12),

            // Description
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Descripcion',
                prefixIcon: Icon(Icons.description),
              ),
            ),
            const SizedBox(height: 12),

            // Category or Source
            if (_type == 'gasto') ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _category,
                    hint: const Text('Categoria'),
                    isExpanded: true,
                    dropdownColor: AppColors.surface,
                    items: widget.categories
                        .map((c) => DropdownMenuItem(
                            value: c.name, child: Text(c.name)))
                        .toList(),
                    onChanged: (v) => setState(() {
                      _category = v;
                      _subcategory = null;
                    }),
                  ),
                ),
              ),
              if (_subcategories.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _subcategory,
                      hint: const Text('Subcategoria'),
                      isExpanded: true,
                      dropdownColor: AppColors.surface,
                      items: _subcategories
                          .map((s) =>
                              DropdownMenuItem(value: s, child: Text(s)))
                          .toList(),
                      onChanged: (v) => setState(() => _subcategory = v),
                    ),
                  ),
                ),
              ],
            ] else ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _source,
                    hint: const Text('Fuente de ingreso'),
                    isExpanded: true,
                    dropdownColor: AppColors.surface,
                    items: incomeSources
                        .map((s) => DropdownMenuItem(
                            value: s['value'], child: Text(s['label']!)))
                        .toList(),
                    onChanged: (v) => setState(() => _source = v),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 20),

            // Submit
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _submit,
                child: _saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : Text(widget.transaction != null ? 'Guardar' : 'Crear'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
