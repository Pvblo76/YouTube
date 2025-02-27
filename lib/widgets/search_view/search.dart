// ignore: unnecessary_import
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:youtube/constants/appcolors.dart';
import 'package:youtube/constants/localizations.dart';
import 'package:youtube/model/videos_model.dart';
import 'package:youtube/network/response/api_status.dart';

import 'package:youtube/provider/search_provider.dart';
import 'package:youtube/responsive/responsiveness.dart';
import 'package:youtube/theme/theme_manager.dart';
import 'package:youtube/widgets/Exceptions/Api_quota_exception.dart';
import 'package:youtube/widgets/Exceptions/offline_exception.dart';
import 'package:youtube/view/appbar.dart';
import 'package:youtube/view/channel_page.dart';
import 'package:youtube/view/video_details_page.dart';
import 'package:youtube/widgets/CircleAvatar/Custome_circle_avatar.dart';
import 'package:youtube/widgets/Exceptions/thumbnail_error.dart';
import 'package:youtube/widgets/desktop/desktop_drawers.dart';
import 'package:youtube/widgets/home/feed.dart';
import 'package:youtube/widgets/home/home_feed_shimmer_effect.dart';
import 'package:youtube/widgets/mobile/mobile_drawer.dart';
import 'package:youtube/widgets/search_view/mobile_search_bar.dart';
import 'package:youtube/widgets/search_view/search_web_shimmer.dart';
import 'package:youtube/widgets/tablet/tablet_drawer.dart';

class SearchView extends StatefulWidget {
  final String Query;
  SearchView({Key? key, required this.Query}) : super(key: key);

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  ScrollController _scrollController = ScrollController();
  bool isFetchingMore = false;

