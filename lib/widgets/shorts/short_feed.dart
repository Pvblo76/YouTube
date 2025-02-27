import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:youtube/constants/appcolors.dart';
import 'package:youtube/responsive/responsiveness.dart';
import 'package:youtube/widgets/CircleAvatar/Custome_circle_avatar.dart';
import 'package:youtube/widgets/routes/app_routes.dart';
import 'package:youtube/widgets/routes/routes.dart';
import 'package:youtube/widgets/subscribe/subscribe_button.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class ShortFeed extends StatefulWidget {
  final String videoId;
  final String channelId;
  final String name;
  final String title;
  final String avatar;
  final String thumbnail;
  final String likeCounts;
  final String commentsCounts;

  const ShortFeed({
    super.key,
    required this.thumbnail,
    required this.name,
    required this.title,
    required this.avatar,
    required this.channelId,
    required this.likeCounts,
    required this.commentsCounts,
    required this.videoId,
  });

  @override
  State<ShortFeed> createState() => _ShortFeedState();
}

class _ShortFeedState extends State<ShortFeed> {
  late YoutubePlayerController _controller;
  final ValueNotifier<bool> _isLoading = ValueNotifier(true);

  @override
  void initState() {
    _controller = YoutubePlayerController.fromVideoId(
      videoId: widget.videoId,
      autoPlay: true,
      params: const YoutubePlayerParams(
        showControls: false,
        showFullscreenButton: false,
        mute: false,

        //  pointerEvents: PointerEvents.none, // Prevent touch events on the player
      ),
    )..listen((event) {
        if (event.playerState == PlayerState.playing) {
          _isLoading.value = false;
        }
      });
    super.initState();
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  void _navigateToChannel() {
    Navigator.pushNamed(
      context,
      RouteNames.channel,
      arguments: ChannelArgs(channelId: widget.channelId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final bool isMobile = Responsive.isMobile(context);

    final containerWidth = screenWidth < 600 ? screenWidth : 360.0;
    final containerHeight = screenHeight;

    return GestureDetector(
      // Prevent horizontal scroll/swipe
      onHorizontalDragDown: (_) {},
      onHorizontalDragUpdate: (_) {},
      onHorizontalDragEnd: (_) {},
      child: Container(
        width: containerWidth,
        height: containerHeight,
        margin: EdgeInsets.symmetric(horizontal: isMobile ? 0 : 8),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Video Player with VisibilityDetector
            VisibilityDetector(
              key: Key('youtube-player-${widget.videoId}'),
              onVisibilityChanged: (VisibilityInfo info) {
                if (info.visibleFraction < 0.5) {
                  _controller.pauseVideo();
                } else if (info.visibleFraction > 0.5) {
                  _controller.playVideo();
                }
              },
              child: ClipRRect(
                borderRadius:
                    isMobile ? BorderRadius.zero : BorderRadius.circular(12),
                child: YoutubePlayerScaffold(
                  controller: _controller,
                  builder: (context, player) {
                    return AbsorbPointer(
                      absorbing:
                          true, // Prevent touch interactions with the video player
                      child: Container(
                        child: player,
                      ),
                    );
                  },
                ),
              ),
            ),
            // Custom tap detector on top
            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  // Toggle play/pause on tap
                  if (_controller.value.playerState == PlayerState.playing) {
                    _controller.pauseVideo();
                  } else {
                    _controller.playVideo();
                  }
                },
                behavior: HitTestBehavior
                    .translucent, // Allows the tap to pass through while still detecting it
              ),
            ),
            // Loading Indicator
            ValueListenableBuilder<bool>(
              valueListenable: _isLoading,
              builder: (context, isLoading, _) {
                return isLoading
                    ? Positioned.fill(
                        child: ClipRRect(
                          borderRadius: isMobile
                              ? BorderRadius.zero
                              : BorderRadius.circular(12),
                          child: Container(
                            color: Colors.black,
                            child: const Center(
                              child: CircularProgressIndicator(
                                  color: Colors.white),
                            ),
                          ),
                        ),
                      )
                    : const SizedBox.shrink();
              },
            ),

            // Gradient Overlay
            if (!isMobile)
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.3),
                      Colors.black.withOpacity(0.7)
                    ],
                  ),
                ),
              ),

            // Bottom Content
            Positioned(
              bottom: 30,
              left: 8,
              right: 8,
              child: _buildBottomContent(),
            ),

            // Right Side Buttons
            Positioned(
              top: 0,
              bottom: 0,
              right: 20,
              child: FractionallySizedBox(
                heightFactor: 0.5,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildSocialButton(
                        widget.likeCounts, 'assets/icons/like_white.png',
                        height: 25),
                    _buildSocialButton('Dislike', 'assets/icons/dislike.png',
                        height: 25),
                    _buildSocialButton(
                        widget.commentsCounts, 'assets/icons/comment_white.png',
                        height: 35),
                    _buildSocialButton('Share', 'assets/icons/share-arrow.png',
                        height: 25),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Rest of your existing methods (_buildBottomContent and _buildSocialButton) remain the same

  Widget _buildBottomContent() {
    final bool isMobile = Responsive.isMobile(context);
    return // Bottom Overlay Content
        Material(
      color: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _navigateToChannel,
                  child: CustomCircleAvatar(avatarUrl: widget.avatar),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      children: [
                        Flexible(
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: _navigateToChannel,
                            child: Text(
                              widget.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                fontSize: isMobile ? 12 : 14,
                                color: AppColors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const SubscribeButton(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                widget.title,
                maxLines: 2,
                style: GoogleFonts.poppins(
                  fontSize: isMobile ? 12 : 14,
                  color: AppColors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialButton(String title, String iconPath, {double? height}) {
    final bool isMobile = Responsive.isMobile(context);

    return Column(
      children: [
        Image.asset(
          iconPath,
          height: height ?? 25,
        ),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: isMobile ? 12 : 14,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
