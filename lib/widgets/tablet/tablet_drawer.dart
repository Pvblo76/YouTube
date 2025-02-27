import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:youtube/theme/theme_manager.dart';
import 'package:youtube/view/desktop_shorts.dart';
import 'package:youtube/view/home_page.dart';
import 'package:youtube/widgets/drawer_state.dart';
import 'package:youtube/widgets/tablet/tablet_drawer_items.dart';

class TabletDrawer extends StatefulWidget {
  final String currentPage;
  const TabletDrawer({super.key, this.currentPage = "Home"});

  @override
  State<TabletDrawer> createState() => _TabletDrawerState();
}

class _TabletDrawerState extends State<TabletDrawer> {
  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<YouTubeTheme>(context);
    return Container(
      width: DrawerState.isCollapsed ? 80 : null,
      child: Drawer(
        backgroundColor: theme.scaffoldColor,
        child: Column(
          children: <Widget>[
            const SizedBox(
              height: 10,
            ),
            ..._drawerItems(context),
          ],
        ),
      ),
    );
  }

  void _updateSelectedTab(String tabName) {
    setState(() {
      DrawerState.selectedTab = tabName;
    });
  }

  List<Widget> _drawerItems(BuildContext context) {
    return [
      TabletDrawerItems(
        icon: Icons.home_filled,
        title: 'Home',
        isSelected: DrawerState.selectedTab == 'Home',
        onTap: () {
          _updateSelectedTab('Home');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
        },
      ),
      TabletDrawerItems(
        icon: Icons.play_circle_outline,
        title: 'Shorts',
        isSelected: DrawerState.selectedTab == 'Shorts',
        onTap: () {
          _updateSelectedTab('Shorts');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const DesktopShorts()),
          );
        },
      ),
      TabletDrawerItems(
        icon: Icons.subscriptions_outlined,
        title: 'Subscriptions',
        isSelected: DrawerState.selectedTab == 'Subscriptions',
        onTap: () => _updateSelectedTab('Subscriptions'),
      ),
      TabletDrawerItems(
        image: const CircleAvatar(
          radius: 15,
          backgroundColor: Colors.grey,
          backgroundImage: NetworkImage(
            "assets/images/avatar.jpg",
          ),
        ),
        title: 'You',
        isSelected: DrawerState.selectedTab == 'You',
        onTap: () => _updateSelectedTab('You'),
      ),
    ];
  }
}
