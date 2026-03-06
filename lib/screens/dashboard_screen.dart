import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/dashboard_provider.dart';
import '../utils/clp_formatter.dart';
import '../widgets/period_selector.dart';
import '../widgets/summary_card.dart';
import '../widgets/pie_chart_widget.dart';
import '../widgets/bar_chart_widget.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      context.read<DashboardProvider>().loadAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardProvider>(
      builder: (context, provider, _) {
        if (provider.loading && provider.balance == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: provider.loadAll,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Balance acumulado
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: (provider.balance?.saldo ?? 0) >= 0
                        ? [const Color(0xFF065F46), const Color(0xFF064E3B)]
                        : [const Color(0xFF7F1D1D), const Color(0xFF991B1B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.account_balance_wallet,
                            size: 18,
                            color: Colors.white.withValues(alpha: 0.7)),
                        const SizedBox(width: 8),
                        Text('Balance Acumulado',
                            style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withValues(alpha: 0.7))),
                      ],
                    ),
                    const SizedBox(height: 12),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        formatCLP(provider.balance?.saldo ?? 0),
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Selector de periodo
              PeriodSelector(
                month: provider.month,
                year: provider.year,
                onChanged: (m, y) => provider.changePeriod(m, y),
              ),
              const SizedBox(height: 12),

              // Resumen del periodo
              if (provider.summary != null) ...[
                Row(
                  children: [
                    Expanded(
                      child: SummaryCard(
                        label: 'Ingresos',
                        amount: provider.summary!.totalIngresos,
                        color: AppColors.income,
                        icon: Icons.trending_up,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SummaryCard(
                        label: 'Gastos',
                        amount: provider.summary!.totalGastos,
                        color: AppColors.expense,
                        icon: Icons.trending_down,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SummaryCard(
                  label: 'Balance del Periodo',
                  amount: provider.summary!.saldo,
                  color: provider.summary!.saldo >= 0
                      ? AppColors.income
                      : AppColors.expense,
                  icon: Icons.account_balance_wallet,
                ),
                const SizedBox(height: 16),

                // Pie chart
                PieChartWidget(data: provider.summary!.gastosPorCategoria),
              ],
              const SizedBox(height: 16),

              // Bar chart
              BarChartWidget(data: provider.history),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}
