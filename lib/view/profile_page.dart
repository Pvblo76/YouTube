import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:youtube/theme/theme_manager.dart';
import 'package:youtube/view/appbar.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<YouTubeTheme>(context);
    final isDark = theme.isDarkMode;
    return Scaffold(
        backgroundColor: theme.scaffoldColor,
        appBar: const PreferredSize(
            preferredSize: Size.fromHeight(kToolbarHeight),
            child: YoutubeAppBar()),
        body: FutureBuilder(
            future: Future.delayed(const Duration(milliseconds: 800)),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isDark ? Colors.grey.shade700 : Colors.black54,
                    ),
                  ),
                );
              }
              return const Center(
                child: Text("Profile Page"),
              );
            }));
  }
}
