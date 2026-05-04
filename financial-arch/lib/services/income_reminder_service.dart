import 'package:flutter/material.dart';

/// Service to handle income expiry reminders via SnackBar
class IncomeReminderService {
  IncomeReminderService._();

  /// Threshold in days to trigger reminder before expiry
  static const int reminderThresholdDays = 3;

  /// Flag to ensure reminder is only shown once per app session
  static bool _shownThisSession = false;

  /// Reset the session flag (useful for testing or manual reset)
  static void resetSessionFlag() {
    _shownThisSession = false;
  }

  /// Check for upcoming income expiry and show SnackBar reminder if applicable
  ///
  /// This method should be called when the app loads or user navigates to home screen.
  /// It will find the nearest upcoming income expiry date and show a reminder if:
  /// - The expiry is within [reminderThresholdDays] days from now
  /// - The income hasn't already expired
  /// - The reminder hasn't been shown yet this session
  ///
  /// Parameters:
  /// - [context]: BuildContext used to show the SnackBar and navigate
  /// - [incomes]: List of income objects (should have expiryDate and other properties)
  static void checkAndShowExpiryReminder(BuildContext context, List incomes) {
    if (_shownThisSession) return;
    if (incomes.isEmpty) return;

    final now = DateTime.now();

    // Filter future income entries and sort by expiry date
    final upcoming = incomes.where((income) {
      try {
        return income.expiryDate != null &&
            income.expiryDate is DateTime &&
            (income.expiryDate as DateTime).isAfter(now);
      } catch (e) {
        return false;
      }
    }).toList()
      ..sort((a, b) =>
          (a.expiryDate as DateTime).compareTo(b.expiryDate as DateTime));

    if (upcoming.isEmpty) return;

    final nearest = upcoming.first;
    final expiryDate = nearest.expiryDate as DateTime;
    final daysLeft = expiryDate.difference(now).inDays;

    // Check if expiry is within reminder threshold
    if (daysLeft <= reminderThresholdDays && daysLeft >= 0) {
      _shownThisSession = true;

      // Format the date as DD/MM/YYYY
      final formattedDate =
          '${expiryDate.day.toString().padLeft(2, '0')}/${expiryDate.month.toString().padLeft(2, '0')}/${expiryDate.year}';

      // Build the reminder message in Arabic
      final reminderMessage =
          'تنبيه: دخلك سينتهي خلال $daysLeft أيام — تاريخ الانتهاء: $formattedDate ⚠️';

      // Show the SnackBar with orange background
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            reminderMessage,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
          backgroundColor: Colors.orange.shade800,
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'عرض التفاصيل',
            textColor: Colors.white,
            onPressed: () {
              // Navigate to income details screen
              // You can customize this navigation based on your app's routing
              _navigateToIncomeDetails(context, nearest);
            },
          ),
        ),
      );
    }
  }

  /// Navigate to income details screen
  /// This is a placeholder method that can be customized based on your routing setup
  static void _navigateToIncomeDetails(BuildContext context, dynamic income) {
    // Example navigation (customize based on your actual routing)
    // Navigator.of(context).pushNamed('/income-details', arguments: income);

    // For now, just print debug info
    debugPrint('Navigating to income details for income: ${income.id}');
  }
}
