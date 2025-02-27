// import 'dart:math';

// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:page_transition/page_transition.dart';
// import 'package:provider/provider.dart';
// import 'package:youtube/constants/appcolors.dart';
// import 'package:youtube/constants/localizations.dart';
// import 'package:youtube/network/response/api_status.dart';
// import 'package:youtube/model/categories.dart';
// import 'package:youtube/provider/api_providers.dart';
// import 'package:youtube/responsive/responsiveness.dart';

// import 'package:youtube/view/video_view_page.dart';
// import 'package:youtube/widgets/app_bar.dart';
// import 'package:youtube/widgets/desktop_drawer_items.dart';

// import 'package:youtube/widgets/feed.dart';
// import 'package:youtube/widgets/home_feed_shimmer_effect.dart';
// import 'package:youtube/widgets/secondary_appbar.dart';
// import 'package:youtube/widgets/video_view.dart';

// class MobileHomeScreen extends StatefulWidget {
//   final TrackingScrollController scrollController;
//   MobileHomeScreen({super.key, required this.scrollController});

//   @override
//   State<MobileHomeScreen> createState() => _MobileHomeScreenState();
// }

// class _MobileHomeScreenState extends State<MobileHomeScreen> {
//   ScrollController _scrollController = ScrollController();
//   late int selectedTabIndex;
//   String query = "new";
//   String id = "";
//   String? selectedCategoryId; // Store the category ID if selected
//   bool isFetchingMore = false;

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
//       // Get the provider instance
//       final apiProvider = Provider.of<ApiProviders>(context, listen: false);

//       // Only fetch videos if needed
//       if (apiProvider.shouldReloadVideos(query)) {
//         _fetchVideos(query);
//       }
//     });
//   }

//   void _fetchVideos(String query) {
//     Provider.of<ApiProviders>(context, listen: false).fetchVideos(query);
//   }

//   void _fetchMoreVideos() {
//     if (!isFetchingMore) {
//       setState(() {
//         isFetchingMore = true;
//       });

//       // Check if fetching for category or general videos
//       if (selectedCategoryId == null) {
//         Provider.of<ApiProviders>(context, listen: false)
//             .fetchMoreVideos(query)
//             .then((_) {
//           setState(() {
//             isFetchingMore = false;
//           });
//         });
//       } else {
//         Provider.of<ApiProviders>(context, listen: false)
//             .fetchMoreVideos(selectedCategoryId!)
//             .then((_) {
//           setState(() {
//             isFetchingMore = false;
//           });
//         });
//       }
//     }
//   }

//   @override
//   void dispose() {
//     _scrollController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final bool isMobile = Responsive.isMobile(context);
//     final bool isTablet = Responsive.isTablet(context);
//     final bool isDesktop = Responsive.isDesktop(context);

//     final List<String?> categoriesId = Categories.categoryMap.keys.toList();
//     Size size = MediaQuery.of(context).size;
//     return Scaffold(
//       backgroundColor: AppColors.white,
//       drawer: Drawer(
//         backgroundColor: AppColors.white,
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.start,
//           crossAxisAlignment: CrossAxisAlignment.start,

//           //   padding: EdgeInsets.zero,
//           children: <Widget>[
//             const SizedBox(
//               height: 10,
//             ),
//             ListTile(
//               leading: SizedBox(
//                 height: size.height * 0.20,
//                 width: size.width * 0.35,
//                 child: Image.asset(
//                   'assets/images/logo.png',
//                   fit: BoxFit.cover,
//                 ),
//               ),
//             ),
//             const SizedBox(
//               height: 30,
//             ),
//             DrawerItems(
//                 image: Image.asset(
//                   'assets/icons/trending.png',
//                   height: 30,
//                 ),
//                 title: 'Trending'),
//             const SizedBox(
//               height: 20,
//             ),
//             DrawerItems(
//                 image: Image.asset(
//                   'assets/icons/music.png',
//                   height: 30,
//                 ),
//                 title: 'Music'),
//             const SizedBox(
//               height: 20,
//             ),
//             DrawerItems(
//                 image: Image.asset(
//                   'assets/icons/movie.png',
//                   height: 30,
//                 ),
//                 title: 'Movies & TV'),
//             const SizedBox(
//               height: 20,
//             ),
//             DrawerItems(
//                 image: Image.asset(
//                   'assets/icons/sports.png',
//                   height: 30,
//                 ),
//                 title: 'Sports'),
//             const SizedBox(
//               height: 20,
//             ),
//             DrawerItems(
//                 image: Image.asset(
//                   'assets/icons/signal.png',
//                   height: 30,
//                 ),
//                 title: 'Podcasts'),
//             const Divider(),
//             const SizedBox(
//               height: 20,
//             ),
//             ListTile(
//               leading: Image.asset(
//                 "assets/icons/youtube.png",
//                 height: 30,
//               ),
//               title: Text('YouTube Premium',
//                   style: GoogleFonts.poppins(
//                     fontSize: 16,
//                   )),
//             ),
//             const SizedBox(
//               height: 20,
//             ),
//             DrawerItems(
//                 image: Image.asset(
//                   'assets/icons/ytmusic.png',
//                   height: 30,
//                 ),
//                 title: 'YouTube Studio'),
//           ],
//         ),
//       ),
//       body: NotificationListener<ScrollNotification>(
//         onNotification: (ScrollNotification scrollInfo) {
//           if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
//             // Fetch more videos or category videos when scrolled to the bottom
//             _fetchMoreVideos();
//           }
//           return false;
//         },
//         child: CustomScrollView(
//           controller: widget.scrollController,
//           slivers: [
//             // SliverAppBar with floating behavior
//             SliverAppBar(
//               backgroundColor: AppColors.white,
//               expandedHeight: 50,
//               floating: true,
//               pinned: false,
//               snap: true,
//               centerTitle: false,
//               automaticallyImplyLeading: false,
//               title: const Appbar(),
//               elevation: 0,
//             ),
//             SliverAppBar(
//               backgroundColor: AppColors.white,
//               automaticallyImplyLeading: false,
//               elevation: 0,
//               pinned: true,
//               bottom: PreferredSize(
//                   preferredSize: const Size.fromHeight(-10),
//                   child: SecondaryAppbar(
//                     selectedIndex: selectedTabIndex,
//                     onTabSelected: (int index) {
//                       setState(() {
//                         selectedTabIndex = index + 1;
//                         final apiProvider =
//                             Provider.of<ApiProviders>(context, listen: false);

