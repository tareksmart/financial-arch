import 'package:financial_architect/widgets/category_add_dialog.dart';
import 'package:flutter/material.dart';
import '../theme/index.dart';

/// Custom form field for Financial Architect
class FinancialArchitectTextField extends StatefulWidget {
  final String label;
  final String? hintText;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final int maxLines;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final IconData? prefixIcon;
  final String? prefix;

  const FinancialArchitectTextField({
    Key? key,
    required this.label,
    this.hintText,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.validator,
    this.onChanged,
    this.prefixIcon,
    this.prefix,
  }) : super(key: key);

  @override
  State<FinancialArchitectTextField> createState() =>
      _FinancialArchitectTextFieldState();
}

class _FinancialArchitectTextFieldState
    extends State<FinancialArchitectTextField> {
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: AppTextStyles.labelMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: _isFocused
                ? AppColors.primary.withOpacity(0.05)
                : AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(12),
            border: _isFocused
                ? Border.all(color: AppColors.primary, width: 2)
                : null,
          ),
          child: TextFormField(
            controller: widget.controller,
            focusNode: _focusNode,
            keyboardType: widget.keyboardType,
            maxLines: widget.maxLines,
            minLines: widget.maxLines == 1 ? null : 1,
            decoration: InputDecoration(
              hintText: widget.hintText,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
              prefixIcon:
                  widget.prefixIcon != null ? Icon(widget.prefixIcon) : null,
              prefix: widget.prefix != null ? Text(widget.prefix!) : null,
              prefixText: widget.prefix != null ? null : widget.prefix,
            ),
            style: AppTextStyles.bodyMedium,
            validator: widget.validator,
            onChanged: widget.onChanged,
          ),
        ),
      ],
    );
  }
}

/// Category selector button
class CategorySelectorButton extends StatelessWidget {
  final String? selectedCategory;
  final VoidCallback onTap;
  final String label;

  const CategorySelectorButton({
    Key? key,
    this.selectedCategory,
    required this.onTap,
    this.label = 'Category',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.labelMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.outlineVariant.withOpacity(0.15),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedCategory ?? 'Select a category',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: selectedCategory != null
                        ? AppColors.onSurface
                        : AppColors.onSurfaceVariant,
                  ),
                ),
                const Icon(
                  Icons.expand_more,
                  color: AppColors.onSurfaceVariant,
                ),
                IconButton(
                    onPressed: () => showDialog(
                          context: context,
                          builder: (context) => const CategoryAddDialog(
                            categoryType: 'EXPENSE', // or 'INCOME'
                          ),
                        ),
                    icon: Icon(Icons.add))
              ],
            ),
          ),
        ],
      ),
    );
  }
}
