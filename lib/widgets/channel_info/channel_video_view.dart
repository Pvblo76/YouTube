import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:youtube/constants/appcolors.dart';
import 'package:youtube/model/videos_model.dart';
import 'package:youtube/responsive/responsiveness.dart';
import 'package:youtube/theme/theme_manager.dart';
import 'package:youtube/widgets/Exceptions/thumbnail_error.dart';
import 'package:youtube/widgets/routes/app_routes.dart';
import 'package:youtube/widgets/routes/routes.dart';

class ChannelVideoView extends StatefulWidget {
  final Video video;
  final String channelId;
  final String title;
  final String views;
  final String publishTime;
  final String thumbnail;

  final String durrations;
  const ChannelVideoView(
      {super.key,
      required this.title,
      required this.views,
      required this.publishTime,
      required this.thumbnail,
      required this.durrations,
      required this.video,
      required this.channelId});

  @override
  State<ChannelVideoView> createState() => _ChannelVideoViewState();
}

class _ChannelVideoViewState extends State<ChannelVideoView> {
  @override
  Widget build(BuildContext context) {
    final bool isMobile = Responsive.isMobile(context);
    final bool isDesktop = Responsive.isDesktop(context);

    // Calculate the available width for the video
    double availableWidth = MediaQuery.of(context).size.width;
    if (isDesktop) {
      availableWidth = availableWidth * 0.7;
    }

    // Calculate padding based on screen size
    double horizontalPadding = isMobile ? 20 : 8;
    availableWidth -= (horizontalPadding * 2);

    // Calculate constrained box sizes with safety checks
    math.max(50, availableWidth * 0.15);
    double actionMaxWidth = math.max(40, availableWidth * 0.1);
    final theme = Provider.of<YouTubeTheme>(context);
    final isDark = theme.isDarkMode;

    return Padding(
      padding: isMobile
          ? const EdgeInsets.symmetric(horizontal: 0)
          : EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail with aspect ratio
          Stack(
            children: [
              AspectRatio(
                aspectRatio: 16 / 9, // Standard video aspect ratio
                child: ClipRRect(
                    borderRadius: isMobile
                        ? BorderRadius.circular(0)
                        : BorderRadius.circular(15),
                    child: InkWell(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          RouteNames.videoPlay,
                          arguments: VideoPlayArgs(
                            channelId: widget.channelId,
                            video: widget.video,
                          ),
                        );
                      },
                      child: CustomVideoThumbnail(
                        thumbnailUrl: widget.thumbnail,
                      ),
                    )),
              ),
              Positioned(
                bottom: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4), // Padding inside the container
                  decoration: BoxDecoration(
                    color: Colors.black
                        .withOpacity(0.7), // Semi-transparent background
                    borderRadius: BorderRadius.circular(4), // Rounded corners
                  ),
                  child: Center(
                    child: Text(
                      widget.durrations, // Replace with dynamic video duration
                      style: GoogleFonts.roboto(
                        color: AppColors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 12, // Adjust font size as needed
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          isMobile ? const SizedBox(height: 15) : const SizedBox(height: 8),

          // Details section with responsive layout
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Video details section
                Expanded(
                  flex: 4,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: isMobile
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.title,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                                style: GoogleFonts.roboto(
                                  color: theme.titleColor,
                                  fontSize:
                                      _getResponsiveFontSize(context, base: 15),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                maxLines: 2,
                                '${widget.views} • ${widget.publishTime}',
                                style: GoogleFonts.roboto(
                                  color: theme.channelInfoColor,
                                  fontSize:
                                      _getResponsiveFontSize(context, base: 14),
                                ),
                              )
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.title,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                                style: GoogleFonts.roboto(
                                  color: theme.titleColor,
                                  fontSize:
                                      _getResponsiveFontSize(context, base: 15),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${widget.views} • ${widget.publishTime}',
                                style: GoogleFonts.roboto(
                                  color: theme.channelInfoColor,
                                  fontSize:
                                      _getResponsiveFontSize(context, base: 14),
                                ),
                              ),
                            ],
                          ),
                  ),
                ),

                // Action button
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: actionMaxWidth,
                    minWidth: 40,
                  ),
                  child: Icon(
                    Icons.more_vert,
                    size: 24,
                    color: isDark ? Colors.white : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to calculate responsive font sizes
  double _getResponsiveFontSize(BuildContext context, {required double base}) {
    if (Responsive.isMobile(context)) return base;
    if (Responsive.isTablet(context)) return base - 1;
    return base - 2; // Desktop
  }
}
