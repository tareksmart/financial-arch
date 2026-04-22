import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/index.dart';
import '../providers/index.dart';
import '../theme/index.dart';
import 'form_fields.dart';

/// Alert dialog for adding a new category
class CategoryAddDialog extends StatefulWidget {
  final String categoryType; // 'INCOME' or 'EXPENSE'

  const CategoryAddDialog({
    Key? key,
    required this.categoryType,
  }) : super(key: key);

  @override
  State<CategoryAddDialog> createState() => _CategoryAddDialogState();
}

class _CategoryAddDialogState extends State<CategoryAddDialog> {
  late TextEditingController _nameArController;
  late TextEditingController _nameEnController;
  late TextEditingController _colorHexController;
  late TextEditingController _iconNameController;
  String? _selectedType;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _nameArController = TextEditingController();
    _nameEnController = TextEditingController();
    _colorHexController = TextEditingController();
    _iconNameController = TextEditingController();
    _selectedType = widget.categoryType;
  }

  @override
  void dispose() {
    _nameArController.dispose();
    _nameEnController.dispose();
    _colorHexController.dispose();
    _iconNameController.dispose();
    super.dispose();
  }

  Future<void> _addCategory() async {
    // Validation
    if (_nameArController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'الرجاء إدخال اسم الفئة بالعربية');
      return;
    }
    if (_nameEnController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Please enter category name in English');
      return;
    }
    if (_selectedType == null) {
      setState(() => _errorMessage = 'Please select category type');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final categoryProvider =
          context.read<CategoryProvider>();

      final newCategory = CategoryModel(
        id: 0, // Will be assigned by database
        nameAr: _nameArController.text.trim(),
        nameEn: _nameEnController.text.trim(),
        type: _selectedType!,
        iconName: _iconNameController.text.trim().isEmpty
            ? null
            : _iconNameController.text.trim(),
        colorHex: _colorHexController.text.trim().isEmpty
            ? null
            : _colorHexController.text.trim(),
      );

      final result = await categoryProvider.addCategory(newCategory);

      if (result > 0) {
        if (mounted) {
          Navigator.of(context).pop(true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Category added successfully'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } else {
        setState(() =>
            _errorMessage = categoryProvider.error ?? 'Failed to add category');
      }
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Add New Category',
                    style: AppTextStyles.headlineSmall,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                    splashRadius: 20,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Error Message
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.error),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: AppColors.error,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              if (_errorMessage != null) const SizedBox(height: 16),

              // Arabic Name Field
              FinancialArchitectTextField(
                label: 'Category Name (Arabic)',
                hintText: 'مثال: طعام',
                controller: _nameArController,
                prefixIcon: Icons.label_outline,
              ),
              const SizedBox(height: 16),

              // English Name Field
              FinancialArchitectTextField(
                label: 'Category Name (English)',
                hintText: 'Example: Food',
                controller: _nameEnController,
                prefixIcon: Icons.label_outline,
              ),
              const SizedBox(height: 16),

              // Category Type Dropdown
              Text(
                'Category Type',
                style: AppTextStyles.labelMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButton<String>(
                  value: _selectedType,
                  isExpanded: true,
                  underline: const SizedBox(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  items: const [
                    DropdownMenuItem(
                      value: 'INCOME',
                      child: Text('Income'),
                    ),
                    DropdownMenuItem(
                      value: 'EXPENSE',
                      child: Text('Expense'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedType = value);
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Optional: Icon Name Field
              FinancialArchitectTextField(
                label: 'Icon Name (Optional)',
                hintText: 'e.g., restaurant, shopping_bag',
                controller: _iconNameController,
                prefixIcon: Icons.emoji_emotions_outlined,
              ),
              const SizedBox(height: 16),

              // Optional: Color Hex Field
              FinancialArchitectTextField(
                label: 'Color (Hex, Optional)',
                hintText: 'e.g., FF5733',
                controller: _colorHexController,
                prefixIcon: Icons.palette_outlined,
              ),
              const SizedBox(height: 32),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isLoading
                        ? null
                        : () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _addCategory,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.primaryDark,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: _isLoading
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.primaryDark,
                              ),
                            ),
                          )
                        : const Text('Add Category'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
