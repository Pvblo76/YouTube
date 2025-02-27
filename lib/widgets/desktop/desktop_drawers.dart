import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:youtube/theme/theme_manager.dart';
import 'package:youtube/view/desktop_shorts.dart';
import 'package:youtube/view/home_page.dart';
import 'package:youtube/widgets/desktop/desktop_drawer_items.dart';
import 'package:youtube/widgets/drawer_state.dart';

class DeskTopDrawer extends StatefulWidget {
  final String currentPage;
  final Widget? header;
  const DeskTopDrawer({
    super.key,
    this.currentPage = 'Home',
    this.header,
  });

  @override
  State<DeskTopDrawer> createState() => _DeskTopDrawerState();
}

class _DeskTopDrawerState extends State<DeskTopDrawer> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    DrawerState.selectedTab = widget.currentPage;
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
          //    _buildHeader(),
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
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10, left: 10),
                        child: widget.header,
                      ),
                      _buildMainSection(),
                      Divider(
                        color: isDark ? Colors.grey[600] : Colors.grey[300],
                      ),
                      _buildYouSection(),
                      Divider(
                        color: isDark ? Colors.grey[600] : Colors.grey[300],
                      ),
                      _buildSubscriptionsSection(),
                      Divider(
                        color: isDark ? Colors.grey[600] : Colors.grey[300],
                      ),
                      _buildExploreSection(),
                      Divider(
                        color: isDark ? Colors.grey[600] : Colors.grey[300],
                      ),
                      _buildMoreFromYouTubeSection(),
                      Divider(
                        color: isDark ? Colors.grey[600] : Colors.grey[300],
                      ),
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

  Widget _buildMainSection() {
    return Column(
      children: [
        DrawerItems(
          icon: Icons.home_filled,
          title: 'Home',
          isSelected: DrawerState.selectedTab == 'Home',
          onTap: () => _navigateTo(const HomePage(), 'Home'),
        ),
        DrawerItems(
          icon: Icons.play_circle_outline,
          title: 'Shorts',
          isSelected: DrawerState.selectedTab == 'Shorts',
          onTap: () => _navigateTo(const DesktopShorts(), 'Shorts'),
        ),
        DrawerItems(
          icon: Icons.subscriptions_outlined,
          title: 'Subscriptions',
          isSelected: DrawerState.selectedTab == 'Subscriptions',
          onTap: () => _updateSelectedTab('Subscriptions'),
        ),
      ],
    );
  }

  Widget _buildYouSection() {
    final theme = Provider.of<YouTubeTheme>(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Text(
            'You',
            style: GoogleFonts.roboto(
              fontSize: 16,
              color: theme.titleColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        DrawerItems(
          icon: Icons.account_box_outlined,
          title: 'Your channel',
          isSelected: DrawerState.selectedTab == 'Your channel',
          onTap: () => _updateSelectedTab('Your channel'),
        ),
        DrawerItems(
          icon: Icons.history,
          title: 'History',
          isSelected: DrawerState.selectedTab == 'History',
          onTap: () => _updateSelectedTab('History'),
        ),
        DrawerItems(
          icon: Icons.video_library_outlined,
          title: 'Your videos',
          isSelected: DrawerState.selectedTab == 'Your videos',
          onTap: () => _updateSelectedTab('Your videos'),
        ),
        DrawerItems(
          icon: Icons.watch_later_outlined,
          title: 'Watch later',
          isSelected: DrawerState.selectedTab == 'Watch later',
          onTap: () => _updateSelectedTab('Watch later'),
        ),
        DrawerItems(
          icon: Icons.playlist_play,
          title: 'Playlists',
          isSelected: DrawerState.selectedTab == 'Playlists',
          onTap: () => _updateSelectedTab('Playlists'),
        ),
      ],
    );
  }

  Widget _buildSubscriptionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Text(
            'Subscriptions',
            style: GoogleFonts.roboto(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        _buildSubscriptionItem(
          'The Tech Brothers',
          'assets/images/brothers.jpg',
        ),
        _buildSubscriptionItem(
          'MIT OpenCourseWare',
          'assets/images/mit.jpg',
        ),
        _buildSubscriptionItem(
          'dbestech',
          'assets/images/dbestech.jpg',
        ),
        _buildSubscriptionItem(
          'Flutter Guys',
          'assets/images/fluter_guys.jpg',
        ),
        DrawerItems(
          icon: Icons.keyboard_arrow_down,
          title: 'Show more',
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildExploreSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Text(
            'Explore',
            style: GoogleFonts.roboto(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Text(
            'More from YouTube',
            style: GoogleFonts.roboto(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
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

  Widget _buildSubscriptionItem(String title, String imagePath) {
    return DrawerItems(
      image: CircleAvatar(
        radius: 12,
        backgroundColor: Colors.grey[300],
        backgroundImage: AssetImage(imagePath),
      ),
      title: title,
      isSelected: DrawerState.selectedTab == title,
      onTap: () => _updateSelectedTab(title),
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
    setState(() {
      DrawerState.selectedTab = tabName;
    });
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