//                         if (index == 0) {
//                           query = "new";
//                           selectedCategoryId = null;

//                           // Only fetch if needed
//                           if (apiProvider.shouldReloadVideos(query)) {
//                             _fetchVideos(query);
//                           }
//                         } else {
//                           selectedCategoryId = categoriesId[index];
//                           if (selectedCategoryId != null) {
//                             // Only fetch if needed
//                             if (apiProvider
//                                 .shouldReloadVideos(selectedCategoryId!)) {
//                               print(selectedCategoryId);
//                               apiProvider.fetchVideos(selectedCategoryId!);
//                             }
//                           }
//                         }
//                       });
//                     },
//                     showCompassIcon: true,
//                   )),
//             ),

//             Consumer<ApiProviders>(
//               builder: (context, value, child) {
//                 switch (value.videoResponse.status) {
//                   case ApiStatus.Loading:
//                     return SliverGrid(
//                       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                           crossAxisSpacing: 5,
//                           mainAxisSpacing: 5,
//                           crossAxisCount: isMobile
//                               ? 1
//                               : isTablet
//                                   ? 2
//                                   : 4),
//                       delegate: SliverChildBuilderDelegate(
//                         (context, index) => const ShimmerLoading(),
//                         childCount: isMobile
//                             ? 5
//                             : isTablet
//                                 ? 10
//                                 : 20, // Show a fixed number of shimmer items during loading
//                       ),
//                     );
//                   case ApiStatus.Complete:
//                     return SliverGrid(
//                         gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                             crossAxisSpacing: 5,
//                             mainAxisSpacing: 5,
//                             crossAxisCount: isMobile
//                                 ? 1
//                                 : isTablet
//                                     ? 2
//                                     : 4),
//                         delegate: SliverChildBuilderDelegate(
//                             childCount: value.videoList.length +
//                                 (value.isLoadingMore ? 1 : 0),
//                             (context, index) {
//                           print("list length : ${value.videoList.length}");
//                           if (index == value.videoList.length) {
//                             // If it's the last index and fetching more videos, show loading indicator
//                             if (isFetchingMore) {
//                               return const Padding(
//                                 padding: EdgeInsets.all(16.0),
//                                 child: Center(
//                                   child: CircularProgressIndicator(
//                                     color: Colors.blue,
//                                   ),
//                                 ),
//                               );
//                             } else {
//                               return const SizedBox.shrink();
//                             }
//                           }

//                           var video = value.videoList[index];
//                           // var channelId = video.snippet!.channelId;
//                           // if(channelId != null){}
//                           // Provider.of<ApiProviders>(context, listen: false)
//                           //     .fetchChannel(channelId!);

//                           //   var channel = value.channel[channelId]!;

//                           //    var channelinfo = channel.snippet;
//                           return GestureDetector(
//                               onTap: () {
//                                 Navigator.push(
//                                   context,
//                                   PageTransition(
//                                       type: PageTransitionType.bottomToTop,
//                                       child: VideoPlayPage(
//                                         video: video,
//                                         id: video.snippet!.channelId!,
//                                       ),
//                                       inheritTheme: true,
//                                       ctx: context),
//                                 );
//                               },
//                               child: HomeFeed(
//                                 avator: video.snippet!.thumbnails!.high!.url
//                                     .toString(),
//                                 thumbnail: video.snippet!.thumbnails!.high!.url
//                                     .toString(),
//                                 title: video.snippet!.title.toString(),
//                                 channel: video.snippet!.channelTitle.toString(),
//                                 views: Formates().formatViewCount(
//                                     video.statistics!.viewCount.toString()),
//                                 publishTime: Formates().timeAgo(
//                                   video.snippet!.publishedAt.toString(),
//                                 ),
//                                 durrations: Formates().videoDurations(
//                                   video.contentDetails!.duration.toString(),
//                                 ),
//                               ));

//                           // return const SizedBox();
//                         }));

//                   case ApiStatus.Error:
//                     return SliverToBoxAdapter(
//                         child: Center(
//                             child:
//                                 Text(value.videoResponse.message.toString())));
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
