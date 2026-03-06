import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../models/transaction.dart';
import '../utils/clp_formatter.dart';
import '../utils/constants.dart';

class TransactionCard extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TransactionCard({
    super.key,
    required this.transaction,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.isIncome;
    final color = isIncome ? AppColors.income : AppColors.expense;
    final sign = isIncome ? '+' : '-';

    String dateStr = '';
    try {
      final dt = DateTime.parse(transaction.date);
      dateStr =
          '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
    } catch (_) {
      dateStr = transaction.date;
    }

    final subtitle = isIncome
        ? getSourceLabel(transaction.source)
        : [transaction.category, transaction.subcategory]
            .where((s) => s != null && s.isNotEmpty)
            .join(' > ');

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(transaction.description,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 15)),
                ),
                Text(
                  '$sign${formatCLP(transaction.amount)}',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15, color: color),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    isIncome ? 'Ingreso' : 'Gasto',
                    style: TextStyle(fontSize: 11, color: color),
                  ),
                ),
                const SizedBox(width: 8),
                if (subtitle.isNotEmpty)
                  Expanded(
                    child: Text(subtitle,
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textSecondary),
                        overflow: TextOverflow.ellipsis),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Text(dateStr,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary)),
                if (transaction.createdBy != null) ...[
                  const SizedBox(width: 8),
                  Text('por ${transaction.createdBy!.name}',
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textSecondary)),
                ],
                const Spacer(),
                GestureDetector(
                  onTap: onEdit,
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Text('Editar',
                        style: TextStyle(
                            fontSize: 12, color: AppColors.primaryLight)),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: onDelete,
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Text('Eliminar',
                        style:
                            TextStyle(fontSize: 12, color: AppColors.expense)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
