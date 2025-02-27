import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:youtube/theme/theme_manager.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<YouTubeTheme>(context);
    final isDark = theme.isDarkMode;
    return BottomNavigationBar(
      backgroundColor: theme.scaffoldColor,
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
      onTap: onTap,
      selectedItemColor: isDark ? Colors.white : Colors.black,
      unselectedItemColor: isDark ? Colors.white : Colors.black54,
      selectedLabelStyle: const TextStyle(
        fontSize: 11, // Size for selected label
        fontWeight:
            FontWeight.w500, // Optional: make selected text slightly bold
      ),
      unselectedLabelStyle: const TextStyle(
        fontSize: 11, // Size for unselected label
      ),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.play_circle_outline),
          activeIcon: Icon(Icons.play_circle_filled),
          label: 'Shorts',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.add_circle_outline, size: 40),
          activeIcon: Icon(Icons.add_circle, size: 40),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.subscriptions_outlined),
          activeIcon: Icon(Icons.subscriptions),
          label: 'Subscriptions',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'You',
        ),
      ],
    );
  }
}
