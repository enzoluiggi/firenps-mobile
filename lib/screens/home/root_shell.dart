import 'package:flutter/material.dart';

import '../../data/fire_nps_controller.dart';
import '../../theme/app_theme.dart';
import '../dashboard/dashboard_screen.dart';
import '../insights/insights_screen.dart';
import '../settings/settings_screen.dart';
import '../surveys/surveys_screen.dart';

class RootShell extends StatefulWidget {
  const RootShell({super.key, required this.controller});

  final FireNpsController controller;

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final user = widget.controller.currentUser;
    final pages = [
      DashboardScreen(controller: widget.controller),
      SurveysScreen(controller: widget.controller),
      InsightsScreen(controller: widget.controller),
      SettingsScreen(controller: widget.controller),
    ];
    final titles = ['FireNps', 'Pesquisas', 'Insights', 'Configuracoes'];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              color: AppColors.primary,
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titles[currentIndex],
                    style: Theme.of(
                      context,
                    ).textTheme.titleLarge?.copyWith(color: Colors.white),
                  ),
                  Text(
                    '${user?.fullName ?? ''} - ${user?.companyName ?? ''}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.84),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: IndexedStack(index: currentIndex, children: pages),
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          setState(() => currentIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_outlined),
            label: 'Pesquisas',
          ),
          NavigationDestination(
            icon: Icon(Icons.lightbulb_outline),
            label: 'Insights',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            label: 'Config',
          ),
        ],
      ),
    );
  }
}
