import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/index.dart';
import '../providers/index.dart';
import '../widgets/index.dart';
import '../theme/index.dart';
import '../localization/index.dart';

/// History/Transaction list screen
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _filterType = 'ALL';
  late DateTime _startDate;
  late DateTime _endDate;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _startDate = DateTime(now.year, now.month, 1);
    _endDate = now;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransactionProvider>().loadTransactions();
      context.read<CategoryProvider>().loadCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LocalizationProvider>(
      builder: (context, localization, _) => Scaffold(
        backgroundColor: AppColors.surface,
        appBar: FinancialArchitectAppBar(
          title: localization.translate('transaction_history'),
          showBackButton: false,
        ),
        body: Column(
          children: [
            // Filter Tabs
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  _FilterTab(
                    label: localization.translate('all'),
                    isSelected: _filterType == 'ALL',
                    onTap: () => setState(() => _filterType = 'ALL'),
                  ),
                  const SizedBox(width: 8),
                  _FilterTab(
                    label: localization.translate('income'),
                    isSelected: _filterType == 'INCOME',
                    onTap: () => setState(() => _filterType = 'INCOME'),
                  ),
                  const SizedBox(width: 8),
                  _FilterTab(
                    label: localization.translate('expense'),
                    isSelected: _filterType == 'EXPENSE',
                    onTap: () => setState(() => _filterType = 'EXPENSE'),
                  ),
                ],
              ),
            ),

            // Date Range Filter
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                Expanded(
                  child: GestureDetector(
                onTap: () => _selectDateRange(context, localization),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_startDate.day}/${_startDate.month} - ${_endDate.day}/${_endDate.month}',
                        style: AppTextStyles.bodySmall,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Transaction List
          Expanded(
            child: Consumer2<TransactionProvider, CategoryProvider>(
              builder: (context, transactionProvider, categoryProvider, _) {
                List<TransactionModel> filteredTransactions;

                if (_filterType == 'ALL') {
                  filteredTransactions = transactionProvider.allTransactions;
                } else {
                  filteredTransactions = _filterType == 'INCOME'
                      ? transactionProvider.incomeTransactions
                      : transactionProvider.expenseTransactions;
                }

                // Filter by date range
                filteredTransactions = filteredTransactions
                    .where(
                      (t) =>
                          t.date.isAfter(_startDate) &&
                          t.date.isBefore(
                            _endDate.add(const Duration(days: 1)),
                          ),
                    )
                    .toList();

                if (filteredTransactions.isEmpty) {
                  return Center(
                    child: Consumer<LocalizationProvider>(
                      builder: (context, localization, _) => Text(
                        localization.translate('no_transactions_found'),
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  itemCount: filteredTransactions.length,
                  itemBuilder: (context, index) {
                    final transaction = filteredTransactions[index];
                    final category = categoryProvider.allCategories.firstWhere(
                      (cat) => cat.id == transaction.categoryId,
                      orElse: () => CategoryModel(
                        id: 0,
                        nameAr: 'Unknown',
                        nameEn: 'Unknown',
                        type: 'EXPENSE',
                      ),
                    );

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: ExpandableTransactionTile(
                        transaction: transaction,
                        category: category,
                        onEdit: () => _editTransaction(context, transaction),
                        onDelete: () =>
                            _deleteTransaction(context, transaction.id),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    ),    );  }

  void _selectDateRange(BuildContext context, LocalizationProvider localization) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  void _editTransaction(BuildContext context, TransactionModel transaction) {
    final localization = context.read<LocalizationProvider>();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(localization.translate('edit_functionality'))),
    );
  }

  void _deleteTransaction(BuildContext context, int id) async {
    final localization = context.read<LocalizationProvider>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localization.translate('delete_transaction')),
        content: Text(
          localization.translate('are_you_sure_delete'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(localization.translate('cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(localization.translate('delete')),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await context.read<TransactionProvider>().deleteTransaction(id);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(localization.translate('transaction_deleted'))));
    }
  }
}

/// Filter tab widget
class _FilterTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterTab({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: !isSelected
              ? Border.all(color: AppColors.outlineVariant.withOpacity(0.3))
              : null,
        ),
        child: Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            color: isSelected ? Colors.white : AppColors.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
