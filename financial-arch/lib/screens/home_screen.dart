import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/index.dart';
import '../providers/index.dart';
import '../widgets/index.dart';
import '../theme/index.dart';

/// Home screen - main dashboard with balance and transaction entry
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late TextEditingController _amountController;
  late TextEditingController _noteController;
  late TextEditingController _dateController;

  String _selectedType = 'EXPENSE';
  CategoryModel? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
    _noteController = TextEditingController();
    _dateController = TextEditingController();

    // Initialize data on screen load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeProvider>().loadHomeData();
      context.read<TransactionProvider>().loadTransactions();
      context.read<CategoryProvider>().loadCategories();
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  void _submitTransaction() async {
    if (_amountController.text.isEmpty || _selectedCategory == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    final now = DateTime.now();
    final transaction = TransactionModel(
      id: 0,
      categoryId: _selectedCategory!.id,
      amount: double.parse(_amountController.text),
      type: _selectedType,
      date: now,
      note: _noteController.text.isEmpty ? null : _noteController.text,
      createdAt: now,
    );

    await context.read<TransactionProvider>().addTransaction(transaction);
    await context.read<HomeProvider>().loadHomeData();

    if (!mounted) return;
    _amountController.clear();
    _noteController.clear();
    _selectedCategory = null;
    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Transaction recorded successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Row(
          children: [
            const Icon(Icons.account_balance_wallet, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              'Financial Architect',
              style: AppTextStyles.headlineSmall.copyWith(
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications,
              color: AppColors.onSurfaceVariant,
            ),
            onPressed: () {},
          ),
        ],
        surfaceTintColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pulse Card - Daily Balance
            Consumer<HomeProvider>(
              builder: (context, homeProvider, _) {
                return PulseCard(
                  title: 'Net Daily Balance',
                  amount: homeProvider.todayBalance.toStringAsFixed(2),
                  currency: 'EGP',
                  subtitle:
                      '${homeProvider.todayBalance.toStringAsFixed(2)} EGP balance today',
                  child: Row(
                    children: [
                      Expanded(
                        child: _BalanceSummaryItem(
                          label: 'Income',
                          amount: homeProvider.todayIncome,
                          isIncome: true,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _BalanceSummaryItem(
                          label: 'Spent',
                          amount: homeProvider.todayExpense,
                          isIncome: false,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 32),

            // Transaction Entry Form
            _TransactionForm(
              amountController: _amountController,
              noteController: _noteController,
              dateController: _dateController,
              selectedType: _selectedType,
              selectedCategory: _selectedCategory,
              onTypeChanged: (type) => setState(() => _selectedType = type),
              onCategorySelected: (category) =>
                  setState(() => _selectedCategory = category),
              onSubmit: _submitTransaction,
            ),
            const SizedBox(height: 32),

            // Recent Transactions
            Text(
              'Recent Transactions',
              style: AppTextStyles.headlineSmall.copyWith(
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 12),
            Consumer2<TransactionProvider, CategoryProvider>(
              builder: (context, transactionProvider, categoryProvider, _) {
                final recentTransactions =
                    transactionProvider.allTransactions.take(5).toList();
                if (recentTransactions.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(32),
                    child: Center(
                      child: Text(
                        'No transactions yet',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  );
                }
                return Column(
                  children: recentTransactions.map((transaction) {
                    final category = categoryProvider.allCategories.firstWhere(
                      (cat) => cat.id == transaction.categoryId,
                      orElse: () => CategoryModel(
                        id: 0,
                        nameAr: 'Unknown',
                        nameEn: 'Unknown',
                        type: 'EXPENSE',
                      ),
                    );
                    return TransactionTile(
                      transaction: transaction,
                      category: category,
                      isExpense: transaction.type == 'EXPENSE',
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Balance summary item widget
class _BalanceSummaryItem extends StatelessWidget {
  final String label;
  final double amount;
  final bool isIncome;

  const _BalanceSummaryItem({
    required this.label,
    required this.amount,
    required this.isIncome,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 4),
          RichText(
            text: TextSpan(
              children: [
                if (!isIncome)
                  TextSpan(
                    text: '-',
                    style: AppTextStyles.headlineSmall.copyWith(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                TextSpan(
                  text: '${amount.toStringAsFixed(0)} ',
                  style: AppTextStyles.titleSmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextSpan(
                  text: 'EGP',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Transaction form widget
class _TransactionForm extends StatefulWidget {
  final TextEditingController amountController;
  final TextEditingController noteController;
  final TextEditingController dateController;
  final String selectedType;
  final CategoryModel? selectedCategory;
  final ValueChanged<String> onTypeChanged;
  final ValueChanged<CategoryModel> onCategorySelected;
  final VoidCallback onSubmit;

  const _TransactionForm({
    required this.amountController,
    required this.noteController,
    required this.dateController,
    required this.selectedType,
    required this.selectedCategory,
    required this.onTypeChanged,
    required this.onCategorySelected,
    required this.onSubmit,
  });

  @override
  State<_TransactionForm> createState() => _TransactionFormState();
}

class _TransactionFormState extends State<_TransactionForm> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Type Tabs
          Consumer<CategoryProvider>(
            builder: (context, categoryProvider, _) {
              return Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    _TypeTab(
                      label: 'Expense',
                      isSelected: widget.selectedType == 'EXPENSE',
                      onTap: () => widget.onTypeChanged('EXPENSE'),
                    ),
                    _TypeTab(
                      label: 'Income',
                      isSelected: widget.selectedType == 'INCOME',
                      onTap: () => widget.onTypeChanged('INCOME'),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 24),

          // Amount Field
          FinancialArchitectTextField(
            label: 'Amount',
            hintText: '0.00',
            controller: widget.amountController,
            keyboardType: TextInputType.number,
            prefix: 'EGP',
          ),
          const SizedBox(height: 24),

          // Category Field
          Consumer<CategoryProvider>(
            builder: (context, categoryProvider, _) {
              final categories = widget.selectedType == 'EXPENSE'
                  ? categoryProvider.expenseCategories
                  : categoryProvider.incomeCategories;

              return CategorySelectorButton(
                selectedCategory: widget.selectedCategory?.nameEn,
                onTap: () => _showCategoryDialog(context, categories),
                label: 'Category',
              );
            },
          ),
          const SizedBox(height: 24),

          // Note Field
          FinancialArchitectTextField(
            label: 'Details (Optional)',
            hintText: 'Add notes...',
            controller: widget.noteController,
            maxLines: 2,
          ),
          const SizedBox(height: 24),

          // Action Buttons
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(Icons.mic, color: AppColors.primary),
                  onPressed: () {},
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: widget.onSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Record ${widget.selectedType == 'EXPENSE' ? 'Expense' : 'Income'}',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showCategoryDialog(
      BuildContext context, List<CategoryModel> categories) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Category'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: categories
                .map(
                  (category) => ListTile(
                    title: Text(category.nameEn),
                    onTap: () {
                      widget.onCategorySelected(category);
                      Navigator.pop(context);
                    },
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}

/// Type tab widget
class _TypeTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TypeTab({
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
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AppTextStyles.labelLarge.copyWith(
              color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
