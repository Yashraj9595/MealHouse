import 'package:flutter/material.dart';
import '../../core/app_export.dart';

class BottomBarItem {
  final String iconName;
  final String label;

  BottomBarItem({required this.iconName, required this.label});
}

class CustomBottomBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<BottomBarItem> items;

  const CustomBottomBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: theme.colorScheme.primary,
        unselectedItemColor: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
        items: items.map((item) => BottomNavigationBarItem(
          icon: CustomIconWidget(iconName: item.iconName),
          label: item.label,
        )).toList(),
      ),
    );
  }
}
