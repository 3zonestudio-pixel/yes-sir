import 'package:flutter/material.dart';
import '../theme/military_theme.dart';
import 'commander_ai_screen.dart';
import 'missions_screen.dart';
import 'mission_map_screen.dart';
import 'reports_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    CommanderAIScreen(),
    MissionsScreen(),
    MissionMapScreen(),
    ReportsScreen(),
  ];

  final List<String> _titles = [
    'COMMAND CENTER',
    'MISSIONS',
    'MISSION MAP',
    'REPORTS',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
        leading: Padding(
          padding: const EdgeInsets.all(10),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: MilitaryTheme.goldAccent.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: const Icon(
              Icons.military_tech,
              color: MilitaryTheme.goldAccent,
              size: 20,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: MilitaryTheme.textMuted, size: 22),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(
              color: MilitaryTheme.surfaceLight,
              width: 0.5,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.smart_toy),
              activeIcon: Icon(Icons.smart_toy),
              label: 'Command',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.assignment_outlined),
              activeIcon: Icon(Icons.assignment),
              label: 'Missions',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month_outlined),
              activeIcon: Icon(Icons.calendar_month),
              label: 'Map',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.analytics_outlined),
              activeIcon: Icon(Icons.analytics),
              label: 'Reports',
            ),
          ],
        ),
      ),
    );
  }
}
