import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:youtube/theme/theme_manager.dart';

class SearchShimmerEffect extends StatelessWidget {
  const SearchShimmerEffect({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<YouTubeTheme>(context);
    final isDark = theme.isDarkMode;
    final width = MediaQuery.of(context).size.width;

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Shimmer.fromColors(
            baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
            highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Calculate thumbnail width based on screen width
                double thumbnailWidth = constraints.maxWidth * 0.4;

                // Set minimum and maximum width constraints
                if (thumbnailWidth > 500) thumbnailWidth = 500;
                if (thumbnailWidth < 160) thumbnailWidth = 160;

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Thumbnail shimmer with responsive width
                    Container(
                      width: thumbnailWidth,
                      height:
                          thumbnailWidth * 9 / 16, // maintain 16:9 aspect ratio
                      margin: EdgeInsets.symmetric(
                          horizontal: width > 600 ? 12 : 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),

                    // Content section with responsive spacing
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          right: width > 900 ? 24 : 12,
                          top: width > 600 ? 4 : 0,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title shimmer with responsive height
                            Container(
                              height: width > 600 ? 24 : 20,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            SizedBox(height: width > 600 ? 12 : 8),

                            // Stats shimmer with responsive width
                            Container(
                              height: 16,
                              width: width > 900 ? 300 : 200,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            SizedBox(height: width > 600 ? 12 : 8),

                            // Channel info shimmer with responsive sizing
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: width > 900 ? 18 : 15,
                                  backgroundColor: Colors.white,
                                ),
                                SizedBox(width: width > 600 ? 12 : 8),
                                Container(
                                  height: 16,
                                  width: width > 900 ? 200 : 150,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ],
                            ),

                            if (width > 900) ...[
                              const SizedBox(height: 12),
                              // Description shimmer for desktop
                              Container(
                                height: 16,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              const SizedBox(height: 12),
                              // Tags shimmer for desktop
                              Row(
                                children: [
                                  Container(
                                    height: 20,
                                    width: 40,
                                    margin: const EdgeInsets.only(right: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                  Container(
                                    height: 20,
                                    width: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}
