import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:frontend/dashboard/dashboard_screen.dart';
import 'package:frontend/transactions/transactions_screen.dart';
import 'package:frontend/categories/category_mgmt_screen.dart';
import 'package:frontend/ai/ai_insights_screen.dart';
import 'package:frontend/profile/user_profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    TransactionListScreen(),
    CategoryManagementScreen(),
    AiInsightsScreen(),
    UserProfileScreen(),
  ];

  final List<IconData> _icons = [
    Icons.dashboard,
    Icons.list_alt,
    Icons.category,
    Icons.insights,
    Icons.person,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: _currentIndex, children: _screens),
      // _screens[_currentIndex],
      bottomNavigationBar: CurvedNavigationBar(
        index: _currentIndex,
        height: 60.0,
        items: _icons
            .map((icon) => Icon(icon, size: 30, color: Colors.white))
            .toList(),
        color: Colors.teal,
        buttonBackgroundColor: Colors.tealAccent,
        backgroundColor: Colors.transparent,
        animationCurve: Curves.easeInOut,
        animationDuration: const Duration(milliseconds: 300),
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
