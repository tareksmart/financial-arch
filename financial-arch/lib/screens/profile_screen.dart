import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/index.dart';
import '../widgets/index.dart';
import '../theme/index.dart';
import '../localization/index.dart';

/// Profile/Settings screen
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SettingsProvider>().loadSettings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LocalizationProvider>(
      builder: (context, localization, _) => Scaffold(
        backgroundColor: AppColors.surface,
        appBar: FinancialArchitectAppBar(
          title: localization.translate('profile_settings'),
          showBackButton: false,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Section
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primary, width: 3),
                      ),
                      child: const Icon(
                        Icons.person,
                        size: 40,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      localization.translate('user_profile'),
                      style: AppTextStyles.headlineSmall.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      localization.translate('premium_member'),
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Account Management
              _SettingsSection(
                title: localization.translate('account_management'),
                items: [
                  _SettingsItem(
                    icon: Icons.person,
                    title: localization.translate('personal_information'),
                    subtitle: localization.translate('update_name_email'),
                    onTap: () {},
                  ),
                  _SettingsItem(
                    icon: Icons.security,
                    title: localization.translate('security_privacy'),
                    subtitle: localization.translate('two_factor_auth'),
                    onTap: () {},
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Preferences
              _SettingsSection(
                title: localization.translate('app_preferences'),
                items: [
                  Consumer<SettingsProvider>(
                    builder: (context, settingsProvider, _) {
                      return Column(
                        children: [
                          _SettingItemWithToggle(
                            icon: Icons.payments,
                            title: localization.translate('currency'),
                            value: settingsProvider.currency,
                            onTap: () => _showCurrencyDialog(
                                context, settingsProvider, localization),
                          ),
                          _SettingItemWithToggle(
                            icon: Icons.language,
                            title: localization.translate('language'),
                            value: settingsProvider.language == 'en'
                                ? localization.translate('english')
                                : localization.translate('arabic'),
                            onTap: () => _showLanguageDialog(
                                context, settingsProvider, localization),
                          ),
                          _SettingItemWithToggle(
                            icon: Icons.palette,
                            title: localization.translate('theme'),
                            value: settingsProvider.theme == 'light'
                                ? localization.translate('light')
                                : localization.translate('dark'),
                            isLocked: true,
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Information
              _SettingsSection(
                title: localization.translate('information'),
                items: [
                  _SettingsItem(
                    icon: Icons.info,
                    title: localization.translate('about_app'),
                    subtitle: localization.translate('version'),
                    onTap: () {},
                  ),
                  _SettingsItem(
                    icon: Icons.description,
                    title: localization.translate('legal_terms'),
                    subtitle: localization.translate('privacy_policy'),
                    onTap: () {},
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Logout
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    localization.translate('logout'),
                    style:
                        AppTextStyles.labelLarge.copyWith(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCurrencyDialog(
    BuildContext context,
    SettingsProvider settingsProvider,
    LocalizationProvider localization,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localization.translate('select_currency')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['EGP', 'USD', 'EUR', 'SAR']
              .map(
                (currency) => ListTile(
                  title: Text(currency),
                  onTap: () {
                    settingsProvider.setCurrency(currency);
                    Navigator.pop(context);
                  },
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  void _showLanguageDialog(
    BuildContext context,
    SettingsProvider settingsProvider,
    LocalizationProvider localization,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localization.translate('select_language')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(localization.translate('english')),
              onTap: () {
                settingsProvider.setLanguage('en');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text(localization.translate('arabic')),
              onTap: () {
                settingsProvider.setLanguage('ar');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Settings section widget
class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> items;

  const _SettingsSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.labelMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(children: items),
        ),
      ],
    );
  }
}

/// Settings item widget
class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _SettingsItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: AppColors.outlineVariant, width: 0.5),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.titleSmall.copyWith(
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.outlineVariant),
            ],
          ),
        ),
      ),
    );
  }
}

/// Settings item with toggle/value widget
class _SettingItemWithToggle extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final VoidCallback? onTap;
  final bool isLocked;

  const _SettingItemWithToggle({
    required this.icon,
    required this.title,
    required this.value,
    this.onTap,
    this.isLocked = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLocked ? null : onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: AppColors.outlineVariant, width: 0.5),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.titleSmall.copyWith(
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (isLocked)
                const Icon(Icons.lock, color: AppColors.primary, size: 16)
              else
                const Icon(
                  Icons.chevron_right,
                  color: AppColors.outlineVariant,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
