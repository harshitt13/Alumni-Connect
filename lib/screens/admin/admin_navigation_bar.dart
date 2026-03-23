import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'admin_dashboard.dart';
import 'manage_alumni_screen.dart';
import 'manage_events_screen.dart';

class AdminNavigation extends StatefulWidget {
  const AdminNavigation({super.key});

  @override
  State<AdminNavigation> createState() => _AdminNavigationState();
}

class _AdminNavigationState extends State<AdminNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    AdminDashboard(),
    ManageAlumniScreen(),
    ManageEventsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            )
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Theme.of(context).cardTheme.color,
          selectedItemColor: Colors.deepPurple,
          unselectedItemColor: Theme.of(context).textTheme.bodyMedium?.color,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(icon: Icon(LucideIcons.layoutDashboard), label: 'Panel'),
            BottomNavigationBarItem(icon: Icon(LucideIcons.users), label: 'Alumni'),
            BottomNavigationBarItem(icon: Icon(LucideIcons.calendar), label: 'Events'),
          ],
        ),
      ),
    );
  }
}
