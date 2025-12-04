import 'package:flutter/material.dart';

import 'home_page.dart';
import 'client_details_page.dart';
import 'completed_actions_page.dart';
import 'profile_page.dart';
import '../widgets/bottom_nav.dart';
import '../config/app_colors.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
    ClientDetailsPage(),
    CompletedActionsPage(),
    ProfilePage(),
  ];

  void _onTabChanged(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: SafeArea(
        top: false,
        child: BottomNav(currentIndex: _currentIndex, onTap: _onTabChanged),
      ),
    );
  }
}
