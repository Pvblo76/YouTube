import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:youtube/constants/localizations.dart';
import 'package:youtube/network/response/api_status.dart';
import 'package:youtube/provider/api_providers.dart';
import 'package:youtube/responsive/responsiveness.dart';
import 'package:youtube/theme/theme_manager.dart';
import 'package:youtube/widgets/Exceptions/Api_quota_exception.dart';
import 'package:youtube/widgets/Exceptions/offline_exception.dart';
import 'package:youtube/view/appbar.dart';
import 'package:youtube/widgets/channel_info/channel_details.dart';
import 'package:youtube/widgets/channel_info/channel_shimmer_view.dart';
import 'package:youtube/widgets/channel_info/channel_tabcontroller.dart';
import 'package:youtube/widgets/channel_info/channel_video_view.dart';
import 'package:youtube/widgets/desktop/desktop_drawers.dart';
import 'package:youtube/widgets/home/home_feed_shimmer_effect.dart';
import 'package:youtube/widgets/search_view/mobile_searching_view.dart';
import 'package:youtube/widgets/tablet/tablet_drawer.dart';

class ChannelPage extends StatefulWidget {
  final String id;
  const ChannelPage({super.key, required this.id});

  @override
  State<ChannelPage> createState() => _ChannelPageState();
}

class _ChannelPageState extends State<ChannelPage> {
  ScrollController _scrollController = ScrollController();
  late int selectedTabIndex = 0;
  String? selectedCategoryId;
  bool isFetchingMore = false;

