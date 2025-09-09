import 'package:flutter/material.dart';
import 'package:isdb_radio/providers/navigation_provider.dart';
import 'package:provider/provider.dart';

class MyBottomNavigationBarWidget extends StatelessWidget {
  const MyBottomNavigationBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationProvider>(
      builder: (context, navigationProvider, child) {
        return ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(22.0),
            topRight: Radius.circular(22.0),
          ),
          child: NavigationBar(
            destinations: [
              NavigationDestination(
                icon: Icon(
                  Icons.radio,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                label: 'Live',
                selectedIcon: Icon(
                  Icons.radio,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              NavigationDestination(
                icon: Icon(
                  Icons.archive,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,  
                ),
                label: 'Archive',
                selectedIcon: Icon(
                  Icons.archive,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
            overlayColor: WidgetStateProperty.all(
              Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            ),
            backgroundColor: Theme.of(context).navigationBarTheme.backgroundColor,            
            selectedIndex: navigationProvider.currentIndex,
            height: 72.0,
            onDestinationSelected: (index) {
              navigationProvider.setCurrentIndex(index);
            },
          ),
        );
      },
    );
  }
}