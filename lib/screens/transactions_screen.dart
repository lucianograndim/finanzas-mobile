import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/transactions_provider.dart';
import '../widgets/period_selector.dart';
import '../widgets/transaction_card.dart';
import '../widgets/transaction_form_sheet.dart';
import '../models/transaction.dart' as model;

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      context.read<TransactionsProvider>().load();
    });
  }

  void _showForm({model.Transaction? transaction}) {
    final provider = context.read<TransactionsProvider>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TransactionFormSheet(
        transaction: transaction,
        categories: provider.categories,
        onSave: (data) async {
          if (transaction != null) {
            await provider.updateTransaction(transaction.id, data);
          } else {
            await provider.createTransaction(data);
          }
        },
      ),
    );
  }

  void _confirmDelete(model.Transaction transaction) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Eliminar transaccion'),
        content:
            Text('Eliminar "${transaction.description}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context
                  .read<TransactionsProvider>()
                  .deleteTransaction(transaction.id);
            },
            child: const Text('Eliminar',
                style: TextStyle(color: AppColors.expense)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionsProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Column(
                  children: [
                    PeriodSelector(
                      month: provider.month,
                      year: provider.year,
                      onChanged: (m, y) =>
                          provider.setFilters(month: m, year: y),
                    ),
                    const SizedBox(height: 8),
                    // Type filter
                    Row(
                      children: [
                        _FilterChip(
                          label: 'Todos',
                          selected: provider.typeFilter == null,
                          onTap: () => provider.setFilters(type: ''),
                        ),
                        const SizedBox(width: 8),
                        _FilterChip(
                          label: 'Gastos',
                          selected: provider.typeFilter == 'gasto',
                          onTap: () =>
                              provider.setFilters(type: 'gasto'),
                          color: AppColors.expense,
                        ),
                        const SizedBox(width: 8),
                        _FilterChip(
                          label: 'Ingresos',
                          selected: provider.typeFilter == 'ingreso',
                          onTap: () =>
                              provider.setFilters(type: 'ingreso'),
                          color: AppColors.income,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: provider.loading && provider.transactions.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : provider.transactions.isEmpty
                        ? const Center(
                            child: Text('No hay transacciones para este periodo',
                                style: TextStyle(
                                    color: AppColors.textSecondary)))
                        : RefreshIndicator(
                            onRefresh: provider.load,
                            child: ListView.builder(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: provider.transactions.length,
                              itemBuilder: (_, i) {
                                final t = provider.transactions[i];
                                return TransactionCard(
                                  transaction: t,
                                  onEdit: () => _showForm(transaction: t),
                                  onDelete: () => _confirmDelete(t),
                                );
                              },
                            ),
                          ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showForm(),
            backgroundColor: AppColors.primary,
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color? color;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = color ?? AppColors.primary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? activeColor.withValues(alpha: 0.2)
              : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? activeColor : AppColors.border,
          ),
        ),
        child: Text(label,
            style: TextStyle(
              fontSize: 13,
              color: selected ? activeColor : AppColors.textSecondary,
            )),
      ),
    );
  }
}
