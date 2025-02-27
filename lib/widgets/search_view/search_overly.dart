// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:youtube/constants/localizations.dart';
// import 'package:youtube/model/videos_model.dart';
// import 'package:youtube/provider/search_provider.dart';

// class SearchOverlay extends StatelessWidget {
//   const SearchOverlay({Key? key}) : super(key: key);

//   static void show(BuildContext context) {
//     showGeneralDialog(
//       context: context,
//       barrierDismissible: true,
//       barrierLabel: "Search",
//       barrierColor: Colors.black54,
//       transitionDuration: const Duration(milliseconds: 200),
//       pageBuilder: (context, anim1, anim2) => const SearchOverlay(),
//       transitionBuilder: (context, anim1, anim2, child) {
//         return SlideTransition(
//           position: Tween(
//             begin: const Offset(0, -1),
//             end: const Offset(0, 0),
//           ).animate(anim1),
//           child: child,
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final isDark = theme.brightness == Brightness.dark;

//     return Material(
//       color: Colors.transparent,
//       child: Column(
//         children: [
//           Container(
//             color: theme.scaffoldBackgroundColor,
//             child: SafeArea(
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   _buildSearchHeader(context),
//                   const Divider(height: 1),
//                 ],
//               ),
//             ),
//           ),
//           Expanded(
//             child: Container(
//               color: theme.scaffoldBackgroundColor,
//               child: Consumer<SearchProvider>(
//                 builder: (context, searchProvider, _) {
//                   if (searchProvider.currentQuery?.isEmpty ?? true) {
//                     return _buildSearchSuggestions(context);
//                   }
//                   return _buildSearchResults(context);
//                 },
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSearchHeader(BuildContext context) {
//     return Row(
//       children: [
//         IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () => Navigator.pop(context),
//         ),
//         Expanded(
//           child: Consumer<SearchProvider>(
//             builder: (context, searchProvider, _) {
//               return TextField(
//                 autofocus: true,
//                 decoration: const InputDecoration(
//                   hintText: 'Search YouTube',
//                   border: InputBorder.none,
//                   contentPadding: EdgeInsets.symmetric(horizontal: 16),
//                 ),
//                 onChanged: (query) {
//                   searchProvider.getSuggestions(query);
//                 },
//                 onSubmitted: (query) {
//                   searchProvider.search(query);
//                 },
//               );
//             },
//           ),
//         ),
//         IconButton(
//           icon: const Icon(Icons.mic),
//           onPressed: () {
//             // Implement voice search
//           },
//         ),
//       ],
//     );
//   }

//   Widget _buildSearchSuggestions(BuildContext context) {
//     return Consumer<SearchProvider>(
//       builder: (context, searchProvider, _) {
//         if (searchProvider.isLoadingSuggestions) {
//           return const Center(child: CircularProgressIndicator());
//         }

//         return ListView.builder(
//           itemCount: searchProvider.searchSuggestions.length,
//           itemBuilder: (context, index) {
//             final suggestion = searchProvider.searchSuggestions[index];
//             return ListTile(
//               leading: const Icon(Icons.search),
//               title: Text(suggestion),
//               onTap: () {
//                 searchProvider.search(suggestion);
//               },
//             );
//           },
//         );
//       },
//     );
//   }

//   Widget _buildSearchResults(BuildContext context) {
//     return Consumer<SearchProvider>(
//       builder: (context, searchProvider, _) {
//         // if (searchProvider.searchResponse.isLoading) {
//         //   return const Center(child: CircularProgressIndicator());
//         // }

//         // if (searchProvider.searchResponse.error != null) {
//         //   return Center(
//         //     child: Text('Error: ${searchProvider.searchResponse.error}'),
//         //   );
//         // }

//         return NotificationListener<ScrollNotification>(
//           onNotification: (scrollInfo) {
//             if (!searchProvider.isLoadingMore &&
//                 searchProvider.hasMoreResults &&
//                 scrollInfo.metrics.pixels ==
//                     scrollInfo.metrics.maxScrollExtent) {
//               searchProvider.loadMore();
//             }
//             return true;
//           },
//           child: ListView.builder(
//             itemCount: searchProvider.searchResults.length + 1,
//             itemBuilder: (context, index) {
//               if (index == searchProvider.searchResults.length) {
//                 return searchProvider.isLoadingMore
//                     ? const Center(
//                         child: Padding(
//                           padding: EdgeInsets.all(16.0),
//                           child: CircularProgressIndicator(),
//                         ),
//                       )
//                     : const SizedBox.shrink();
//               }

//               final video = searchProvider.searchResults[index];
//               return _buildSearchResultItem(context, video);
//             },
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildSearchResultItem(BuildContext context, Video video) {
//     return InkWell(
//       onTap: () {
//         // Navigate to video player while dismissing the search overlay
//         Navigator.pop(context);
//         // Add your navigation logic here
//       },
//       child: Padding(
//         padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//         child: Row(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Thumbnail
//             ClipRRect(
//               borderRadius: BorderRadius.circular(8),
//               child: SizedBox(
//                 width: 120,
//                 height: 68,
//                 child: Image.network(
//                   video.snippet!.thumbnails!.maxres!.url.toString() ?? '',
//                   fit: BoxFit.cover,
//                 ),
//               ),
//             ),
//             const SizedBox(width: 12),
//             // Video details
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     video.snippet!.title.toString() ?? '',
//                     maxLines: 2,
//                     overflow: TextOverflow.ellipsis,
//                     style: const TextStyle(
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     '${video.snippet!.channelTitle.toString()} • ${Formates().formatViewCount(video.statistics!.viewCount.toString())} views',
//                     style: Theme.of(context).textTheme.bodySmall,
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
