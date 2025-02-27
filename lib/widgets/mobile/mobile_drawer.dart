import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:youtube/theme/theme_manager.dart';

import 'package:youtube/widgets/desktop/desktop_drawer_items.dart';

class MobileDrawer extends StatefulWidget {
  const MobileDrawer({
    super.key,
  });

  @override
  State<MobileDrawer> createState() => _MobileDrawerState();
}

class _MobileDrawerState extends State<MobileDrawer> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<YouTubeTheme>(context);
    final isDark = theme.isDarkMode;
    return Drawer(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero, // Set border radius to zero
      ),
      backgroundColor: theme.scaffoldColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          Expanded(
            child: ScrollConfiguration(
              // Add this wrapper
              behavior: ScrollConfiguration.of(context).copyWith(
                scrollbars: false, // Hide default scrollbar
              ),
              child: RawScrollbar(
                thumbColor: isDark
                    ? Colors.white.withOpacity(0.4)
                    : Colors.black.withOpacity(0.2),
                radius: Radius.zero,
                thickness: 9,
                minThumbLength: 50,
                thumbVisibility: false,
                trackVisibility: false,
                pressDuration:
                    Duration.zero, // Instant thumb appearance on press
                fadeDuration:
                    const Duration(milliseconds: 300), // Smooth fade animation
                interactive: true,
                controller: _scrollController, // Add this
                child: SingleChildScrollView(
                  controller: _scrollController, // Add this
                  physics: const AlwaysScrollableScrollPhysics(), // Add this
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _buildExploreSection(),
                      Divider(
                        color: isDark ? Colors.grey[600] : Colors.grey[300],
                      ),
                      const SizedBox(height: 16),
                      _buildMoreFromYouTubeSection(),
                      Divider(
                        color: isDark ? Colors.grey[600] : Colors.grey[300],
                      ),
                      const SizedBox(height: 16),
                      _buildSettingsSection(),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final theme = Provider.of<YouTubeTheme>(context);
    final isDark = theme.isDarkMode;
    return Padding(
      padding: const EdgeInsets.only(left: 30, top: 40, bottom: 20),
      child: SizedBox(
        height: 20,
        child: Image.asset(
          isDark ? 'assets/images/yt_logo_dark.png' : 'assets/images/logo.png',
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildExploreSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DrawerItems(
          icon: Icons.local_fire_department_outlined,
          title: 'Trending',
          onTap: () => _updateSelectedTab('Trending'),
        ),
        DrawerItems(
          icon: Icons.shopping_bag_outlined,
          title: 'Shopping',
          onTap: () => _updateSelectedTab('Shopping'),
        ),
        DrawerItems(
          icon: Icons.music_note_outlined,
          title: 'Music',
          onTap: () => _updateSelectedTab('Music'),
        ),
        DrawerItems(
          icon: Icons.movie_outlined,
          title: 'Movies & TV',
          onTap: () => _updateSelectedTab('Movies'),
        ),
        DrawerItems(
          icon: Icons.stream,
          title: 'Live',
          onTap: () => _updateSelectedTab('Live'),
        ),
        DrawerItems(
          icon: Icons.sports_esports_outlined,
          title: 'Gaming',
          onTap: () => _updateSelectedTab('Gaming'),
        ),
      ],
    );
  }

  Widget _buildMoreFromYouTubeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DrawerItems(
          image: Image.asset('assets/icons/youtube.png', height: 24),
          title: 'YouTube Premium',
          onTap: () => _updateSelectedTab('Premium'),
        ),
        DrawerItems(
          image: Image.asset('assets/icons/ytmusic.png', height: 24),
          title: 'YouTube Studio',
          onTap: () => _updateSelectedTab('Studio'),
        ),
        DrawerItems(
          image: Image.asset('assets/icons/ytmusic.png', height: 24),
          title: 'YouTube Music',
          onTap: () => _updateSelectedTab('Music'),
        ),
        DrawerItems(
          image: Image.asset('assets/icons/ytkid.png', height: 24),
          title: 'YouTube Kids',
          onTap: () => _updateSelectedTab('Kids'),
        ),
      ],
    );
  }

  Widget _buildSettingsSection() {
    return Column(
      children: [
        DrawerItems(
          icon: Icons.settings_outlined,
          title: 'Settings',
          onTap: () => _updateSelectedTab('Settings'),
        ),
        AnimatedThemeIcon(onPressed: () {
          context.read<YouTubeTheme>().toggleTheme();
        }),
        DrawerItems(
          icon: Icons.flag_outlined,
          title: 'Report history',
          onTap: () => _updateSelectedTab('Report'),
        ),
        DrawerItems(
          icon: Icons.help_outline,
          title: 'Help',
          onTap: () => _updateSelectedTab('Help'),
        ),
        DrawerItems(
          icon: Icons.feedback_outlined,
          title: 'Send feedback',
          onTap: () => _updateSelectedTab('Feedback'),
        ),
      ],
    );
  }

  void _navigateTo(Widget page, String tabName) {
    _updateSelectedTab(tabName);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  void _updateSelectedTab(String tabName) {
    setState(() {});
  }
}

class AnimatedThemeIcon extends StatelessWidget {
  final VoidCallback onPressed;

  const AnimatedThemeIcon({
    Key? key,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return IconButton(
      onPressed: onPressed,
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return RotationTransition(
            turns: animation,
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          );
        },
        child: Icon(
          isDark ? Icons.wb_sunny_outlined : Icons.brightness_2_outlined,
          key: ValueKey<bool>(isDark),
          color: Theme.of(context).iconTheme.color,
        ),
      ),
    );
  }
}
