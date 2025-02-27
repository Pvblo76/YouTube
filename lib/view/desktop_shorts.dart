import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:youtube/constants/localizations.dart';
import 'package:youtube/network/response/api_status.dart';
import 'package:youtube/provider/api_providers.dart';
import 'package:youtube/responsive/responsiveness.dart';
import 'package:youtube/theme/theme_manager.dart';
import 'package:youtube/widgets/Exceptions/Api_quota_exception.dart';
import 'package:youtube/widgets/Exceptions/offline_exception.dart';
import 'package:youtube/view/appbar.dart';
import 'package:youtube/widgets/desktop/desktop_drawers.dart';

import 'package:youtube/widgets/search_view/mobile_searching_view.dart';
import 'package:youtube/widgets/shorts/short_feed.dart';

import 'package:youtube/widgets/shorts/short_feed_shimmer.dart';
import 'package:youtube/widgets/tablet/tablet_drawer.dart';

class DesktopShorts extends StatefulWidget {
  const DesktopShorts({super.key});
  @override
  State<DesktopShorts> createState() => _DesktopShortsState();
}

class _DesktopShortsState extends State<DesktopShorts> {
  late PageController _pageController;
  bool isFetchingMore = false;
  bool _showUpButton = false;
  double _scrollOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _pageController.addListener(_scrollListener);

    final apiProvider = Provider.of<ApiProviders>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (apiProvider.shouldReloadShorts(apiProvider.lastShortQery)) {
        _fetchShort(apiProvider.lastShortQery);
      }
    });
  }

  void _scrollListener() {
    setState(() {
      _showUpButton = _pageController.page != 0;
      // Only update scroll offset in mobile mode
      if (Responsive.isMobile(context)) {
        _scrollOffset = _pageController.page ?? 0;
      }
    });
  }

  void _fetchShort(String query) {
    Provider.of<ApiProviders>(context, listen: false).fetchShorts(query);
  }

  void _fetchMoreShorts() {
    if (!isFetchingMore) {
      setState(() {
        isFetchingMore = true;
      });
      Provider.of<ApiProviders>(context, listen: false)
          .fetchMoreShorts(ApiProviders().lastShortQery)
          .then((_) {
        setState(() {
          isFetchingMore = false;
        });
      });
    }
  }

  @override
  void dispose() {
    _pageController.removeListener(_scrollListener);
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildMobileLayout(BuildContext context, Size size) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: _scrollOffset > 0
                ? Colors.black.withOpacity(0.0)
                : Colors.black,
          ),
          child: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(
                  CupertinoIcons.search,
                  size: 30,
                  color: Colors.white,
                ),
                onPressed: () {
                  showSearch(
                    context: context,
                    delegate: YoutubeSearchDelegate(context: context),
                  );
                },
              ),
              const SizedBox(width: 10),
              const Icon(
                Icons.more_vert,
                size: 30,
                color: Colors.white,
              ),
              const SizedBox(width: 10),
            ],
          ),
        ),
      ),
      body: SizedBox(
        width: size.width,
        child: _buildShortsContent(),
      ),
    );
  }

  Widget _buildDesktopTabletLayout(
      BuildContext context, Size size, bool isDesktop, bool isTablet) {
    final double sideWidth = isDesktop ? size.width * 0.25 : size.width * 0.15;
    final theme = Provider.of<YouTubeTheme>(context);
    return Scaffold(
      backgroundColor: theme.scaffoldColor,
      drawer: isTablet ? const TabletDrawer(currentPage: 'Shorts') : null,
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: YoutubeAppBar(),
      ),
      body: Row(
        children: [
          if (isDesktop)
            Container(
              width: size.width * 0.15,
              color: theme.scaffoldColor,
              child: const DeskTopDrawer(currentPage: 'Shorts'),
            ),
          if (isTablet)
            Container(
              width: size.width * 0.1,
              color: theme.scaffoldColor,
              child: const TabletDrawer(currentPage: 'Shorts'),
            ),
          Expanded(
            child: Container(
              width: sideWidth,
              color: theme.scaffoldColor,
            ),
          ),
          SizedBox(
            width: 400,
            child: _buildShortsContent(),
          ),
          Expanded(
            child: Container(
              width: sideWidth,
              color: theme.scaffoldColor,
              child: _buildNavigationButtons(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShortsContent() {
    return Consumer<ApiProviders>(
      builder: (context, value, child) {
        switch (value.shortsResponse.status) {
          case ApiStatus.Loading:
            return PageView.builder(
              scrollDirection: Axis.vertical,
              itemCount: 5,
              itemBuilder: (context, index) => const ShortFeedShimmer(),
            );
          case ApiStatus.Complete:
            return PageView.builder(
              controller: _pageController,
              scrollDirection: Axis.vertical,
              onPageChanged: (index) {
                if (index == value.shortsList.length - 1) {
                  _fetchMoreShorts();
                }
              },
              itemCount:
                  value.shortsList.length + (value.isLoadingMoreShorts ? 1 : 0),
              itemBuilder: (context, index) {
                if (index < value.shortsList.length) {
                  var shorts = value.shortsList[index];
                  return ShortFeed(
                    videoId: shorts.id!,
                    thumbnail: shorts.snippet!.thumbnails!.maxres != null
                        ? shorts.snippet!.thumbnails!.maxres!.url.toString()
                        : shorts.snippet!.thumbnails!.high!.url.toString(),
                    name: shorts.snippet!.channelTitle.toString(),
                    title: shorts.snippet!.title.toString(),
                    avatar: shorts.channelDetails!.snippet!.thumbnails!
                        .defaultThumbnail!.url
                        .toString(),
                    channelId: shorts.snippet!.channelId!,
                    commentsCounts: shorts.statistics!.commentCount != null
                        ? Formates().formatsubCount(
                            shorts.statistics!.commentCount.toString())
                        : "Comments",
                    likeCounts: shorts.statistics!.likeCount != null
                        ? Formates().formatsubCount(
                            shorts.statistics!.likeCount.toString())
                        : "Like",
                  );
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            );
          case ApiStatus.Error:
            if (value.shortsResponse.message.toString().contains('quota')) {
              return const QuotaExceededErrorPage();
            }
            if (!value.shortsResponse.message.toString().contains('quota') &&
                value.shortsResponse.message
                    .toString()
                    .contains('Error During Communication')) {
              return const NoInternetPage();
            }
            return Center(
              child: Text(value.shortsResponse.message.toString()),
            );
          default:
            return const Center(child: Text('Unexpected state'));
        }
      },
    );
  }

  Widget _buildNavigationButtons() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Spacer(),
        if (_showUpButton)
          AnimatedOpacity(
            duration: const Duration(milliseconds: 400),
            opacity: 1.0,
            child: IconButton(
              icon: const Icon(Icons.arrow_upward),
              onPressed: () {
                _pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
            ),
          ),
        const SizedBox(height: 20),
        IconButton(
          icon: const Icon(Icons.arrow_downward),
          onPressed: () {
            _pageController.nextPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          },
        ),
        const Spacer(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = Responsive.isMobile(context);
    final bool isDesktop = Responsive.isDesktop(context);
    final bool isTablet = Responsive.isTablet(context);
    final Size size = MediaQuery.of(context).size;

    // Return different layouts based on device type
    if (isMobile) {
      return _buildMobileLayout(context, size);
    } else {
      return _buildDesktopTabletLayout(context, size, isDesktop, isTablet);
    }
  }
}
