// import 'package:flutter/material.dart';
// import 'package:media_kit_video/media_kit_video.dart';
// import 'package:provider/provider.dart';
// import 'package:youtube/provider/video_player_controller.dart';

// class OptimizedVideoPlayer extends StatelessWidget {
//   final String videoId;
//   final bool isMobile;
//   final bool isTablet;
//   final VoidCallback? onReturn;

//   const OptimizedVideoPlayer({
//     Key? key,
//     required this.videoId,
//     required this.isMobile,
//     required this.isTablet,
//     this.onReturn,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return ChangeNotifierProvider(
//       create: (_) => VideoPlayerProvider(),
//       child: _VideoPlayerContent(
//         videoId: videoId,
//         isMobile: isMobile,
//         isTablet: isTablet,
//         onReturn: onReturn,
//       ),
//     );
//   }
// }

// class _VideoPlayerContent extends StatefulWidget {
//   final String videoId;
//   final bool isMobile;
//   final bool isTablet;
//   final VoidCallback? onReturn;

//   const _VideoPlayerContent({
//     Key? key,
//     required this.videoId,
//     required this.isMobile,
//     required this.isTablet,
//     this.onReturn,
//   }) : super(key: key);

//   @override
//   State<_VideoPlayerContent> createState() => _VideoPlayerContentState();
// }

// class _VideoPlayerContentState extends State<_VideoPlayerContent> {
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       context.read<VideoPlayerProvider>().setVideo(widget.videoId);
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<VideoPlayerProvider>(
//       builder: (context, provider, child) {
//         if (!provider.isInitialized) {
//           return const Center(child: CircularProgressIndicator());
//         }

//         return Container(
//           padding: widget.isMobile
//               ? EdgeInsets.zero
//               : widget.isTablet
//                   ? const EdgeInsets.symmetric(horizontal: 20, vertical: 10)
//                   : const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
//           child: Stack(
//             children: [
//               ClipRRect(
//                 borderRadius: widget.isMobile
//                     ? BorderRadius.zero
//                     : BorderRadius.circular(10),
//                 child: AspectRatio(
//                   aspectRatio: 16 / 9,
//                   child: Stack(
//                     children: [
//                       Video(
//                         controller: provider.controller,
//                         controls: AdaptiveVideoControls,
//                       ),
//                       if (!provider.isPlaying)
//                         Center(
//                           child: CircularProgressIndicator(
//                             valueColor:
//                                 AlwaysStoppedAnimation<Color>(Colors.red),
//                           ),
//                         ),
//                     ],
//                   ),
//                 ),
//               ),
//               if (widget.isMobile && widget.onReturn != null)
//                 Positioned(
//                   top: 10,
//                   left: 10,
//                   child: GestureDetector(
//                     onTap: widget.onReturn,
//                     child: Container(
//                       padding: const EdgeInsets.all(8),
//                       decoration: BoxDecoration(
//                         color: Colors.black.withOpacity(0.6),
//                         borderRadius: BorderRadius.circular(20),
//                       ),
//                       child: const Icon(
//                         Icons.arrow_back,
//                         color: Colors.white,
//                       ),
//                     ),
//                   ),
//                 ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }
