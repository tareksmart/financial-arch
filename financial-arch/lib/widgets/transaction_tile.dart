import 'package:flutter/material.dart';
import '../models/index.dart';
import '../theme/index.dart';

/// Transaction list tile widget
class TransactionTile extends StatelessWidget {
  final TransactionModel transaction;
  final CategoryModel? category;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool isExpense;

  const TransactionTile({
    Key? key,
    required this.transaction,
    this.category,
    this.onTap,
    this.onLongPress,
    required this.isExpense,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final amountColor = isExpense ? AppColors.error : AppColors.success;
    final amountSign = isExpense ? '-' : '+';
    final categoryColor = category?.colorHex != null
        ? Color(
            int.parse('0xFF${category!.colorHex!.replaceAll('#', '')}'),
          ).withOpacity(0.15)
        : AppColors.surfaceContainerLow;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            children: [
              // Category Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: categoryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getIconData(category?.iconName ?? 'account_balance'),
                  color: Color(
                    int.parse(
                      '0xFF${category?.colorHex?.replaceAll('#', '') ?? '1A237E'}',
                    ),
                  ),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              // Transaction Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category?.nameEn ?? 'Unknown',
                      style: AppTextStyles.titleSmall.copyWith(
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${transaction.date.day} ${_getMonthName(transaction.date.month)}, ${transaction.date.year}',
                      style: AppTextStyles.labelSmall,
                    ),
                  ],
                ),
              ),
              // Amount
              Text(
                '$amountSign${transaction.amount.toStringAsFixed(2)} EGP',
                style: AppTextStyles.titleSmall.copyWith(
                  color: amountColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconData(String iconName) {
    final iconMap = {
      'payments': Icons.payments,
      'work': Icons.work,
      'restaurant': Icons.restaurant,
      'directions_car': Icons.directions_car,
      'shopping_bag': Icons.shopping_bag,
      'home': Icons.home,
      'local_hospital': Icons.local_hospital,
      'movie': Icons.movie,
      'electric_bolt': Icons.electric_bolt,
      'card_giftcard': Icons.card_giftcard,
      'trending_up': Icons.trending_up,
      'account_balance': Icons.account_balance,
    };
    return iconMap[iconName] ?? Icons.account_balance;
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }
}

/// Expandable transaction tile for detailed view
class ExpandableTransactionTile extends StatefulWidget {
  final TransactionModel transaction;
  final CategoryModel? category;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ExpandableTransactionTile({
    Key? key,
    required this.transaction,
    this.category,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);

  @override
  State<ExpandableTransactionTile> createState() =>
      _ExpandableTransactionTileState();
}

class _ExpandableTransactionTileState extends State<ExpandableTransactionTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isExpense = widget.transaction.type == 'EXPENSE';
    final amountColor = isExpense ? AppColors.error : AppColors.success;
    final amountSign = isExpense ? '-' : '+';

    return Column(
      children: [
        // Header
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              setState(() => _isExpanded = !_isExpanded);
              _isExpanded ? _controller.forward() : _controller.reverse();
            },
            borderRadius: BorderRadius.circular(24),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: _isExpanded
                    ? AppColors.surfaceContainerLow
                    : AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.vertical(
                  top: const Radius.circular(24),
                  bottom: Radius.circular(_isExpanded ? 0 : 24),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Color(
                        int.parse(
                          '0xFF${widget.category?.colorHex?.replaceAll('#', '') ?? '1A237E'}',
                        ),
                      ).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getIconData(
                        widget.category?.iconName ?? 'account_balance',
                      ),
                      color: Color(
                        int.parse(
                          '0xFF${widget.category?.colorHex?.replaceAll('#', '') ?? '1A237E'}',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.category?.nameEn ?? 'Unknown',
                          style: AppTextStyles.titleSmall.copyWith(
                            color: AppColors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${widget.transaction.date.day} ${_getMonthName(widget.transaction.date.month)}, ${widget.transaction.date.year}',
                          style: AppTextStyles.labelSmall,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '$amountSign${widget.transaction.amount.toStringAsFixed(2)} EGP',
                    style: AppTextStyles.titleSmall.copyWith(
                      color: amountColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 8),
                  RotationTransition(
                    turns: Tween(begin: 0.0, end: 0.5).animate(_controller),
                    child: Icon(
                      Icons.expand_more,
                      color: AppColors.outlineVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Expandable Content
        if (_isExpanded)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(color: AppColors.outlineVariant, height: 16),
                if (widget.transaction.note != null &&
                    widget.transaction.note!.isNotEmpty) ...[
                  Text(
                    'Notes',
                    style: AppTextStyles.labelMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.transaction.note!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                Text(
                  'Time',
                  style: AppTextStyles.labelMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${widget.transaction.date.hour.toString().padLeft(2, '0')}:${widget.transaction.date.minute.toString().padLeft(2, '0')}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: widget.onEdit,
                        icon: const Icon(Icons.edit, size: 16),
                        label: const Text('Edit'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: widget.onDelete,
                        icon: const Icon(
                          Icons.delete,
                          size: 16,
                          color: AppColors.error,
                        ),
                        label: const Text(
                          'Delete',
                          style: TextStyle(color: AppColors.error),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          side: const BorderSide(color: AppColors.error),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }

  IconData _getIconData(String iconName) {
    final iconMap = {
      'payments': Icons.payments,
      'work': Icons.work,
      'restaurant': Icons.restaurant,
      'directions_car': Icons.directions_car,
      'shopping_bag': Icons.shopping_bag,
      'home': Icons.home,
      'local_hospital': Icons.local_hospital,
      'movie': Icons.movie,
      'electric_bolt': Icons.electric_bolt,
      'card_giftcard': Icons.card_giftcard,
      'trending_up': Icons.trending_up,
      'account_balance': Icons.account_balance,
    };
    return iconMap[iconName] ?? Icons.account_balance;
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }
}
