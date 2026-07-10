import 'package:flutter/material.dart';

import 'widgets/app_sidebar.dart';
import 'widgets/app_header.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Row(
        children: [
          const AppSidebar(),
          Expanded(
            child: Column(
              children: [
                const AppHeader(),
                Expanded(child: child),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
