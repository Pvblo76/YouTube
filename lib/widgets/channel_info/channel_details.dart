import 'package:country_picker/country_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:youtube/responsive/responsiveness.dart';
import 'package:youtube/theme/theme_manager.dart';
import 'package:youtube/widgets/routes/app_routes.dart';
import 'package:youtube/widgets/routes/routes.dart';
import 'package:youtube/widgets/subscribe/subscribe_button.dart';

class ChannelDetails extends StatefulWidget {
  final String name;
  final String descriptions;
  final String banner;
  final String logo;
  final String subscriber;
  final String videocount;
  final String viewcount;
  final String country;
  const ChannelDetails(
      {super.key,
      required this.viewcount,
      required this.videocount,
      required this.descriptions,
      required this.banner,
      required this.logo,
      required this.name,
      required this.subscriber,
      required this.country});

  @override
  State<ChannelDetails> createState() => _ChannelDetailsState();
}

class _ChannelDetailsState extends State<ChannelDetails> {
  ScrollController _scrollController = ScrollController();

  String getCountryName(String code) {
    final country = Country.tryParse(code); // Get the Country object
    return country?.name ?? ""; // Fallback if the code is invalid
  }

  // Helper function to ensure complete banner URL
  String _buildResizedBannerUrl(String originalUrl, double width) {
    try {
      // Remove existing width parameters if present
      final baseUrl = originalUrl.split('=w')[0];

      // Construct new URL with specific width
      return '$baseUrl=w${width.toInt()}-fcrop64=1,00000000ffffffff-k-c0xffffffff-no-nd-rj';
    } catch (e) {
      print('URL processing error: $e');
      return originalUrl;
    }
  }

  double _determineBannerWidth(BoxConstraints constraints) {
    if (kIsWeb) {
      // More granular width selection
      if (constraints.maxWidth > 2120) return 2560.0;
      if (constraints.maxWidth > 1707) return 2276.0;
      if (constraints.maxWidth > 1388) return 2120.0;
      if (constraints.maxWidth > 1280) return 1707.0;
      if (constraints.maxWidth > 1138) return 1280.0; // Adjusted
      if (constraints.maxWidth > 1060) return 1138.0;
      return 1060.0;
    } else {
      // Mobile sizing
      if (constraints.maxWidth > 1280) return 1440.0;
      if (constraints.maxWidth > 960) return 1280.0;
      if (constraints.maxWidth > 640) return 960.0;
      if (constraints.maxWidth > 320) return 640.0;
      return 320.0;
    }
  }

