// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:video_player/video_player.dart';
// import 'package:visibility_detector/visibility_detector.dart';
// import 'package:youtube/provider/short_video_controller.dart';
//
// class ShortsVideoPlayer extends StatefulWidget {
//   final String videoId;
//   final String thumbnail;
//
//   const ShortsVideoPlayer({
//     Key? key,
//     required this.videoId,
//     required this.thumbnail,
//   }) : super(key: key);
//
//   @override
//   State<ShortsVideoPlayer> createState() => _ShortsVideoPlayerState();
// }
//
// class _ShortsVideoPlayerState extends State<ShortsVideoPlayer> {
//   late VideoProvider videoProvider;
//
//   @override
//   void initState() {
//     super.initState();
//     videoProvider = Provider.of<VideoProvider>(context, listen: false);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return VisibilityDetector(
//       key: Key(widget.videoId),
//       onVisibilityChanged: (visibilityInfo) {
//         if (visibilityInfo.visibleFraction >= 0.8) {
//           videoProvider.initializeVideo(widget.videoId);
//           videoProvider.play();
//         } else {
//           videoProvider.pause();
//         }
//       },
//       child: Consumer<VideoProvider>(
//         builder: (context, provider, child) {
//           if (!provider.isInitialized || provider.isLoading) {
//             return Stack(
//               fit: StackFit.expand,
//               children: [
//                 Image.network(
//                   widget.thumbnail,
//                   fit: BoxFit.cover,
//                 ),
//                 const Center(
//                   child: CircularProgressIndicator(
//                     color: Colors.white,
//                   ),
//                 ),
//               ],
//             );
//           }
//
//           return GestureDetector(
//             onTap: provider.togglePlay,
//             child: Stack(
//               alignment: Alignment.center,
//               children: [
//                 AspectRatio(
//                   aspectRatio: provider.controller!.value.aspectRatio,
//                   child: VideoPlayer(provider.controller!),
//                 ),
//                 if (!provider.isPlaying)
//                   Container(
//                     decoration: BoxDecoration(
//                       color: Colors.black.withOpacity(0.3),
//                     ),
//                     child: const Icon(
//                       Icons.play_arrow,
//                       size: 60,
//                       color: Colors.white,
//                     ),
//                   ),
//                 // Add loading indicator when buffering
//                 if (provider.controller!.value.isBuffering)
//                   const Center(
//                     child: CircularProgressIndicator(
//                       color: Colors.white,
//                     ),
//                   ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
