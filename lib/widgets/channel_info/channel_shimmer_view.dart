import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ChannelDetailsShimmer extends StatelessWidget {
  const ChannelDetailsShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1024;
    final isTablet = screenWidth > 768 && screenWidth <= 1024;
    final isMobile = screenWidth <= 768;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Shimmer for Banner Image
              AspectRatio(
                aspectRatio: isDesktop ? 16 / 3 : (isTablet ? 16 / 4 : 16 / 5),
                child: Shimmer.fromColors(
                  baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
                  highlightColor:
                      isDark ? Colors.grey[700]! : Colors.grey[100]!,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.grey[300],
                    ),
                  ),
                ),
              ),

              Padding(
                padding: EdgeInsets.all(isMobile ? 12 : 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Shimmer for Profile Image
                        Shimmer.fromColors(
                          baseColor:
                              isDark ? Colors.grey[800]! : Colors.grey[300]!,
                          highlightColor:
                              isDark ? Colors.grey[700]! : Colors.grey[100]!,
                          child: CircleAvatar(
                            backgroundColor: Colors.grey[300],
                            radius: isMobile ? 40 : (isTablet ? 50 : 60),
                          ),
                        ),

                        const SizedBox(width: 16),

                        // Shimmer for Channel Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Shimmer.fromColors(
                                baseColor: isDark
                                    ? Colors.grey[800]!
                                    : Colors.grey[300]!,
                                highlightColor: isDark
                                    ? Colors.grey[700]!
                                    : Colors.grey[100]!,
                                child: Container(
                                  height: 20,
                                  width: 150,
                                  color: Colors.grey[300],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Shimmer.fromColors(
                                baseColor: isDark
                                    ? Colors.grey[800]!
                                    : Colors.grey[300]!,
                                highlightColor: isDark
                                    ? Colors.grey[700]!
                                    : Colors.grey[100]!,
                                child: Container(
                                  height: 16,
                                  width: 200,
                                  color: Colors.grey[300],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Shimmer.fromColors(
                                baseColor: isDark
                                    ? Colors.grey[800]!
                                    : Colors.grey[300]!,
                                highlightColor: isDark
                                    ? Colors.grey[700]!
                                    : Colors.grey[100]!,
                                child: Container(
                                  height: 16,
                                  width: 100,
                                  color: Colors.grey[300],
                                ),
                              ),
                              if (!isMobile) // Shimmer for Subscribe Button
                                Padding(
                                  padding: const EdgeInsets.only(top: 16),
                                  child: Shimmer.fromColors(
                                    baseColor: isDark
                                        ? Colors.grey[800]!
                                        : Colors.grey[300]!,
                                    highlightColor: isDark
                                        ? Colors.grey[700]!
                                        : Colors.grey[100]!,
                                    child: Container(
                                      height: 30,
                                      width: 90,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // Shimmer for Subscribe Button
                    if (isMobile)
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Shimmer.fromColors(
                          baseColor:
                              isDark ? Colors.grey[800]! : Colors.grey[300]!,
                          highlightColor:
                              isDark ? Colors.grey[700]! : Colors.grey[100]!,
                          child: Container(
                            height: 30,
                            width: 90,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
