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

class HomeFeed extends StatefulWidget {
  final Video video;
  final String channelId;
  final String title;
  final String channel;
  final String views;
  final String publishTime;
  final String thumbnail;
  final String avator;
  final String durrations;
  final String? subscribers;
  const HomeFeed({
    super.key,
    required this.title,
    required this.channel,
    required this.views,
    required this.publishTime,
    required this.thumbnail,
    required this.avator,
    required this.durrations,
    this.subscribers,
    required this.video,
    required this.channelId,
  });

  @override
  State<HomeFeed> createState() => _HomeFeedState();
}

class _HomeFeedState extends State<HomeFeed> {
  ImageProvider? _avatarImage;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadAvatarImage();
  }

  void _loadAvatarImage() {
    _avatarImage = NetworkImage(widget.avator)
      ..resolve(ImageConfiguration()).addListener(
        ImageStreamListener(
          (info, call) {
            if (mounted) {
              setState(() {
                _hasError = false;
              });
            }
          },
          onError: (exception, stackTrace) {
            if (mounted) {
              setState(() {
                _hasError = true;
              });
            }
          },
        ),
      );
  }

  Widget _buildAvatar(bool isMobile) {
    final double size = isMobile ? 50.0 : 40.0;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey[200],
      ),
      clipBehavior: Clip.antiAlias, // Ensures perfect circular clipping
      child: _hasError
          ? Center(
              child: Icon(
                Icons.account_circle,
                size: size,
                color: Colors.grey[400],
              ),
            )
          : Image(
              image: _avatarImage ?? NetworkImage(widget.avator),
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Center(
                  child: Icon(
                    Icons.account_circle,
                    size: size,
                    color: Colors.grey[400],
                  ),
                );
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: SizedBox(
                    width:
                        size * 0.5, // Make loader slightly smaller than avatar
                    height: size * 0.5,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.grey.shade500,
                      ),
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                      strokeWidth: 2,
                    ),
                  ),
                );
              },
            ),
    );
  }

  bool _isVerified(String subscribers) {
    try {
      // Remove non-numeric characters (e.g., "K", ",") and parse to number
      String cleanValue = subscribers.replaceAll(RegExp(r'[^\d.]'), '');
      double numericValue = double.parse(cleanValue);

      // Handle "K" (thousands) multiplier
      if (subscribers.contains('K')) numericValue *= 1000;
      if (subscribers.contains('M')) numericValue *= 1000000;

      return numericValue > 100000;
    } catch (e) {
      // Handle parsing errors
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<YouTubeTheme>(context);
    final isDark = theme.isDarkMode;
    final bool isMobile = Responsive.isMobile(context);
    final bool isDesktop = Responsive.isDesktop(context);

    // Calculate the available width for the video
    double availableWidth = MediaQuery.of(context).size.width;
    double availablehieght = MediaQuery.of(context).size.height;
    print(" height : ${availablehieght}");
    if (isDesktop) {
      availableWidth = availableWidth * 0.7;
    }

    // Calculate padding based on screen size
    double horizontalPadding = isMobile ? 20 : 8;
    availableWidth -= (horizontalPadding * 2);

    // Calculate constrained box sizes with safety checks
    double avatarMaxWidth = math.max(50, availableWidth * 0.15);
    double actionMaxWidth = math.max(40, availableWidth * 0.1);

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
                      isMobile: isMobile,
                    ),
                  ),
                  // child: Image.network(
                  //   widget.thumbnail,
                  //   fit: BoxFit.cover,
                  // ),
                ),
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
                // Avatar section
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: avatarMaxWidth,
                    minWidth: 50,
                  ),
                  child: Padding(
                    padding: isMobile
                        ? const EdgeInsets.only(top: 4, left: 5)
                        : const EdgeInsets.only(top: 4),
                    child: _buildAvatar(isMobile),
                  ),
                ),

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
                                      _getResponsiveFontSize(context, base: 16),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                maxLines: 2,
                                '${widget.channel} • ${widget.views} • ${widget.publishTime}',
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
                                      _getResponsiveFontSize(context, base: 16),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      widget.channel,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.roboto(
                                        color: theme.channelInfoColor,
                                        fontSize: _getResponsiveFontSize(
                                            context,
                                            base: 14),
                                      ),
                                    ),
                                  ),
                                  _isVerified(widget.subscribers!) && !isMobile
                                      ? Padding(
                                          padding:
                                              const EdgeInsets.only(left: 4.0),
                                          child: Icon(
                                            Icons.check_circle,
                                            size: 14,
                                            color: theme.verifiedIconColor,
                                          ),
                                        )
                                      : SizedBox.shrink(),
                                ],
                              ),
                              const SizedBox(height: 2),
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
    if (Responsive.isMobile(context)) return base - 2;
    if (Responsive.isTablet(context)) return base - 1;
    return base - 1; // Desktop
  }
}
