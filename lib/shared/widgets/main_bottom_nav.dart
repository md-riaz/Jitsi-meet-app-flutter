import 'package:flutter/material.dart';

import 'package:alora_meet/app/routes.dart';

class MainBottomNav extends StatelessWidget {
  final int currentIndex;

  const MainBottomNav({super.key, required this.currentIndex});

  void _onTap(BuildContext context, int index) {
    if (index == currentIndex) return;

    // Capture the NavigatorState before popUntil so the subsequent pushNamed
    // call does not use a BuildContext that may have been deactivated after the
    // pop removes the current route from the tree.
    final navigator = Navigator.of(context);

    // Navigate back to the dashboard root (or the first route if dashboard is
    // not in the stack) to keep a clean navigation stack.
    navigator.popUntil((route) {
      return route.settings.name == AppRoutes.dashboard || route.isFirst;
    });

    if (index == 0) return; // Already at dashboard after popUntil.

    switch (index) {
      case 1:
        navigator.pushNamed(AppRoutes.history);
        break;
      case 2:
        navigator.pushNamed(AppRoutes.settings);
        break;
      case 3:
        navigator.pushNamed(AppRoutes.profile);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) => _onTap(context, index),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home_rounded),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.history_outlined),
          activeIcon: Icon(Icons.history_rounded),
          label: 'History',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings_outlined),
          activeIcon: Icon(Icons.settings_rounded),
          label: 'Settings',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person_rounded),
          label: 'Profile',
        ),
      ],
    );
  }
}
