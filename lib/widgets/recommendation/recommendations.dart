import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:youtube/constants/appcolors.dart';
import 'package:youtube/model/videos_model.dart';
import 'package:youtube/responsive/responsiveness.dart';
import 'package:youtube/theme/theme_manager.dart';
import 'package:youtube/widgets/routes/app_routes.dart';
import 'package:youtube/widgets/routes/routes.dart';

class Recommendations extends StatefulWidget {
  final Video video;
  final String channelId;
  final String durrations;
  final String title;
  final String channel;
  final String views;
  final String publishTime;
  final String thumbnail;
  final String subscribers;
  const Recommendations(
      {super.key,
      required this.subscribers,
      required this.title,
      required this.channel,
      required this.views,
      required this.publishTime,
      required this.thumbnail,
      required this.durrations,
      required this.video,
      required this.channelId});

  @override
  State<Recommendations> createState() => _RecommendationsState();
}

class _RecommendationsState extends State<Recommendations> {
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
    final bool isTablet = Responsive.isTablet(context);
    final bool isDesktop = Responsive.isDesktop(context);
    final theme = Provider.of<YouTubeTheme>(context);
    return Row(
      children: [
        Container(
          //  color: Colors.yellow,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Stack(children: [
              ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                    onTap: () {
                      Navigator.pushReplacementNamed(
                        context,
                        RouteNames.videoPlay,
                        arguments: VideoPlayArgs(
                          channelId: widget.channelId,
                          video: widget.video,
                        ),
                      );
                    },
                    child: CachedNetworkImage(
                        imageUrl: widget.thumbnail,
                        width: 200,
                        height: 100,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.grey.shade500),
                              ),
                            ),
                        errorWidget: (context, url, error) => Container(
                              color: Colors.grey[200],
                              child: Center(
                                child: Icon(
                                  Icons.play_circle_outline,
                                  size: 48,
                                  color: Colors.grey[400],
                                ),
                              ),
                            )),
                  )),
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
            ]),
          ),
        ),
        Expanded(
          flex: 5,
          child: Container(
            //   color: Colors.blueAccent,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  widget.title,
                  style: GoogleFonts.roboto(
                      color: theme.titleColor,
                      fontSize: _getResponsiveFontSize(context, base: 16),
                      fontWeight: FontWeight.w500),
                ),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        widget.channel,
                        style: GoogleFonts.roboto(
                          color: Colors.grey,
                          fontSize: _getResponsiveFontSize(context, base: 14),
                        ),
                      ),
                    ),
                    _isVerified(widget.subscribers)
                        ? Padding(
                            padding: const EdgeInsets.only(left: 4.0),
                            child: Icon(
                              Icons.check_circle,
                              size: 14,
                              color: theme.verifiedIconColor,
                            ),
                          )
                        : const SizedBox.shrink(),
                  ],
                ),
                Text(
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  '${widget.views} • ${widget.publishTime}',
                  style: GoogleFonts.roboto(
                    color: Colors.grey,
                    fontSize: _getResponsiveFontSize(context, base: 14),
                  ),
                )
              ],
            ),
          ),
        ),
        const Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Icon(Icons.more_vert),
            ],
          ),
        ),
        isTablet
            ? const SizedBox(
                width: 30,
              )
            : isDesktop
                ? const SizedBox(
                    width: 40,
                  )
                : const SizedBox(
                    width: 0,
                  ),
      ],
    );
  }

  // Helper method to calculate responsive font sizes
  double _getResponsiveFontSize(BuildContext context, {required double base}) {
    if (Responsive.isTablet(context)) return base - 2;
    return base - 2; // Desktop
  }
}
