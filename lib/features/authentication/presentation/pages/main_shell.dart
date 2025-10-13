import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/custom_bottom_navbar.dart';

class MainShell extends StatefulWidget {
  final Widget child;
  final int currentIndex;

  const MainShell({super.key, required this.child, required this.currentIndex});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  void _onTabSelected(int index) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/notifications');
        break;
      case 2:
        context.go('/assignments');
        break;
      case 3:
        context.go('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: widget.currentIndex,
        onTabSelected: _onTabSelected,
      ),
    );
  }
}