  @override
  void initState() {
    super.initState();
    final apiProvider = Provider.of<ApiProviders>(context, listen: false);
    selectedTabIndex = apiProvider.selectedTabIndex;

    _scrollController.addListener(_scrollListener);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      apiProvider.fetchChannel(widget.id);
      _fetchChannelVideos(widget.id);
    });
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _fetchMoreChannelVideos();
    }
  }

  void _fetchChannelVideos(String channelId) {
    Provider.of<ApiProviders>(context, listen: false)
        .fetchChannelVideos(channelId);
  }

  void _fetchMoreChannelVideos() {
    if (!isFetchingMore) {
      setState(() {
        isFetchingMore = true;
      });
      Provider.of<ApiProviders>(context, listen: false)
          .fetchMoreChannelVideos(widget.id)
          .then((_) {
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

  @override
  Widget build(BuildContext context) {
    final bool isMobile = Responsive.isMobile(context);
    final bool isDesktop = Responsive.isDesktop(context);
    final bool isTablet = Responsive.isTablet(context);
    final Size size = MediaQuery.of(context).size;
    final theme = Provider.of<YouTubeTheme>(context);
    final isDark = theme.isDarkMode;

    return Scaffold(
      backgroundColor: theme.scaffoldColor,
      appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: isMobile ? _buildAppBar() : const YoutubeAppBar()),
      drawer: isMobile
          ? const DeskTopDrawer(currentPage: 'Home')
          : isTablet
              ? const TabletDrawer()
              : null,
      body: Row(
        children: [
          if (isDesktop)
            Container(
              width: size.width * 0.15,
              color: theme.scaffoldColor,
              child: const DeskTopDrawer(currentPage: 'Home'),
            ),
          if (isTablet)
            Container(
              width: size.width * 0.1,
              color: theme.scaffoldColor,
              child: const TabletDrawer(),
            ),
          Expanded(
            child: Padding(
              padding: isDesktop
                  ? const EdgeInsets.only(top: 15.0)
                  : EdgeInsets.zero,
              child: isMobile
                  ? CustomScrollView(
                      controller: _scrollController,
                      slivers: _buildSlivers(isMobile, isTablet, isDesktop),
                    )
                  : ScrollConfiguration(
                      behavior: ScrollConfiguration.of(context).copyWith(
                        scrollbars: false,
                      ),
                      child: RawScrollbar(
                        thumbColor: isDark
                            ? Colors.grey[300]
                            : Colors.black.withOpacity(0.2),
                        radius: Radius.zero,
                        thickness: 15,
                        minThumbLength: 50,
                        thumbVisibility: true,
                        trackVisibility: false,
                        pressDuration: Duration.zero,
                        fadeDuration: const Duration(milliseconds: 300),
                        interactive: true,
                        controller: _scrollController,
                        child: CustomScrollView(
                          controller: _scrollController,
                          slivers: _buildSlivers(isMobile, isTablet, isDesktop),
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildSlivers(bool isMobile, bool isTablet, bool isDesktop) {
    return [
      SliverPadding(
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 10 : 60),
        sliver: SliverToBoxAdapter(
          child: Consumer<ApiProviders>(
            builder: (context, value, child) {
              switch (value.channelResponse.status) {
                case ApiStatus.Loading:
                  return const ChannelDetailsShimmer();
                case ApiStatus.Complete:
                  final formattedViews = NumberFormat("#,###")
                      .format(int.parse(value.channel!.viewCount.toString()));
                  return ChannelDetails(
                    viewcount: formattedViews,
                    country: value.channel!.country.toString(),
                    name: value.channel!.title.toString(),
                    descriptions: value.channel!.description.toString(),
                    banner: value.channel!.bannerImageUrl.toString(),
                    logo: value.channel!.avatar.toString(),
                    subscriber: Formates().formatsubCount(
                        value.channel!.subscriberCount.toString()),
                    videocount: isMobile
                        ? Formates().formatsubCount(
                            value.channel!.videoCount.toString())
                        : value.channel!.videoCount.toString(),
                  );
                case ApiStatus.Error:
                  if (value.channelResponse.message
                      .toString()
                      .contains('quota')) {
                    return const QuotaExceededErrorPage();
                  }
                  if (!value.channelResponse.message
                          .toString()
                          .contains('quota') &&
                      value.channelResponse.message
                          .toString()
                          .contains('Error During Communication')) {
                    return const NoInternetPage();
                  }
                  return Center(
                      child: Text(value.channelResponse.message.toString()));
                default:
                  return const Center(child: Text('Unexpected state'));
              }
            },
          ),
        ),
      ),
      SliverPadding(
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 10 : 60),
        sliver: SliverToBoxAdapter(
          child: ChannelTabController(
            selectedIndex: selectedTabIndex,
            onTabSelected: _handleTabSelection,
          ),
        ),
      ),
      Consumer<ApiProviders>(
        builder: (context, value, child) {
          switch (value.channelVideosResponse.status) {
            case ApiStatus.Loading:
              return _buildLoadingGrid(isMobile, isTablet, isDesktop);
            case ApiStatus.Complete:
              return _buildVideoGrid(value, isMobile, isTablet, isDesktop);
            case ApiStatus.Error:
              if (value.channelVideosResponse.message
                  .toString()
                  .contains('quota')) {
                return const SliverToBoxAdapter(
                    child: QuotaExceededErrorPage());
              }
              if (!value.channelVideosResponse.message
                      .toString()
                      .contains('quota') &&
                  value.channelVideosResponse.message
                      .toString()
                      .contains('Error During Communication')) {
                return const SliverToBoxAdapter(child: NoInternetPage());
              }
              return SliverToBoxAdapter(
                  child: Center(
                      child: Text(
                          value.channelVideosResponse.message.toString())));
            default:
              return const SliverToBoxAdapter(
                  child: Center(child: Text('Unexpected state')));
          }
        },
      ),
    ];
  }

  void _handleTabSelection(int index) {
    setState(() {
      selectedTabIndex = index;
    });
  }

  Widget _buildLoadingGrid(bool isMobile, bool isTablet, bool isDesktop) {
    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisSpacing: 5,
        mainAxisSpacing: 5,
        crossAxisCount: isMobile
            ? 1
            : isTablet
                ? 3
                : 4,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) => const ShimmerLoading(),
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
    double screenWidth = MediaQuery.of(context).size.width;
    double aspectRatio = isMobile
        ? 16 / 13
        : screenWidth >= 650 && screenWidth <= 820
            ? 16 / 16.5
            : screenWidth > 820 && screenWidth <= 1014
                ? 16 / 15
                : screenWidth > 1014 && screenWidth <= 1355
                    ? 16 / 16
                    : 16 / 13;

    return SliverPadding(
      padding: isMobile
          ? const EdgeInsets.only(top: 20)
          : const EdgeInsets.only(left: 15, top: 20, right: 15),
      sliver: SliverGrid.builder(
        itemCount: value.channelVideosList.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          childAspectRatio: aspectRatio,
          crossAxisSpacing: 16,
          mainAxisSpacing: isMobile ? 16 : 24,
          crossAxisCount: isMobile
              ? 1
              : isDesktop
                  ? 4
                  : 3,
        ),
        itemBuilder: (context, index) {
          final video = value.channelVideosList[index];
          return ChannelVideoView(
            video: video,
            channelId: video.snippet!.channelId!,
            thumbnail: video.snippet!.thumbnails!.maxres != null
                ? video.snippet!.thumbnails!.maxres!.url.toString()
                : video.snippet!.thumbnails!.high!.url.toString(),
            title: video.snippet!.title.toString(),
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

  Widget _buildAppBar() {
    final theme = Provider.of<YouTubeTheme>(context);
    final isDark = theme.isDarkMode;
    return AppBar(
      backgroundColor: theme.scaffoldColor,
      automaticallyImplyLeading: false,
      leading: GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: Icon(
          Icons.arrow_back,
          size: 22,
          color: isDark ? Colors.white : Colors.black,
        ),
      ),
      actions: [
        Icon(
          Icons.cast, // This is the icon you are looking for

          size: 22,
          color: isDark ? Colors.white : Colors.black,
        ),
        const SizedBox(width: 20),
        IconButton(
          icon: Icon(
            CupertinoIcons.search,
            size: 24,
            color: isDark ? Colors.white : Colors.black,
          ),
          onPressed: () {
            showSearch(
              context: context,
              delegate: YoutubeSearchDelegate(context: context),
            );
          },
        ),
        const SizedBox(width: 20),
        Icon(
          Icons.more_vert,
          size: 22,
          color: isDark ? Colors.white : Colors.black,
        ),
        const SizedBox(width: 15),
      ],
    );
  }
}
