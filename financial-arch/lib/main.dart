import 'package:financial_architect/widgets/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/index.dart';
import 'screens/index.dart';
import 'theme/index.dart';

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
        // Category Provider
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        // Transaction Provider
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        // Settings Provider
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        // Home Provider
        ProxyProvider<TransactionProvider, HomeProvider>(
          create: (context) => HomeProvider(
            transactionProvider: context.read<TransactionProvider>(),
          ),
          update: (context, transactionProvider, homeProvider) =>
              homeProvider ??
              HomeProvider(transactionProvider: transactionProvider),
        ),
      ],
      child: MaterialApp(
        title: 'Financial Architect',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme(),
        home: const MainApp(),
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
