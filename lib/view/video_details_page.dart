import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:transparent_image/transparent_image.dart';

import 'package:youtube/constants/localizations.dart';
import 'package:youtube/model/videos_model.dart';
import 'package:youtube/network/response/api_status.dart';
import 'package:youtube/provider/api_providers.dart';
import 'package:youtube/responsive/responsiveness.dart';
import 'package:youtube/theme/theme_manager.dart';
import 'package:youtube/widgets/Exceptions/Api_quota_exception.dart';
import 'package:youtube/widgets/Exceptions/offline_exception.dart';
import 'package:youtube/view/appbar.dart';
import 'package:youtube/view/home_page.dart';
import 'package:youtube/widgets/desktop/desktop_drawers.dart';
import 'package:youtube/widgets/home/feed.dart';
import 'package:youtube/widgets/home/home_feed_shimmer_effect.dart';
import 'package:youtube/widgets/recommendation/shimmer_effect_for_recommendations.dart';
import 'package:youtube/widgets/video/video_comments_sections.dart';
import 'package:youtube/widgets/video/video_description.dart';
import 'package:youtube/widgets/video/video_page_shimmer_effect.dart';
import 'package:youtube/widgets/video/video_view.dart';
import 'package:youtube/widgets/recommendation/recommendations.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class VideoPlayPage extends StatefulWidget {
  final Video video;
  final String id;
  final VoidCallback? onReturn;
  const VideoPlayPage({
    super.key,
    required this.video,
    required this.id,
    this.onReturn,
  });
  @override
  State<VideoPlayPage> createState() => _VideoPlayPageState();
}

class _VideoPlayPageState extends State<VideoPlayPage>
    with WidgetsBindingObserver {
  final ScrollController _mainScrollController = ScrollController();
  final ValueNotifier<bool> _isLoading =
      ValueNotifier(true); // Track loading state
  bool isFetchingMore = false;

  bool isMoreComment = false;

  late YoutubePlayerController _controller;
  @override
  void initState() {
    super.initState();
    // Register as an observer to detect app lifecycle changes
    WidgetsBinding.instance.addObserver(this);
    final apiProvider = Provider.of<ApiProviders>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      apiProvider.fetchChannel(widget.id);
      apiProvider.fetchRelatedVideos(widget.video.snippet!.title!);
      if (apiProvider.shouldReloadComments(widget.video.id!)) {
        _fetchComments();
      }
    });
    _controller = YoutubePlayerController.fromVideoId(
      videoId: widget.video.id!,
      autoPlay: true,
      params: const YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: true,
        mute: false,
      ),
    )..listen((event) {
        if (event.playerState == PlayerState.playing) {
          _isLoading.value = false; // Hide loader when video starts playing
        }
      });
    super.initState();
  }

