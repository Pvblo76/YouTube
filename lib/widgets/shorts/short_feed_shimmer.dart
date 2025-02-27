import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:youtube/responsive/responsiveness.dart';
import 'package:youtube/theme/theme_manager.dart';

class ShortFeedShimmer extends StatelessWidget {
  const ShortFeedShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isMobile = Responsive.isMobile(context);
    Size size = MediaQuery.of(context).size;
    final theme = Provider.of<YouTubeTheme>(context);
    final isDark = theme.isDarkMode;
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
      child: Container(
        height: size.height * 0.95,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius:
              isMobile ? BorderRadius.circular(0) : BorderRadius.circular(10),
          color: Colors.grey,
        ),
      ),
    );
  }
}

class SocialButtons extends StatelessWidget {
  final String title;
  final Widget image;
  const SocialButtons({super.key, required this.title, required this.image});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        image,
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
