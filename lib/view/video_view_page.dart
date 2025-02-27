// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:page_transition/page_transition.dart';
// import 'package:provider/provider.dart';
// import 'package:youtube/constants/appcolors.dart';
// import 'package:youtube/constants/localizations.dart';
// import 'package:youtube/model/videos_model.dart';
// import 'package:youtube/network/response/api_status.dart';
// import 'package:youtube/provider/api_providers.dart';
// import 'package:youtube/view/home_page.dart';
// import 'package:youtube/view/mobile_home_screen.dart';
// import 'package:youtube/widgets/feed.dart';
// import 'package:youtube/widgets/home_feed_shimmer_effect.dart';
// import 'package:youtube/widgets/video_page_shimmer_effect.dart';
// import 'package:youtube/widgets/video_view.dart';

// class VideoPlayPage extends StatefulWidget {
//   final String id;
//   final Video video;
//   const VideoPlayPage({super.key, required this.video, required this.id});

//   @override
//   State<VideoPlayPage> createState() => _VideoPlayPageState();
// }

// class _VideoPlayPageState extends State<VideoPlayPage> {
//   final TrackingScrollController scrollController =
//       TrackingScrollController(); // Use TrackingScrollController
//   ScrollController _scrollController = ScrollController();
//   bool isFetchingMore = false;
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
//       Provider.of<ApiProviders>(context, listen: false).fetchChannel(widget.id);
//       Provider.of<ApiProviders>(context, listen: false)
//           .fetchRelatedVideos(widget.video.snippet!.title!);
//     });
//   }

//   void _fetchMoreVideos() {
//     if (!isFetchingMore) {
//       setState(() {
//         isFetchingMore = true;
//       });

//       Provider.of<ApiProviders>(context, listen: false)
//           .fetchMoreRelatedVideos(widget.video.snippet!.title!)
//           .then((_) {
//         setState(() {
//           isFetchingMore = false;
//         });
//       });
//     }
//   }