  @override
  void initState() {
    super.initState();
    final searchProvider = Provider.of<SearchProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      searchProvider.search(widget.Query);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = Responsive.isDesktop(context);
    final bool isMobile = Responsive.isMobile(context);
    final bool isTablet = Responsive.isTablet(context);
    final Size size = MediaQuery.of(context).size;
    print("Searh View Query : ${widget.Query}");
    final theme = Provider.of<YouTubeTheme>(context);
    final isDark = theme.isDarkMode;
    return Scaffold(
      backgroundColor: theme.scaffoldColor,
      drawer: isMobile
          ? const MobileDrawer()
          : isTablet
              ? const TabletDrawer()
              : null,
      appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: isMobile
              ? MobileSearchBar(query: widget.Query)
              : YoutubeAppBar(
                  initialQuery: widget.Query,
                )),
      body: Row(
        children: [
          if (isDesktop)
            Container(
              decoration: BoxDecoration(
                color: theme.scaffoldColor,
                borderRadius: BorderRadius.zero,
              ),
              width: size.width * 0.15,
              child: const DeskTopDrawer(
                currentPage: 'Home',
              ),
            ),
          if (isTablet)
            Container(
              width: size.width * 0.1,
              color: theme.scaffoldColor,
              child: const TabletDrawer(),
            ),
          Expanded(
            child: Consumer<SearchProvider>(
              builder: (context, value, child) {
                // Handle different states
                if (value.searchResponse.status == ApiStatus.Loading) {
                  return isMobile
                      ? _homefeedLoading()
                      : const SearchShimmerEffect();
                }

                if (value.searchResponse.status == ApiStatus.Error) {
                  // Handle quota exceeded error
                  if (value.searchResponse.message
                      .toString()
                      .contains('quota')) {
                    return const QuotaExceededErrorPage();
                  }
                  // Handle no internet connection error
                  if (value.searchResponse.message
                      .toString()
                      .contains('Error During Communication')) {
                    return const NoInternetPage();
                  }
                  // Handle other errors
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 48,
                          color: isDark ? Colors.grey[400] : Colors.grey[700],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          value.searchResponse.message.toString(),
                          textAlign: TextAlign.center,
                          style: GoogleFonts.roboto(
                            fontSize: 16,
                            color: isDark ? Colors.grey[300] : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Handle successful data load
                return ScrollConfiguration(
                    // Add this wrapper
                    behavior: ScrollConfiguration.of(context).copyWith(
                      scrollbars: false, // Hide default scrollbar
                    ),
                    child: RawScrollbar(
                      thumbColor: isDark
                          ? Colors.grey[300]
                          : Colors.black.withOpacity(0.2),
                      radius: Radius.zero,
                      thickness: 15,
                      minThumbLength: 50,
                      thumbVisibility: !isMobile,
                      trackVisibility: !isMobile,
                      pressDuration:
                          Duration.zero, // Instant thumb appearance on press
                      fadeDuration: const Duration(
                          milliseconds: 300), // Smooth fade animation
                      interactive: true,
                      controller: _scrollController,
                      child: NotificationListener<ScrollNotification>(
                        onNotification: (scrollInfo) {
                          if (!value.isLoadingMore &&
                              value.hasMoreResults &&
                              scrollInfo.metrics.pixels ==
                                  scrollInfo.metrics.maxScrollExtent) {
                            value.loadMore();
                          }
                          return true;
                        },
                        child: ListView.builder(
                          controller: _scrollController,
                          itemCount: value.searchResults.length +
                              (value.isLoadingMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == value.searchResults.length) {
                              return value.isLoadingMore
                                  ? Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          strokeWidth: 3,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                            isDark
                                                ? Colors.grey.shade700
                                                : Colors.black54,
                                          ),
                                        ),
                                      ),
                                    )
                                  : const SizedBox.shrink();
                            }
                            final result = value.searchResults[index];
                            return _buildSearchResultItem(context, result);
                          },
                        ),
                      ),
                    ));
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResultItem(BuildContext context, Video video) {
    final bool isMobile = Responsive.isMobile(context);

    final Size size = MediaQuery.of(context).size;

    double thumbnailWidth = size.width * 0.4; // 40% of screen width
    // Set minimum and maximum width constraints
    if (thumbnailWidth > 500) thumbnailWidth = 500; // Max width
    if (thumbnailWidth < 160) thumbnailWidth = 160; // Min width

    print("Screen Widht : ${size.width}");
    return Padding(
        padding: EdgeInsets.only(top: 15, bottom: 8, left: !isMobile ? 10 : 0),
        child: !isMobile
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Thumbnail section
                  Container(
                    width: thumbnailWidth,
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    child: Stack(
                      children: [
                        AspectRatio(
                          aspectRatio: 16 / 9,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => VideoPlayPage(
                                            video: video,
                                            id: video.snippet!.channelId!)));
                              },
                              child: CustomVideoThumbnail(
                                isMobile: false,
                                thumbnailUrl:
                                    video.snippet!.thumbnails!.maxres != null
                                        ? video.snippet!.thumbnails!.maxres!.url
                                            .toString()
                                        : video.snippet!.thumbnails!.high!.url
                                            .toString(),
                              ),
                            ),
                            // child: Container(
                            //     color: Colors.grey[300],
                            //     child: InkWell(
                            //       onTap: () {
                            //         Navigator.push(
                            //             context,
                            //             MaterialPageRoute(
                            //                 builder: (context) => VideoPlayPage(
                            //                     video: video,
                            //                     id: video
                            //                         .snippet!.channelId!)));
                            //       },
                            //       child: Image.network(
                            //         video.snippet!.thumbnails!.maxres != null
                            //             ? video.snippet!.thumbnails!.maxres!.url
                            //                 .toString()
                            //             : video.snippet!.thumbnails!.high!.url
                            //                 .toString(),
                            //         fit: BoxFit.cover,
                            //       ),
                            //     )),
                          ),
                        ),
                        Positioned(
                          bottom: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.7),
                              borderRadius:
                                  BorderRadius.circular(4), // Rounded corners
                            ),
                            child: Text(
                              Formates().videoDurations(
                                  video.contentDetails!.duration.toString()),
                              style: GoogleFonts.roboto(
                                color: AppColors.white,
                                fontWeight: FontWeight.w500,
                                fontSize: 12, // Adjust font size as needed
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: _buildWideScreenDetails(context, video),
                  )
                ],
              )
            : _buildMobileDetails(context, video));
  }

  Widget _buildWideScreenDetails(BuildContext context, Video video) {
    final theme = Provider.of<YouTubeTheme>(context);
    final isDark = theme.isDarkMode;
    return Padding(
      padding: const EdgeInsets.only(right: 24, top: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    video.snippet!.title.toString(),
                    style: GoogleFonts.roboto(
                      color: isDark ? Colors.white : Colors.black,
                      fontSize: _getResponsiveFontSize(context, base: 16),
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(
                  Icons.more_vert,
                  size: 20,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${Formates().formatViewCount(video.statistics!.viewCount.toString())} • ${Formates().timeAgo(video.snippet!.publishedAt.toString())}',
            style: TextStyle(
              color: isDark ? Colors.grey[200] : Colors.grey[600],
              fontSize: _getResponsiveFontSize(context, base: 14),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              ChannelPage(id: video.channelDetails!.id!)));
                },
                child: CustomCircleAvatar(
                  avatarUrl: video.channelDetails!.snippet!.thumbnails!
                      .defaultThumbnail!.url
                      .toString(),
                  isMobile: false,
                ),
                // child: CircleAvatar(
                //     radius: 15,
                //     backgroundColor: Colors.grey[400],
                //     backgroundImage: NetworkImage(video.channelDetails!.snippet!
                //         .thumbnails!.defaultThumbnail!.url
                //         .toString())),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              ChannelPage(id: video.channelDetails!.id!)));
                },
                child: Text(
                  video.snippet!.channelTitle.toString(),
                  style: GoogleFonts.roboto(
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    fontSize: _getResponsiveFontSize(context, base: 14),
                  ),
                ),
              ),
              // if (result['isVerified'] == "true")
              _isVerified(video.channelDetails!.statistics!.subscriberCount
                      .toString())
                  ? Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Icon(
                        Icons.check_circle,
                        size: 14,
                        color: theme.verifiedIconColor,
                      ),
                    )
                  : const SizedBox.shrink(),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: Text(
              video.snippet!.description.toString(),
              style: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
                fontSize: _getResponsiveFontSize(context, base: 12),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[900] : Colors.grey[200],
              borderRadius: BorderRadius.circular(2),
            ),
            child: Text(
              '4K',
              style: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.grey[700],
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileDetails(BuildContext context, Video video) {
    return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: HomeFeed(
            video: video,
            channelId: video.snippet!.channelId!,
            title: video.snippet!.title.toString(),
            channel: video.snippet!.channelTitle.toString(),
            views: Formates()
                .formatViewCount(video.statistics!.viewCount.toString()),
            publishTime:
                Formates().timeAgo(video.snippet!.publishedAt.toString()),
            thumbnail: video.snippet!.thumbnails!.maxres != null
                ? video.snippet!.thumbnails!.maxres!.url.toString()
                : video.snippet!.thumbnails!.high!.url.toString(),
            avator: video
                .channelDetails!.snippet!.thumbnails!.defaultThumbnail!.url
                .toString(),
            durrations: Formates()
                .videoDurations(video.contentDetails!.duration.toString())));
  }

  // if the Channel has Enough Subscribers then put a check mark on it
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

  Widget _homefeedLoading() {
    return ListView.builder(
        itemCount: 5,
        itemBuilder: (context, index) {
          return const ShimmerLoading();
        });
  }

  // Helper method to calculate responsive font sizes
  double _getResponsiveFontSize(BuildContext context, {required double base}) {
    if (Responsive.isTablet(context)) return base - 2;
    return base - 2; // Desktop
  }
}
