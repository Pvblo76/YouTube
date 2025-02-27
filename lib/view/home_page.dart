import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:youtube/constants/localizations.dart';
import 'package:youtube/network/response/api_status.dart';
import 'package:youtube/model/categories.dart';
import 'package:youtube/provider/api_providers.dart';
import 'package:youtube/responsive/responsiveness.dart';
import 'package:youtube/theme/theme_manager.dart';
import 'package:youtube/widgets/Exceptions/Api_quota_exception.dart';
import 'package:youtube/widgets/Exceptions/offline_exception.dart';
import 'package:youtube/view/appbar.dart';

import 'package:youtube/widgets/desktop/desktop_drawers.dart';
import 'package:youtube/widgets/home/feed.dart';
import 'package:youtube/widgets/home/home_feed_shimmer_effect.dart';
import 'package:youtube/widgets/mobile/mobile_drawer.dart';
import 'package:youtube/widgets/categories/secondary_appbar.dart';
import 'package:youtube/widgets/tablet/tablet_drawer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ScrollController _scrollController = ScrollController();
  late int selectedTabIndex;
  String? selectedCategoryId;
  bool isFetchingMore = false;
  String? query;

  @override
  void initState() {
    super.initState();

    // // Initialize with the provider's stored state
    final apiProvider = Provider.of<ApiProviders>(context, listen: false);
    selectedTabIndex = apiProvider.selectedTabIndex;

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (selectedTabIndex > 0) {
        selectedCategoryId = Categories.categoryMap.keys.toList()[
            Responsive.isMobile(context)
                ? selectedTabIndex - 1
                : selectedTabIndex];
      }

      if (apiProvider.shouldReloadVideos(apiProvider.lastQuery)) {
        _fetchVideos(apiProvider.lastQuery);
      }
    });
  }

  void _fetchVideos(String query) {
    Provider.of<ApiProviders>(context, listen: false).fetchVideos(query);
  }

  void _fetchMoreVideos() {
    if (!isFetchingMore) {
      setState(() {
        isFetchingMore = true;
      });
      final apiProvider = Provider.of<ApiProviders>(context, listen: false);
      final fetchFunction = selectedCategoryId == null
          ? apiProvider.fetchMoreVideos(apiProvider.lastQuery)
          : apiProvider.fetchMoreVideos(selectedCategoryId!);
      fetchFunction.then((_) {
        setState(() {
          isFetchingMore = false;
        });
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildScrollableContent() {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        if (scrollInfo.metrics.pixels >=
                scrollInfo.metrics.maxScrollExtent - 100 &&
            !isFetchingMore) {
          _fetchMoreVideos();
        }
        return false;
      },
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          Consumer<ApiProviders>(
            builder: (context, value, child) {
              switch (value.videoResponse.status) {
                case ApiStatus.Loading:
                  return _buildLoadingGrid(
                    Responsive.isMobile(context),
                    Responsive.isTablet(context),
                    Responsive.isDesktop(context),
                  );
                case ApiStatus.Complete:
                  return _buildVideoGrid(
                    value,
                    Responsive.isMobile(context),
                    Responsive.isTablet(context),
                    Responsive.isDesktop(context),
                  );
                case ApiStatus.Error:
                  // Ensure you always return a SliverWidget
                  return SliverToBoxAdapter(
                    child: _buildErrorWidget(value.videoResponse.message),
                  );
                default:
                  return SliverToBoxAdapter(
                    child: Center(
                      child: Text(
                          'Unexpected state: ${value.videoResponse.status}'),
                    ),
                  );
              }
            },
          ),
        ],
      ),
    );
  }