// Handle app lifecycle changes
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      // App goes to background or is minimized
      _controller.pauseVideo();
    }
  }

  void _fetchComments() {
    Provider.of<ApiProviders>(context, listen: false)
        .fetchComments(widget.video.id!);
  }

  void _fetchMoreVideos() {
    if (!isFetchingMore) {
      setState(() {
        isFetchingMore = true;
      });

      Provider.of<ApiProviders>(context, listen: false)
          .fetchMoreRelatedVideos(widget.video.snippet!.title!)
          .then((_) {
        setState(() {
          isFetchingMore = false;
        });
      });
    }
  }

  void _fetchMoreComments() {
    if (!isMoreComment) {
      setState(() {
        isMoreComment = true;
      });

      Provider.of<ApiProviders>(context, listen: false)
          .fetchMoreComments(widget.video.id!)
          .then((_) {
        setState(() {
          isMoreComment = false;
        });
      });
    }
  }

  // Initialize the state

  @override
  void dispose() {
    // Make sure to pause and dispose of the controller when leaving the page
    _controller.pauseVideo();
    _controller.close();
    _mainScrollController.dispose();

    // Remove the observer
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Widget _buildVideoPlayer(bool isMobile, bool isTablet) {
    return Container(
      padding: isMobile
          ? EdgeInsets.zero
          : isTablet
              ? const EdgeInsets.symmetric(horizontal: 20, vertical: 10)
              : const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
      child: Stack(
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: ClipRRect(
              borderRadius:
                  isMobile ? BorderRadius.zero : BorderRadius.circular(20),
              child: YoutubePlayerScaffold(
                aspectRatio: 16 / 9,
                controller: _controller,
                builder: (context, player) {
                  return Column(
                    children: [
                      player,
                    ],
                  );
                },
              ),
            ),
          ),
          // Thumbnail and loading indicator overlay
          ValueListenableBuilder<bool>(
            valueListenable: _isLoading,
            builder: (context, isLoading, _) {
              return isLoading
                  ? AspectRatio(
                      aspectRatio: 16 / 9,
                      child: ClipRRect(
                        borderRadius: isMobile
                            ? BorderRadius.zero
                            : BorderRadius.circular(20),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            // The thumbnail image
                            FadeInImage.memoryNetwork(
                              placeholder: kTransparentImage,
                              image: widget.video.snippet!.thumbnails!.maxres !=
                                      null
                                  ? widget
                                      .video.snippet!.thumbnails!.maxres!.url
                                      .toString()
                                  : widget.video.snippet!.thumbnails!.high!.url
                                      .toString(),
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              imageErrorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[200],
                                  child: const Center(
                                    child: Icon(Icons.play_circle_outline,
                                        size: 50, color: Colors.white),
                                  ),
                                );
                              },
                            ),
                            // Semi-transparent overlay with loading indicator
                            Container(
                              color: Colors.black.withOpacity(0.5),
                              child: const Center(
                                child: CircularProgressIndicator(
                                    color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : const SizedBox.shrink();
            },
          ),

          // Back button for mobile
          if (isMobile)
            Positioned(
              top: 10,
              left: 10,
              child: InkWell(
                // Replace GestureDetector with InkWell for better feedback
                onTap: () => Navigator.pop(context),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(
                        0.5), // Add background for better visibility
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    CupertinoIcons.back,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCommentsPreview() {
    final theme = Provider.of<YouTubeTheme>(context, listen: false);
    bool hasComments = widget.video.statistics?.commentCount != null;
    return GestureDetector(
      onTap: _showCommentsSheet,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          height: 90,
          decoration: BoxDecoration(
            color: theme.containerBackgroundColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasComments
                      ? 'Comments  ${Formates().formatsubCount(widget.video.statistics!.commentCount.toString())}'
                      : "",
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: theme.titleColor),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Consumer<ApiProviders>(builder: (context, value, child) {
                      return CircleAvatar(
                        radius: 15,
                        backgroundColor: Colors.grey.shade300,
                        backgroundImage: value.commentResponse.status ==
                                    ApiStatus.Complete &&
                                value.commentsList.isNotEmpty
                            ? NetworkImage(value.commentsList.first.snippet
                                .topLevelComment.snippet.authorProfileImageUrl)
                            : null,
                      );
                    }),
                    const SizedBox(
                      width: 8,
                    ),
                    Expanded(
                      child: Consumer<ApiProviders>(
                        builder: (context, value, child) {
                          if (value.commentResponse.status ==
                                  ApiStatus.Complete &&
                              value.commentsList.isNotEmpty) {
                            final topComment = value.commentsList.first.snippet
                                .topLevelComment.snippet;
                            return Text(
                              topComment.textDisplay,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: theme.titleColor),
                            );
                          }
                          return value.commentResponse.status ==
                                  ApiStatus.Loading
                              ? const SizedBox.shrink()
                              : const Text(
                                  "No comments yet",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showCommentsSheet() {
    final theme = Provider.of<YouTubeTheme>(context, listen: false);
    final isDark = theme.isDarkMode;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          final apiProvider = Provider.of<ApiProviders>(context, listen: false);
          // Add scroll listener to detect bottom
          scrollController.addListener(() {
            if (scrollController.position.pixels >=
                    scrollController.position.maxScrollExtent - 100 &&
                !apiProvider.isLoadingMoreComments) {
              _fetchMoreComments();
            }
          });

          return ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Container(
              decoration: BoxDecoration(
                color: theme.scaffoldColor,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: CustomScrollView(
                controller: scrollController,
                slivers: [
                  // Fixed header at the top
                  SliverAppBar(
                    pinned: true,
                    toolbarHeight: 80,
                    automaticallyImplyLeading: false,
                    backgroundColor: theme.scaffoldColor,
                    title: Column(
                      children: [
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.grey.shade500
                                : Colors.grey[300],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Comments',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.close,
                                  color: isDark ? Colors.white : Colors.black),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Divider below the header
                  const SliverToBoxAdapter(
                    child: Divider(height: 1),
                  ),

                  // Comments section
                  Consumer<ApiProviders>(
                    builder: (context, value, child) {
                      switch (value.commentResponse.status) {
                        case ApiStatus.Loading:
                          return SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    isDark
                                        ? Colors.grey.shade400
                                        : Colors.black54,
                                  ),
                                ),
                              ),
                            ),
                          );
                        case ApiStatus.Complete:
                          if (value.commentsList.isEmpty) {
                            return const SliverToBoxAdapter(
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Center(
                                  child: Text('No comments yet'),
                                ),
                              ),
                            );
                          }
                          return SliverList(
                            delegate: SliverChildListDelegate([
                              YouTubeComments(
                                commentsCount: Formates().formatsubCount(widget
                                    .video.statistics!.commentCount
                                    .toString()),
                                // commentsCount: widget
                                //     .video.statistics!.commentCount
                                //     .toString(),
                                currentUserAvatar:
                                    'https://avatars.githubusercontent.com/u/48078961?v=4',
                                comments: value.commentsList
                                    .map((comment) => CommentData(
                                          username: comment
                                              .snippet
                                              .topLevelComment
                                              .snippet
                                              .authorDisplayName,
                                          userAvatar: comment
                                              .snippet
                                              .topLevelComment
                                              .snippet
                                              .authorProfileImageUrl,
                                          text: comment.snippet.topLevelComment
                                              .snippet.textDisplay,
                                          timestamp: Formates().timeAgo(comment
                                              .snippet
                                              .topLevelComment
                                              .snippet
                                              .publishedAt),
                                          likes: comment.snippet.topLevelComment
                                              .snippet.likeCount,
                                          replies:
                                              comment.snippet.totalReplyCount,
                                        ))
                                    .toList(),
                                isDesktop: Responsive.isDesktop(context),
                              ),
                              if (value.isLoadingMoreComments)
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 3,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        isDark
                                            ? Colors.grey.shade400
                                            : Colors.black54,
                                      ),
                                    ),
                                  ),
                                ),
                            ]),
                          );
                        case ApiStatus.Error:
                          // Check for quota exceeded error
                          if (value.commentResponse.message
                              .toString()
                              .contains('quota')) {
                            return const SliverToBoxAdapter(
                                child: QuotaExceededErrorPage());
                          }
                          // No Internet Connections error..
                          if (!value.commentResponse.message
                                  .toString()
                                  .contains('quota') &&
                              value.commentResponse.message
                                  .toString()
                                  .contains('Error During Communication')) {
                            return const SliverToBoxAdapter(
                                child: NoInternetPage());
                          }

                          return SliverToBoxAdapter(
                            child: Center(
                              child: Text(
                                  value.commentResponse.message.toString()),
                            ),
                          );
                        default:
                          return const SliverToBoxAdapter(
                            child: Center(child: Text('Unexpected state')),
                          );
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _showDescription() {
    final theme = Provider.of<YouTubeTheme>(context, listen: false);
    return GestureDetector(
      onTap: _showDescriptionSheet,
      child: Text(
        '...more',
        style: TextStyle(color: theme.titleColor),
      ),
    );
  }

  void _showDescriptionSheet() {
    final theme = Provider.of<YouTubeTheme>(context, listen: false);
    final isDark = theme.isDarkMode;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          child: Container(
            decoration: BoxDecoration(
              color: theme.scaffoldColor,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: CustomScrollView(
              controller: scrollController,
              slivers: [
                // Sticky Header with Drag Handle and Close Button
                SliverAppBar(
                  pinned: true,
                  toolbarHeight: 80,
                  automaticallyImplyLeading: false,
                  backgroundColor: theme.scaffoldColor,
                  title: Column(
                    children: [
                      // Drag Handle
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color:
                              isDark ? Colors.grey.shade500 : Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      // Header Row with Title and Close Button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Description',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: theme.titleColor,
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.close,
                                color: isDark ? Colors.white : Colors.black),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Divider below the header
                const SliverToBoxAdapter(
                  child: Divider(height: 1),
                ),

                // Description Content
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.video.snippet!.title.toString(),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildStatsRow(),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),

                // Expandable Description
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 10, right: 10, top: 15, bottom: 35),
                    child: ExpandableDescription(
                      views: '34k view',
                      publishTime: '2 month ago',
                      descriptions:
                          widget.video.snippet!.description.toString(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    final theme = Provider.of<YouTubeTheme>(context, listen: false);
    final formattedViews = NumberFormat("#,###")
        .format(int.parse(widget.video.statistics!.viewCount.toString()));
    DateTime dateTime =
        DateTime.parse(widget.video.snippet!.publishedAt.toString());
    String formattedDate = DateFormat("MMM d\nyyyy").format(dateTime);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            textAlign: TextAlign.center,
            '${Formates().formatLikes(widget.video.statistics!.likeCount.toString())}\nLikes',
            style: GoogleFonts.roboto(
                fontWeight: FontWeight.bold, color: theme.titleColor),
          ),
          const SizedBox(width: 8),
          Text(
            textAlign: TextAlign.center,
            '${formattedViews}\nviews',
            style: GoogleFonts.roboto(
                color: theme.titleColor, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          Text(
            formattedDate,
            textAlign: TextAlign.center,
            style: GoogleFonts.roboto(
              color: theme.titleColor,
              fontWeight: FontWeight.bold,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCommentInput() {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            child: Icon(Icons.person),
          ),
          SizedBox(width: 16),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Add a comment...',
                border: UnderlineInputBorder(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentSection(ApiProviders value) {
    bool hasComments = widget.video.statistics?.commentCount != null;

    switch (value.commentResponse.status) {
      case ApiStatus.Loading:
        return const Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(
              child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(
              Colors.black54,
            ),
          )),
        );
      case ApiStatus.Complete:
        if (value.commentsList.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(
              child: Text('No comments yet'),
            ),
          );
        }
        return Column(
          children: [
            YouTubeComments(
              // commentsCount: '1',
              commentsCount: hasComments
                  ? widget.video.statistics!.commentCount.toString()
                  : "0",
              currentUserAvatar:
                  'https://avatars.githubusercontent.com/u/48078961?v=4',
              comments: value.commentsList
                  .map((comment) => CommentData(
                        username: comment
                            .snippet.topLevelComment.snippet.authorDisplayName,
                        userAvatar: comment.snippet.topLevelComment.snippet
                            .authorProfileImageUrl,
                        text:
                            comment.snippet.topLevelComment.snippet.textDisplay,
                        timestamp: Formates().timeAgo(comment
                            .snippet.topLevelComment.snippet.publishedAt),
                        likes:
                            comment.snippet.topLevelComment.snippet.likeCount,
                        replies: comment.snippet.totalReplyCount,
                      ))
                  .toList(),
              isDesktop: Responsive.isDesktop(context),
            ),
            if (isMoreComment)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.black54,
                    ),
                  ),
                ),
              ),
          ],
        );
      case ApiStatus.Error:
        final errorMessage =
            value.commentResponse.message.toString().toLowerCase();
        if (errorMessage.contains('403') ||
            errorMessage.contains('comments disabled') ||
            errorMessage.contains('commentsDisabled')) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(
              child: Text(
                "Comments are disabled for this video",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ),
          );
        }
        return const Center(
          child: Text(''),
        );
      default:
        return const Center(child: Text('Unexpected state'));
    }
  }

  Widget _dumbVideoPlayer(bool isMobile, bool isTablet) {
    return Container(
      padding: isMobile
          ? EdgeInsets.zero
          : isTablet
              ? const EdgeInsets.symmetric(horizontal: 20, vertical: 10)
              : const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
      child: Stack(
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: ClipRRect(
              borderRadius:
                  isMobile ? BorderRadius.zero : BorderRadius.circular(10),
              child: Image.asset(
                'assets/images/avatar.jpg',
                fit: BoxFit.cover,
              ),
            ),
          ),
          if (isMobile)
            Positioned(
              top: 10,
              left: 10,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const HomePage()),
                  );
                },
                child: const Icon(
                  CupertinoIcons.back,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsList(
      ApiProviders value, bool isMobile, bool isTablet) {
    final theme = Provider.of<YouTubeTheme>(context, listen: false);
    final isDark = theme.isDarkMode;
    switch (value.recommendationResponse.status) {
      case ApiStatus.Loading:
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 5,
          itemBuilder: (context, index) => isMobile
              ? const ShimmerLoading()
              : const RecommendationsShimmer(),
        );
      case ApiStatus.Complete:
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount:
              value.recommendedList.length + (value.isLoadingMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == value.recommendedList.length) {
              if (isFetchingMore) {
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
                    : const RecommendationsShimmer();
              }
              return const SizedBox.shrink();
            }

            var channel = value.recommendedList[index];
            return isMobile
                ? Padding(
                    padding: const EdgeInsets.only(bottom: 30),
                    child: HomeFeed(
                      video: channel,
                      channelId: channel.snippet!.channelId!,
                      title: channel.snippet!.title.toString(),
                      channel: channel.snippet!.channelTitle.toString(),
                      views: Formates().formatViewCount(
                          channel.statistics!.viewCount.toString()),
                      publishTime: Formates()
                          .timeAgo(channel.snippet!.publishedAt.toString()),
                      thumbnail: channel.snippet!.thumbnails!.maxres != null
                          ? channel.snippet!.thumbnails!.maxres!.url.toString()
                          : channel.snippet!.thumbnails!.high!.url.toString(),
                      avator: channel.channelDetails!.snippet!.thumbnails!
                          .defaultThumbnail!.url
                          .toString(),
                      durrations: Formates().videoDurations(
                          channel.contentDetails!.duration.toString()),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Recommendations(
                      video: channel,
                      channelId: channel.snippet!.channelId!,
                      subscribers:
                          channel.channelDetails!.statistics!.subscriberCount!,
                      title: channel.snippet!.title.toString(),
                      channel: channel.snippet!.channelTitle.toString(),
                      views: Formates().formatViewCount(
                          channel.statistics!.viewCount.toString()),
                      publishTime: Formates()
                          .timeAgo(channel.snippet!.publishedAt.toString()),
                      thumbnail: channel.snippet!.thumbnails!.maxres != null
                          ? channel.snippet!.thumbnails!.maxres!.url.toString()
                          : channel.snippet!.thumbnails!.high!.url.toString(),
                      durrations: Formates().videoDurations(
                          channel.contentDetails!.duration.toString()),
                    ),
                  );
          },
        );
      case ApiStatus.Error:
        // Check for quota exceeded error
        if (value.recommendationResponse.message.toString().contains('quota')) {
          return isMobile
              ? const SizedBox.shrink()
              : const QuotaExceededErrorPage();
        }
        // No Internet Connections error..
        if (!value.recommendationResponse.message
                .toString()
                .contains('quota') &&
            value.recommendationResponse.message
                .toString()
                .contains('Error During Communication')) {
          return isMobile ? const SizedBox.shrink() : const NoInternetPage();
        }
        return Center(
            child: Text(value.recommendationResponse.message.toString()));

      default:
        return const Center(child: Text('Unexpected state'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = Responsive.isMobile(context);
    final bool isDesktop = Responsive.isDesktop(context);
    final bool isTablet = Responsive.isTablet(context);
    final double screenWidth = MediaQuery.of(context).size.width;
    print("Screen Width : ${screenWidth}");
    final theme = Provider.of<YouTubeTheme>(
      context,
    );
    final isDark = theme.isDarkMode;
    if (isMobile) {
      return Scaffold(
        backgroundColor: theme.scaffoldColor,
        body: Column(
          children: [
            // Pinned video player for mobile
            _buildVideoPlayer(isMobile, isTablet),
            // Scrollable content
            Expanded(
              child: NotificationListener<ScrollNotification>(
                onNotification: (ScrollNotification scrollInfo) {
                  if (scrollInfo.metrics.pixels ==
                      scrollInfo.metrics.maxScrollExtent) {
                    _fetchMoreVideos();
                  }
                  return false;
                },
                child: SingleChildScrollView(
                  controller: _mainScrollController,
                  child: Column(
                    children: [
                      // Video Information
                      Consumer<ApiProviders>(
                        builder: (context, value, child) {
                          bool hasLikes =
                              widget.video.statistics?.likeCount != null;
                          switch (value.channelResponse.status) {
                            case ApiStatus.Loading:
                              return const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: VideoViewShimmer(),
                              );
                            case ApiStatus.Complete:
                              return VideoView(
                                showdescription: _showDescription(),
                                preview: _buildCommentsPreview(),
                                //   customUrl: value.channel!.customUrl,
                                likeCount: hasLikes
                                    ? Formates().formatLikes(widget
                                        .video.statistics!.likeCount
                                        .toString())
                                    : "Like",
                                channelId: value.channel!.id!,
                                avator: value.channel!.avatar.toString(),
                                title: widget.video.snippet!.title.toString(),
                                channel: value.channel!.title.toString(),
                                views: Formates().formatViewCount(widget
                                    .video.statistics!.viewCount
                                    .toString()),
                                publishTime: Formates().timeAgo(widget
                                    .video.snippet!.publishedAt
                                    .toString()),
                                subscribers: Formates().formatsubCount(
                                    value.channel!.subscriberCount.toString()),
                                descriptions: widget.video.snippet!.description
                                    .toString(),
                              );
                            case ApiStatus.Error:
                              // Check for quota exceeded error
                              if (value.channelResponse.message
                                  .toString()
                                  .contains('quota')) {
                                return const QuotaExceededErrorPage();
                              }
                              // No Internet Connections error..
                              if (!value.channelResponse.message
                                      .toString()
                                      .contains('quota') &&
                                  value.channelResponse.message
                                      .toString()
                                      .contains('Error During Communication')) {
                                return const NoInternetPage();
                              }
                              return Center(
                                  child: Text(value.channelResponse.message
                                      .toString()));
                            default:
                              return const Center(
                                  child: Text('Unexpected state'));
                          }
                        },
                      ),

                      // Mobile Recommendations
                      Consumer<ApiProviders>(
                        builder: (context, value, child) {
                          return _buildRecommendationsList(
                              value, isMobile, isTablet);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
    return Consumer<ApiProviders>(builder: (context, value, child) {
      // Check for error conditions first
      if (value.channelResponse.status == ApiStatus.Error) {
        // Check for quota exceeded error
        if (value.channelResponse.message.toString().contains('quota')) {
          return Scaffold(
            drawer: isDesktop
                ? const DeskTopDrawer(
                    currentPage: 'Home',
                  )
                : null,
            backgroundColor: theme.scaffoldColor,
            appBar: const PreferredSize(
              preferredSize: Size.fromHeight(kToolbarHeight),
              child: YoutubeAppBar(),
            ),
            body: QuotaExceededErrorPage(),
          );
        }

        // No Internet Connections error
        if (!value.channelResponse.message.toString().contains('quota') &&
            value.channelResponse.message
                .toString()
                .contains('Error During Communication')) {
          return Scaffold(
            drawer: isDesktop
                ? const DeskTopDrawer(
                    currentPage: 'Home',
                  )
                : null,
            backgroundColor: theme.scaffoldColor,
            appBar: const PreferredSize(
              preferredSize: Size.fromHeight(kToolbarHeight),
              child: YoutubeAppBar(),
            ),
            body: NoInternetPage(),
          );
        }
      }

      // Desktop and Tablet layout
      return Scaffold(
          drawer: isDesktop
              ? DeskTopDrawer(
                  header: _buildHeader(),
                  currentPage: 'Home',
                )
              : null,
          backgroundColor: theme.scaffoldColor,
          appBar: const PreferredSize(
            preferredSize: Size.fromHeight(kToolbarHeight),
            child: YoutubeAppBar(),
          ),
          body: ScrollConfiguration(
            // Add this wrapper
            behavior: ScrollConfiguration.of(context).copyWith(
              scrollbars: false, // Hide default scrollbar
            ),
            child: RawScrollbar(
              thumbColor:
                  isDark ? Colors.grey[300] : Colors.black.withOpacity(0.2),
              radius: Radius.zero,
              thickness: 15,
              minThumbLength: 50,
              thumbVisibility: true,
              trackVisibility: false,
              pressDuration: Duration.zero, // Instant thumb appearance on press
              fadeDuration:
                  const Duration(milliseconds: 300), // Smooth fade animation
              interactive: true,
              controller: _mainScrollController,
              child: NotificationListener<ScrollNotification>(
                onNotification: (ScrollNotification scrollInfo) {
                  if (scrollInfo.metrics.pixels ==
                      scrollInfo.metrics.maxScrollExtent) {
                    _fetchMoreVideos();
                  }
                  if (scrollInfo.metrics.pixels ==
                          scrollInfo.metrics.maxScrollExtent &&
                      isDesktop) {
                    _fetchMoreComments();
                  }
                  return false;
                },
                child: SingleChildScrollView(
                  controller: _mainScrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            // Actuall Content............
                            _buildVideoPlayer(isMobile, isTablet),
                            Consumer<ApiProviders>(
                                builder: (context, value, child) {
                              bool hasLikes =
                                  widget.video.statistics?.likeCount != null;
                              if (hasLikes)
                                print("Yes like");
                              else
                                print("No like");
                              print(
                                  "Statistics: ${widget.video.statistics.toString()}");
                              if (widget.video.statistics?.likeCount == null) {
                                print(
                                    "Warning: likeCount is missing in statistics.");
                              }

                              switch (value.channelResponse.status) {
                                case ApiStatus.Loading:
                                  return const Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: Center(
                                      child: VideoViewShimmer(),
                                    ),
                                  );
                                case ApiStatus.Complete:
                                  return VideoView(
                                    showdescription: _showDescription(),
                                    preview: _buildCommentsPreview(),
                                    //   likeCount: '0',
                                    likeCount: hasLikes
                                        ? Formates().formatLikes(widget
                                            .video.statistics!.likeCount
                                            .toString())
                                        : "Like",
                                    //   customUrl: value.channel!.customUrl,
                                    channelId: value.channel!.id!,
                                    avator: value.channel!.avatar.toString(),
                                    title:
                                        widget.video.snippet!.title.toString(),
                                    channel: value.channel!.title.toString(),
                                    //   views: '34k',
                                    views: Formates().formatViewCount(widget
                                        .video.statistics!.viewCount
                                        .toString()),
                                    // publishTime: '3 m',
                                    publishTime: Formates().timeAgo(widget
                                        .video.snippet!.publishedAt
                                        .toString()),
                                    // subscribers: '343',
                                    subscribers: Formates().formatsubCount(value
                                        .channel!.subscriberCount
                                        .toString()),
                                    descriptions: widget
                                        .video.snippet!.description
                                        .toString(),
                                  );
                                case ApiStatus.Error:
                                  // Check for quota exceeded error
                                  if (value.channelResponse.message
                                      .toString()
                                      .contains('quota')) {
                                    return const QuotaExceededErrorPage();
                                  }
                                  // No Internet Connections error..
                                  if (!value.channelResponse.message
                                          .toString()
                                          .contains('quota') &&
                                      value.channelResponse.message
                                          .toString()
                                          .contains(
                                              'Error During Communication')) {
                                    return const NoInternetPage();
                                  }
                                  return Center(
                                      child: Text(value.channelResponse.message
                                          .toString()));
                                default:
                                  return const Center(
                                      child: Text('Unexpected state'));
                              }
                            }),

                            isTablet
                                ? const SizedBox.shrink()
                                : Consumer<ApiProviders>(
                                    builder: (context, value, child) {
                                      return _buildCommentSection(value);
                                    },
                                  ),

                            if (isTablet)
                              Consumer<ApiProviders>(
                                builder: (context, value, child) {
                                  return _buildRecommendationsList(
                                      value, isMobile, isTablet);
                                },
                              ),
                          ],
                        ),
                      ),
                      if (isDesktop)
                        Container(
                          width: 500,
                          color: theme.scaffoldColor,
                          child: Consumer<ApiProviders>(
                            builder: (context, value, child) {
                              return _buildRecommendationsList(
                                  value, false, false);
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ));
    });
  }

  Widget _buildHeader() {
    final theme = Provider.of<YouTubeTheme>(context);
    final isDark = theme.isDarkMode;
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20, top: 20, bottom: 20),
          child: IconButton(
            icon: Icon(Icons.menu, color: isDark ? Colors.white : Colors.black),
            onPressed: () {
              Scaffold.of(context).closeDrawer();
            },
          ),
        ),
        const SizedBox(width: 16),
        Image.asset(
          isDark ? 'assets/images/yt_logo_dark.png' : 'assets/images/logo.png',
          height: 20,
          fit: BoxFit.contain,
        ),
      ],
    );
  }
}
