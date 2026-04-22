import 'package:financial_architect/models/category.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/index.dart';
import '../widgets/index.dart';
import '../theme/index.dart';

/// Analytics/Chart screen
class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({Key? key}) : super(key: key);

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  String _selectedPeriod = 'MONTH';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeProvider>().loadHomeData();
      context.read<TransactionProvider>().loadTransactions();
      context.read<CategoryProvider>().loadCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: FinancialArchitectAppBar(
        title: 'Analytics Dashboard',
        showBackButton: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Period Selector
            _PeriodSelector(
              selectedPeriod: _selectedPeriod,
              onPeriodChanged: (period) =>
                  setState(() => _selectedPeriod = period),
            ),
            const SizedBox(height: 24),

            // Summary Cards
            Consumer<HomeProvider>(
              builder: (context, homeProvider, _) {
                return Row(
                  children: [
                    Expanded(
                      child: _AnalyticsCard(
                        title: 'Income',
                        amount: homeProvider.monthlyIncome.toStringAsFixed(2),
                        icon: Icons.trending_up,
                        color: AppColors.success,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _AnalyticsCard(
                        title: 'Expenses',
                        amount: homeProvider.monthlyExpense.toStringAsFixed(2),
                        icon: Icons.trending_down,
                        color: AppColors.error,
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),

            // Net Balance Card
            Consumer<HomeProvider>(
              builder: (context, homeProvider, _) {
                return PulseCard(
                  title: 'Monthly Balance',
                  amount: homeProvider.monthlyBalance.abs().toStringAsFixed(2),
                  currency: 'EGP',
                  backgroundColor: homeProvider.monthlyBalance >= 0
                      ? AppColors.success
                      : AppColors.error,
                );
              },
            ),
            const SizedBox(height: 24),

            // Category Breakdown Title
            Text(
              'Spending by Category',
              style: AppTextStyles.headlineSmall.copyWith(
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 12),

            // Category Breakdown List
            Consumer2<TransactionProvider, CategoryProvider>(
              builder: (context, transactionProvider, categoryProvider, _) {
                return FutureBuilder<Map<int, double>>(
                  future: () async {
                    final now = DateTime.now();
                    final monthStart = DateTime(now.year, now.month, 1);
                    final monthEnd = monthStart
                        .add(const Duration(days: 32))
                        .copyWith(day: 1);
                    return await transactionProvider.getSpendingByCategory(
                      monthStart,
                      monthEnd,
                    );
                  }(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                        child: Text(
                          'No spending data',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      );
                    }

                    final spendingData = snapshot.data!;
                    return Column(
                      children: spendingData.entries.map((entry) {
                        final category = categoryProvider.allCategories
                            .where((CategoryModel cat) => cat.id == entry.key)
                            .firstOrNull;

                        if (category == null) return const SizedBox.shrink();

                        return Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLowest,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.account_balance,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      category.nameEn,
                                      style: AppTextStyles.titleSmall.copyWith(
                                        color: AppColors.onSurface,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: LinearProgressIndicator(
                                        minHeight: 4,
                                        value: (entry.value / 10000).clamp(
                                          0,
                                          1,
                                        ),
                                        backgroundColor:
                                            AppColors.surfaceContainerLow,
                                        valueColor: AlwaysStoppedAnimation(
                                          Color(
                                            int.parse(
                                              '0xFF${category.colorHex?.replaceAll('#', '') ?? '1A237E'}',
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                '${entry.value.toStringAsFixed(0)} EGP',
                                style: AppTextStyles.titleSmall.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Period selector widget
class _PeriodSelector extends StatelessWidget {
  final String selectedPeriod;
  final ValueChanged<String> onPeriodChanged;

  const _PeriodSelector({
    required this.selectedPeriod,
    required this.onPeriodChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _PeriodButton(
            label: 'Day',
            isSelected: selectedPeriod == 'DAY',
            onTap: () => onPeriodChanged('DAY'),
          ),
          _PeriodButton(
            label: 'Month',
            isSelected: selectedPeriod == 'MONTH',
            onTap: () => onPeriodChanged('MONTH'),
          ),
          _PeriodButton(
            label: 'Year',
            isSelected: selectedPeriod == 'YEAR',
            onTap: () => onPeriodChanged('YEAR'),
          ),
        ],
      ),
    );
  }
}

class _PeriodButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _PeriodButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AppTextStyles.labelMedium.copyWith(
              color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

/// Analytics card widget
class _AnalyticsCard extends StatelessWidget {
  final String title;
  final String amount;
  final IconData icon;
  final Color color;

  const _AnalyticsCard({
    required this.title,
    required this.amount,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            amount,
            style: AppTextStyles.headlineSmall.copyWith(color: color),
          ),
          Text(
            'EGP',
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