//   @override
//   void dispose() {
//     _scrollController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     Size size = MediaQuery.of(context).size;
//     return Scaffold(
//       backgroundColor: AppColors.white,
//       body: NotificationListener<ScrollNotification>(
//         onNotification: (ScrollNotification scrollInfo) {
//           if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
//             // Fetch more videos or category videos when scrolled to the bottom
//             _fetchMoreVideos();
//           }
//           return false;
//         },
//         child: CustomScrollView(
//           controller: _scrollController,
//           slivers: [
//             SliverPersistentHeader(
//               pinned: true,
//               delegate: _ThumbnailHeaderDelegate(
//                 videoThumbnailUrl:
//                     widget.video.snippet!.thumbnails!.high!.url.toString(),
//                 onBackPressed: () {
//                   Navigator.push(
//                     context,
//                     PageTransition(
//                         type: PageTransitionType.topToBottom,
//                         duration: Duration(milliseconds: 400),
//                         child: MobileHomeScreen(
//                           scrollController: scrollController,
//                         ),
//                         inheritTheme: true,
//                         ctx: context),
//                   );
//                 },
//                 height: size.height * 0.27,
//               ),
//             ),
//             SliverToBoxAdapter(
//               child: Consumer<ApiProviders>(
//                 builder: (context, value, child) {
//                   switch (value.channelResponse.status) {
//                     case ApiStatus.Loading:
//                       return const Padding(
//                         padding: EdgeInsets.all(16.0),
//                         child: Center(
//                           child: VideoViewShimmer(),
//                         ),
//                       );
//                     case ApiStatus.Complete:
//                       return VideoView(
//                         channelId: value.channel!.id!,
//                         descriptions: value.channel!.description.toString(),
//                         avator: value.channel!.avator.toString(),
//                         title: widget.video.snippet!.title.toString(),
//                         channel: value.channel!.title.toString(),
//                         subscribers: Formates().formatsubCount(
//                             value.channel!.subscriberCount.toString()),
//                         views: Formates().formatViewCount(
//                             widget.video.statistics!.viewCount.toString()),
//                         publishTime: Formates().timeAgo(
//                             widget.video.snippet!.publishedAt.toString()),
//                       );
//                     case ApiStatus.Error:
//                       return Center(
//                           child:
//                               Text(value.channelResponse.message.toString()));
//                     default:
//                       return const Center(child: Text('Unexpected state'));
//                   }
//                 },
//               ),
//             ),
//             Consumer<ApiProviders>(
//               builder: (context, value, child) {
//                 switch (value.recommendationResponse.status) {
//                   case ApiStatus.Loading:
//                     return SliverList(
//                       delegate: SliverChildBuilderDelegate(
//                         (context, index) => const ShimmerLoading(),
//                         childCount:
//                             5, // Show a fixed number of shimmer items during loading
//                       ),
//                     );
//                   case ApiStatus.Complete:
//                     return SliverList(
//                         delegate: SliverChildBuilderDelegate(
//                             childCount: value.recommendedList.length +
//                                 (value.isLoadingMore ? 1 : 0),
//                             (context, index) {
//                       print("list length : ${value.recommendedList.length}");
//                       if (index == value.recommendedList.length) {
//                         // If it's the last index and fetching more videos, show loading indicator
//                         if (isFetchingMore) {
//                           return const Padding(
//                             padding: EdgeInsets.all(16.0),
//                             child: Center(
//                               child: CircularProgressIndicator(
//                                 color: Colors.blue,
//                               ),
//                             ),
//                           );
//                         } else {
//                           return const SizedBox.shrink();
//                         }
//                       }
//                       var channel = value.recommendedList[index];
//                       return GestureDetector(
//                         onTap: () {
//                           // Navigate to VideoPlayPage with the selected video's data
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => VideoPlayPage(
//                                 video: channel, // Pass the selected video
//                                 id: channel
//                                     .snippet!.channelId!, // Pass the video ID
//                               ),
//                             ),
//                           );
//                         },
//                         child: HomeFeed(
//                             durrations: Formates().videoDurations(
//                                 channel.contentDetails!.duration.toString()),
//                             title: channel.snippet!.title.toString(),
//                             channel: channel.snippet!.channelTitle.toString(),
//                             views: Formates().formatViewCount(
//                                 channel.statistics!.viewCount.toString()),
//                             publishTime: Formates().timeAgo(
//                                 channel.snippet!.publishedAt.toString()),
//                             thumbnail: channel.snippet!.thumbnails!.high!.url
//                                 .toString(),
//                             avator: channel.snippet!.thumbnails!.high!.url
//                                 .toString()),
//                       );
//                     }));

//                   case ApiStatus.Error:
//                     return SliverToBoxAdapter(
//                         child: Center(
//                             child: Text(value.recommendationResponse.message
//                                 .toString())));
//                   default:
//                     return const SliverToBoxAdapter(
//                         child: Center(child: Text('Unexpected state')));
//                 }
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _ThumbnailHeaderDelegate extends SliverPersistentHeaderDelegate {
//   final String videoThumbnailUrl;
//   final VoidCallback onBackPressed;
//   final double height;

//   _ThumbnailHeaderDelegate({
//     required this.videoThumbnailUrl,
//     required this.onBackPressed,
//     required this.height,
//   });

//   @override
//   double get minExtent => height;
//   @override
//   double get maxExtent => height;

//   @override
//   Widget build(
//       BuildContext context, double shrinkOffset, bool overlapsContent) {
//     return Stack(
//       fit: StackFit.expand,
//       children: [
//         AspectRatio(
//           aspectRatio: 16 / 9,
//           child: Image.network(
//             videoThumbnailUrl,
//             fit: BoxFit.cover,
//           ),
//         ),
//         Positioned(
//           top: 20,
//           left: 8,
//           child: GestureDetector(
//             onTap: onBackPressed,
//             child: Icon(
//               CupertinoIcons.back,
//               color: AppColors.white,
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   @override
//   bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
//     return false;
//   }
// }
