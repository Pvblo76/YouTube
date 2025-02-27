import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:youtube/theme/theme_manager.dart';

class AnimatedThemeWrapper extends StatelessWidget {
  final Widget child;

  const AnimatedThemeWrapper({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final youtubeTheme = Provider.of<YouTubeTheme>(context);

    return AnimatedTheme(
      data: youtubeTheme.theme,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        color: youtubeTheme.scaffoldColor,
        child: child,
      ),
    );
  }
}