// New error handling method to always return a valid widget
  Widget _buildErrorWidget(dynamic errorMessage) {
    // Check for specific error types
    if (errorMessage.toString().contains('quota')) {
      return const QuotaExceededErrorPage();
    }

    if (errorMessage.toString().contains('Error During Communication')) {
      return const NoInternetPage();
    }

    // Generic error handling
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 60),
          Text(
            'An error occurred',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Text(
            errorMessage.toString(),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<YouTubeTheme>(context);
    final isDark = theme.isDarkMode;
    final bool isMobile = Responsive.isMobile(context);
    final bool isDesktop = Responsive.isDesktop(context);
    final bool isTablet = Responsive.isTablet(context);
    final Size size = MediaQuery.of(context).size;
    // Define the height of the AppBar + SecondaryAppbar
    // print("Screen width : ${screenWidth}");

    return Scaffold(
      backgroundColor: theme.scaffoldColor,
      appBar: const PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight),
          child: Stack(
            children: [
              YoutubeAppBar(),
            ],
          )),
      drawer: isMobile
          ? const MobileDrawer()
          : isTablet
              ? const TabletDrawer()
              : null,
      body: Row(
        children: [
          if (isDesktop)
            Container(
              decoration: BoxDecoration(
                color: theme.scaffoldColor,
                borderRadius: BorderRadius.zero,
                // border: Border
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
            child: Stack(
              children: [
                Padding(
                    padding: isDesktop || isTablet
                        ? const EdgeInsets.only(top: 50)
                        : EdgeInsets.zero,
                    child: ScrollConfiguration(
                      // Add this wrapper
                      behavior: ScrollConfiguration.of(context).copyWith(
                        scrollbars:
                            isMobile ? true : false, // Hide default scrollbar
                      ),
                      child: isMobile
                          ? _buildScrollableContent()
                          : RawScrollbar(
                              thumbColor: isDark
                                  ? Colors.grey[300]
                                  : Colors.black.withOpacity(0.2),
                              radius: Radius.zero,
                              thickness: 15,
                              minThumbLength: 50,
                              thumbVisibility: true,
                              trackVisibility: false,
                              pressDuration: Duration
                                  .zero, // Instant thumb appearance on press
                              fadeDuration: const Duration(
                                  milliseconds: 300), // Smooth fade animation
                              interactive: true,
                              controller: _scrollController, // Add this
                              child: NotificationListener<ScrollNotification>(
                                onNotification:
                                    (ScrollNotification scrollInfo) {
                                  if (!isFetchingMore) {
                                    double threshold = isMobile ? 0 : 100;

                                    if (scrollInfo.metrics.pixels >=
                                        scrollInfo.metrics.maxScrollExtent -
                                            threshold) {
                                      _fetchMoreVideos();
                                    }
                                  }

                                  return false;
                                },
                                child: isMobile
                                    ? _buildScrollableContent()
                                    : CustomScrollView(
                                        controller: _scrollController,
                                        //  physics: const NeverScrollableScrollPhysics(),
                                        slivers: [
                                          // if (!isDesktop) ...[
                                          //   SliverAppBar(
                                          //     backgroundColor:
                                          //         theme.scaffoldBackgroundColor,
                                          //     elevation: 0,
                                          //     expandedHeight: 50,
                                          //     floating: true,
                                          //     pinned: false,
                                          //     snap: true,
                                          //     centerTitle: false,
                                          //     automaticallyImplyLeading: false,
                                          //     title: const Appbar(),
                                          //   ),
                                          //   SliverAppBar(
                                          //     backgroundColor:
                                          //         theme.scaffoldBackgroundColor,
                                          //     automaticallyImplyLeading: false,
                                          //     elevation: 0,
                                          //     pinned: true,
                                          //     bottom: PreferredSize(
                                          //       preferredSize: const Size.fromHeight(-10),
                                          //       child: SecondaryAppbar(
                                          //         selectedIndex: isMobile
                                          //             ? selectedTabIndex + 1
                                          //             : selectedTabIndex,
                                          //         onTabSelected: _handleTabSelection,
                                          //         showCompassIcon: isMobile,
                                          //       ),
                                          //     ),
                                          //   ),
                                          // ],
                                          Consumer<ApiProviders>(
                                            builder: (context, value, child) {
                                              switch (
                                                  value.videoResponse.status) {
                                                case ApiStatus.Loading:
                                                  return _buildLoadingGrid(
                                                      isMobile,
                                                      isTablet,
                                                      isDesktop);
                                                case ApiStatus.Complete:
                                                  return _buildVideoGrid(
                                                      value,
                                                      isMobile,
                                                      isTablet,
                                                      isDesktop);
                                                case ApiStatus.Error:
                                                  return SliverToBoxAdapter(
                                                    child: _buildErrorWidget(
                                                        value.videoResponse
                                                            .message),
                                                  );
                                                default:
                                                  return const SliverToBoxAdapter(
                                                      child: Center(
                                                          child: Text(
                                                              'Unexpected state')));
                                              }
                                            },
                                          ),

                                          // dummay data....
                                          // Consumer<ApiProviders>(
                                          //   builder: (context, value, child) {
                                          //     return _dumbGrid(value, isMobile,
                                          //         isTablet, isDesktop);
                                          //   },
                                          // ),
                                        ],
                                      ),
                              ),
                            ),
                    )),

                Positioned(
                    left: 0,
                    right: 0,
                    top: 0,
                    child: Container(
                      color: theme.scaffoldColor,
                      child: SecondaryAppbar(
                        selectedIndex: selectedTabIndex,
                        onTabSelected: _handleTabSelection,
                        showCompassIcon: isMobile,
                      ),
                    ))
                // if (isDesktop)
                //   Positioned(
                //     top: 0,
                //     left: 0,
                //     right: 0,
                //     child: Container(
                //       height: appBarHeight,
                //       color: theme.scaffoldBackgroundColor,
                //       child: Column(
                //         children: [
                //           SizedBox(
                //             height: 10,
                //           ),
                //           const DesktopAppbar(),
                //           SizedBox(
                //             height: 10,
                //           ),
                //           SecondaryAppbar(
                //             selectedIndex: selectedTabIndex,
                //             onTabSelected: _handleTabSelection,
                //             showCompassIcon: false,
                //           ),
                //         ],
                //       ),
                //     ),
                //   ),
              ],
            ),
          ),
        ],
      ),
      // bottomNavigationBar: isMobile ? NavBar() : null,
    );
  }

  void _handleTabSelection(int index) {
    final apiProvider = Provider.of<ApiProviders>(context, listen: false);
    final bool isMobile = Responsive.isMobile(context);

    setState(() {
      selectedTabIndex = isMobile ? index : index;
      String newQuery;

      if (index == 0 && !isMobile) {
        newQuery = "ai OR coding OR season OR netflix";
        selectedCategoryId = null;
      } else {
        selectedCategoryId = Categories.categoryMap.keys.toList()[index];
        newQuery = selectedCategoryId!;
      }

      apiProvider.updateSelectedTab(selectedTabIndex, newQuery);

      if (apiProvider.shouldReloadVideos(newQuery)) {
        _fetchVideos(newQuery);
      }
    });
  }

  Widget _buildLoadingGrid(bool isMobile, bool isTablet, bool isDesktop) {
    // Get the current screen width
    double screenWidth = MediaQuery.of(context).size.width;

    // Calculate the aspect ratio based on screen width
    double aspectRatio = isMobile
        ? 16 / 14.5 // Mobile ratio stays the same
        : screenWidth >= 650 && screenWidth <= 820
            ? 16 / 16 // First tablet breakpoint
            : screenWidth > 820 && screenWidth <= 1014
                ? 16 / 13 // Second tablet breakpoint
                : screenWidth > 1014 && screenWidth <= 1355
                    ? 16 / 15 // First desktop breakpoint
                    : 16 / 13; // Larger desktop screens
    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        // Optimized aspect ratios for each device type
        childAspectRatio: aspectRatio,
        crossAxisSpacing: 16,
        mainAxisSpacing: isMobile ? 16 : 24,
        crossAxisCount: isMobile
            ? 1
            : isTablet
                ? 2
                : 3,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) => Padding(
          padding: isMobile
              ? const EdgeInsets.only(top: 50)
              : const EdgeInsets.only(left: 15, top: 20, right: 15),
          child: const ShimmerLoading(),
        ),
        childCount: isMobile
            ? 5
            : isTablet
                ? 10
                : 20,
      ),
    );
  }

  Widget _buildVideoGrid(
      ApiProviders value, bool isMobile, bool isTablet, bool isDesktop) {
    final theme = Provider.of<YouTubeTheme>(context, listen: false);
    final isDark = theme.isDarkMode;
    // Get the current screen width
    double screenWidth = MediaQuery.of(context).size.width;

    // Calculate the aspect ratio based on screen width
    double aspectRatio = isMobile
        ? 16 / 14 // Mobile ratio stays the same
        : screenWidth >= 650 && screenWidth <= 820
            ? 16 / 16 // First tablet breakpoint
            : screenWidth > 820 && screenWidth <= 1014
                ? 16 / 13 // Second tablet breakpoint
                : screenWidth > 1014 && screenWidth <= 1355
                    ? 16 / 15 // First desktop breakpoint
                    : 16 / 13; // Larger desktop screens
    return SliverPadding(
      padding: isMobile
          ? const EdgeInsets.only(
              top: 50,
            )
          : const EdgeInsets.only(left: 15, top: 20, right: 15),
      sliver: SliverGrid.builder(
        itemCount: value.videoList.length + (value.isLoadingMore ? 1 : 0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          // Optimized aspect ratios for each device type
          childAspectRatio: aspectRatio,
          crossAxisSpacing: 16,
          mainAxisSpacing: isMobile ? 16 : 24,
          crossAxisCount: isMobile
              ? 1
              : isDesktop
                  ? 3
                  : 2,
        ),
        itemBuilder: (context, index) {
          if (index == value.videoList.length) {
            if (value.isLoadingMore) {
              return isMobile
                  ? Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isDark ? Colors.grey.shade700 : Colors.black54,
                          ),
                        ),
                      ),
                    )
                  : const ShimmerLoading();
              // : _buildLoadingGrid(false, isTablet, isDesktop);
            }
            return const SizedBox.shrink();
          }
          final video = value.videoList[index];

          return HomeFeed(
            channelId: video.snippet!.channelId!,
            video: video,
            subscribers: video.channelDetails!.statistics!.subscriberCount,
            avator: video
                .channelDetails!.snippet!.thumbnails!.defaultThumbnail!.url
                .toString(),
            thumbnail: video.snippet!.thumbnails!.maxres != null
                ? video.snippet!.thumbnails!.maxres!.url.toString()
                : video.snippet!.thumbnails!.high!.url.toString(),
            title: video.snippet!.title.toString(),
            channel: video.snippet!.channelTitle.toString(),
            views: Formates()
                .formatViewCount(video.statistics!.viewCount.toString()),
            publishTime:
                Formates().timeAgo(video.snippet!.publishedAt.toString()),
            durrations: Formates()
                .videoDurations(video.contentDetails!.duration.toString()),
          );
        },
      ),
    );
  }

  // Widget _dumbGrid(
  //     ApiProviders value, bool isMobile, bool isTablet, bool isDesktop) {
  //   return SliverPadding(
  //     padding: isMobile
  //         ? const EdgeInsets.only(
  //             top: 20,
  //           )
  //         : const EdgeInsets.only(left: 15, top: 20, right: 15),
  //     sliver: SliverGrid.builder(
  //       itemCount: 15,
  //       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
  //         crossAxisSpacing: 0,
  //         mainAxisSpacing: 0,
  //         crossAxisCount: isMobile
  //             ? 1
  //             : isDesktop
  //                 ? 3
  //                 : 2,
  //       ),
  //       itemBuilder: (context, index) {
  //         //   final video = value.videoList[index];
  //         return GestureDetector(
  //           onTap: () {
  //             // Navigator.push(
  //             //   context,
  //             //   MaterialPageRoute(
  //             //     builder: (context) => VideoPlayPage(
  //             //         id:wi video.snippet!.channelId!,
  //             //         video: video,
  //             //         ),
  //             //   ),
  //             // );
  //           },
  //           child: HomeFeed(
  //             subscribers: '23',
  //             avator: 'assets/images/brothers.jpg',
  //             thumbnail: 'assets/images/avatar.jpg',
  //             title: 'Money Heist: Season 5',
  //             channel: 'Netflix',
  //             views: '1.5M',
  //             publishTime: Formates().timeAgo('2023-01-01T00:00:00Z'),
  //             durrations: Formates().videoDurations('PT1H45M'),
  //           ),
  //         );
  //       },
  //     ),
  //   );
  // }
}