  Widget buildBannerImage(double aspectRatio, BoxConstraints constraints) {
    final isMobile = Responsive.isMobile(context);
    final bannerWidth = _determineBannerWidth(constraints);
    print(
        'constraints.maxWidth Screen Width: ${constraints.maxWidth}'); // Debug print
    print('Selected Banner Width: $bannerWidth'); // Debug print

    return AspectRatio(
      aspectRatio: aspectRatio,
      child: ClipRRect(
        borderRadius: isMobile ? BorderRadius.circular(15) : BorderRadius.zero,
        child: Container(
          width: bannerWidth, // Add the width here
          decoration: BoxDecoration(
            color: Colors.grey[200], // Fallback color
          ),
          child: widget.banner.isEmpty
              ? Center(
                  child: Icon(
                    Icons.image_not_supported,
                    color: Colors.grey[400],
                    size: 40,
                  ),
                )
              : Image.network(
                  _buildResizedBannerUrl(widget.banner, bannerWidth),
                  width: bannerWidth, // Also set width for the image
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: bannerWidth,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.grey[200],
                      ),
                      child: Center(
                        child: Icon(
                          Icons.error_outline,
                          color: Colors.grey[400],
                          size: 40,
                        ),
                      ),
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.grey.shade500,
                        ),
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                ),
        ),
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

  Widget _channelNameWithBadge(BuildContext context) {
    final theme = Provider.of<YouTubeTheme>(context);
    final isMobile = Responsive.isMobile(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: widget.name,
                  style: GoogleFonts.roboto(
                    color: theme.titleColor,
                    fontSize: isMobile ? 18 : 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_isVerified(widget.subscriber))
                  WidgetSpan(
                    child: Padding(
                      padding:
                          EdgeInsets.only(left: 4.0, bottom: isMobile ? 2 : 5),
                      child: Icon(
                        Icons.check_circle,
                        size: isMobile ? 14 : 18,
                        color: theme.verifiedIconColor,
                      ),
                    ),
                  ),
              ],
            ),
            maxLines: isMobile ? 2 : 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // Helper function to get first 10 words
  String getFirst12Words(String text) {
    final words = text.split(' ');
    if (words.length <= 12) return text;
    return words.take(12).join(' ');
  }

  void _showDescriptionDialog() {
    final theme = Provider.of<YouTubeTheme>(context);
    final isDark = theme.isDarkMode;
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Container();
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return StatefulBuilder(
          builder: (context, setState) {
            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                ),
                child: Dialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: FutureBuilder(
                    // Simulating data loading with a delay
                    future: Future.delayed(const Duration(milliseconds: 800)),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Container(
                          width: 600,
                          padding: const EdgeInsets.symmetric(
                            vertical: 40,
                            horizontal: 20,
                          ),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.grey[900] : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                height: 40,
                                width: 40,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    isDark
                                        ? Colors.grey.shade700
                                        : Colors.black54,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Loading...',
                                style: GoogleFonts.roboto(
                                  fontSize: 16,
                                  color:
                                      isDark ? Colors.white : Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return Container(
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey[900] : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.only(
                            left: 20, top: 20, bottom: 20),
                        width: 600,
                        child: ScrollConfiguration(
                          // Add this wrapper
                          behavior: ScrollConfiguration.of(context).copyWith(
                            scrollbars: false, // Hide default scrollbar
                          ),
                          child: RawScrollbar(
                            thumbColor: isDark
                                ? Colors.grey[300]
                                : Colors.black.withOpacity(0.2),
                            radius: Radius.zero,
                            thickness: 10,
                            minThumbLength: 20,
                            thumbVisibility: true,
                            trackVisibility: false,
                            pressDuration: Duration
                                .zero, // Instant thumb appearance on press
                            fadeDuration: const Duration(
                                milliseconds: 300), // Smooth fade animation
                            interactive: true,
                            controller: _scrollController,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'About',
                                          style: GoogleFonts.roboto(
                                            fontSize: 20,
                                            color: theme.titleColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        MouseRegion(
                                          cursor: SystemMouseCursors.click,
                                          child: GestureDetector(
                                            onTap: () => Navigator.pop(context),
                                            child: Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(50),
                                                color: isDark
                                                    ? Colors.black
                                                    : Colors.grey[100],
                                              ),
                                              child: Icon(
                                                CupertinoIcons.multiply,
                                                size: 16,
                                                color: isDark
                                                    ? Colors.white
                                                    : Colors.grey[700],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Flexible(
                                    child: SingleChildScrollView(
                                  controller: _scrollController,
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 20),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          widget.descriptions,
                                          style: GoogleFonts.roboto(
                                            fontSize: 14,
                                            height: 1.5,
                                            color: isDark
                                                ? Colors.white
                                                : Colors.grey[800],
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          "Channel Details",
                                          style: GoogleFonts.roboto(
                                              fontSize: 14,
                                              color: theme.titleColor,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Row(
                                          children: [
                                            Icon(
                                              CupertinoIcons.globe,
                                              color: isDark
                                                  ? Colors.white
                                                  : Colors.grey[800],
                                            ),
                                            const SizedBox(
                                              width: 8,
                                            ),
                                            Text(
                                                "www.youtube.com/@${widget.name}",
                                                style: const TextStyle(
                                                    color: Color.fromARGB(
                                                        255, 18, 107, 180)))
                                          ],
                                        ), // Website

                                        const SizedBox(
                                          height: 10,
                                        ),

                                        _channelInfo(
                                            Icon(
                                              Icons
                                                  .person_add_alt_outlined, // Updated icon for subscribers
                                              color: isDark
                                                  ? Colors.white
                                                  : Colors.grey[800],
                                            ),
                                            "${widget.subscriber} subscribers"), // Subscribers

                                        const SizedBox(
                                          height: 10,
                                        ),

                                        _channelInfo(
                                            Icon(
                                              Icons
                                                  .play_circle_fill_outlined, // Updated icon for videos
                                              color: isDark
                                                  ? Colors.white
                                                  : Colors.grey[800],
                                            ),
                                            "${widget.videocount} videos"), // Video count

                                        const SizedBox(
                                          height: 10,
                                        ),

                                        _channelInfo(
                                            Icon(
                                              Icons
                                                  .trending_up, // Updated icon for views
                                              color: isDark
                                                  ? Colors.white
                                                  : Colors.grey[800],
                                            ),
                                            "${widget.viewcount} views"), // View count

                                        const SizedBox(
                                          height: 10,
                                        ),

                                        _channelInfo(
                                            Icon(
                                              Icons
                                                  .public_outlined, // Updated icon for country
                                              color: isDark
                                                  ? Colors.white
                                                  : Colors.grey[800],
                                            ),
                                            getCountryName(
                                                widget.country)), // Country

                                        const SizedBox(
                                          height: 10,
                                        ),
                                      ],
                                    ),
                                  ),
                                ))
                                // _channelInfo(Icon(Icons.access_alarm_sharp),
                                //     widget.subscriber),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1024;
    final isTablet = screenWidth > 768 && screenWidth <= 1024;
    final isMobile = screenWidth <= 768;
    final theme = Provider.of<YouTubeTheme>(context);
    final isDark = theme.isDarkMode;
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Banner Image
              // ChannelBannerImage(
              //   bannerUrl: widget.banner,
              // ),
              buildBannerImage(
                  isDesktop ? 16 / 3 : (isTablet ? 16 / 4 : 16 / 5),
                  constraints),
              // Channel Info Section
              Padding(
                padding: EdgeInsets.all(isMobile ? 12 : 20),
                child: Column(
                  children: [
                    // Profile Section
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.grey.shade300,
                          radius: isMobile ? 40 : (isTablet ? 50 : 60),
                          backgroundImage: NetworkImage(
                            widget.logo,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _channelNameWithBadge(context),
                              const SizedBox(height: 8),
                              Wrap(
                                children: [
                                  Text(
                                    "@${widget.name}",
                                    style: GoogleFonts.roboto(
                                        fontSize: isMobile ? 12 : 14,
                                        fontWeight: FontWeight.w500,
                                        color: theme.titleColor),
                                  ),
                                  Text(
                                    " • ${widget.subscriber} subscribers • ${widget.videocount} videos",
                                    style: GoogleFonts.roboto(
                                      fontSize: isMobile ? 12 : 14,
                                      color: isDark
                                          ? Colors.grey[300]
                                          : Colors.grey.shade700,
                                    ),
                                  ),
                                ],
                              ),
                              // Description Section
                              Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: InkWell(
                                  onTap: () {
                                    if (isMobile) {
                                      Navigator.pushNamed(
                                          context, RouteNames.about,
                                          arguments: Aboutchannle(
                                              name: widget.name,
                                              description: widget.descriptions,
                                              subscriber: widget.subscriber,
                                              videocount: widget.videocount,
                                              viewcount: widget.viewcount,
                                              country: widget.country));
                                    } else {
                                      _showDescriptionDialog();
                                    }
                                  },
                                  child: RichText(
                                    text: TextSpan(
                                      style: GoogleFonts.roboto(
                                        fontSize: isMobile ? 12 : 14,
                                        color: Colors.grey[700],
                                      ),
                                      children: [
                                        TextSpan(
                                            text:
                                                "${getFirst12Words(widget.descriptions)} ...",
                                            style: TextStyle(
                                                color: isDark
                                                    ? Colors.grey[400]
                                                    : Colors.grey[700])),
                                        TextSpan(
                                          text: "more",
                                          style: TextStyle(
                                            color: theme.titleColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),

                              if (!isMobile) const SubscribeButton(),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // Mobile Subscribe Button
                    if (isMobile)
                      const Padding(
                        padding: EdgeInsets.only(top: 16),
                        child: SizedBox(
                          width: double.infinity,
                          child: SubscribeButton(),
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

  Widget _channelInfo(Widget icon, String title) {
    final theme = Provider.of<YouTubeTheme>(context);
    final isDark = theme.isDarkMode;
    return Row(
      children: [
        icon,
        const SizedBox(
          width: 10,
        ),
        Text(
          title,
          style: GoogleFonts.roboto(
            fontSize: 14,
            color: isDark ? Colors.white : Colors.grey[800],
          ),
        ),
      ],
    );
  }
}
