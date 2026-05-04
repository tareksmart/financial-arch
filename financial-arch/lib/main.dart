import 'package:financial_architect/widgets/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/index.dart';
import 'screens/index.dart';
import 'theme/index.dart';
import 'localization/index.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FinancialArchitectApp());
}

class FinancialArchitectApp extends StatelessWidget {
  const FinancialArchitectApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Localization Provider
        ChangeNotifierProvider(create: (_) => LocalizationProvider()),
        // Authentication Provider
        ChangeNotifierProvider(create: (_) => AuthenticationProvider()),
        // Category Provider
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        // Transaction Provider
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        // Settings Provider
        ChangeNotifierProxyProvider<LocalizationProvider, SettingsProvider>(
          create: (context) => SettingsProvider(),
          update: (context, localizationProvider, settingsProvider) {
            settingsProvider?.updateLocalizationProvider(localizationProvider);
            return settingsProvider!;
          },
        ),
        // Home Provider - depends on TransactionProvider
        ChangeNotifierProxyProvider<TransactionProvider, HomeProvider>(
          create: (context) => HomeProvider(
            transactionProvider: context.read<TransactionProvider>(),
          ),
          update: (context, transactionProvider, homeProvider) {
            homeProvider!.updateTransactionProvider(transactionProvider);
            return homeProvider;
          },
        ),
      ],
      child: Consumer2<LocalizationProvider, SettingsProvider>(
        builder: (context, localizationProvider, settingsProvider, _) {
          return MaterialApp(
            title: 'Financial Architect',
            debugShowCheckedModeBanner: false,
            locale: localizationProvider.getLocale(),
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en', 'US'),
              Locale('ar', 'SA'),
            ],
            theme: AppTheme.lightTheme(),
            darkTheme: AppTheme.darkTheme(),
            themeMode: settingsProvider.theme == 'dark'
                ? ThemeMode.dark
                : ThemeMode.light,
            home: const AppInitializer(),
            routes: {
              '/login': (context) => const LoginScreen(),
              '/home': (context) => const MainApp(),
            },
          );
        },
      ),
    );
  }
}

/// Initializer screen that checks auth status and settings on startup
class AppInitializer extends StatefulWidget {
  const AppInitializer({Key? key}) : super(key: key);

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Load settings first
    await context.read<SettingsProvider>().loadSettings();

    // Check authentication status
    await context.read<AuthenticationProvider>().checkAuthStatus();

    if (!mounted) return;

    // Navigate based on auth status
    final isAuthenticated =
        context.read<AuthenticationProvider>().isAuthenticated;
    if (isAuthenticated) {
      Navigator.of(context).pushReplacementNamed('/home');
    } else {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Center(
                child: Icon(
                  Icons.account_balance,
                  color: Colors.white,
                  size: 50,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Financial Architect',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}

/// Main app with bottom navigation
class MainApp extends StatefulWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    HistoryScreen(),
    AnalyticsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: FinancialArchitectBottomNav(
        currentIndex: _selectedIndex,
        onIndexChanged: (index) => setState(() => _selectedIndex = index),
      ),
    );
  }
}
