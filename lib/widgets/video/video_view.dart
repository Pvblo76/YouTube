import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:youtube/responsive/responsiveness.dart';
import 'package:youtube/theme/theme_manager.dart';
import 'package:youtube/widgets/CircleAvatar/Custome_circle_avatar.dart';
import 'package:youtube/widgets/routes/app_routes.dart';
import 'package:youtube/widgets/routes/routes.dart';
import 'package:youtube/widgets/subscribe/subscribe_button.dart';
import 'package:youtube/widgets/video/video_description.dart';

class VideoView extends StatefulWidget {
  final String title;
  final String channel;
  final String likeCount;
  final Widget preview;
  final String views;
  final String publishTime;
  final String subscribers;
  final String avator;
  final String descriptions;
  final String channelId;
  final Widget showdescription;

  const VideoView({
    super.key,
    required this.title,
    required this.channel,
    required this.views,
    required this.publishTime,
    required this.subscribers,
    required this.avator,
    required this.descriptions,
    required this.channelId,
    required this.likeCount,
    required this.preview,
    required this.showdescription,
  });

  @override
  State<VideoView> createState() => _VideoViewState();
}

class _VideoViewState extends State<VideoView> {
  bool _isVerified(String subscribers) {
    try {
      // Remove non-numeric characters (e.g., "K", ",") and parse to number
      String cleanValue = subscribers.replaceAll(RegExp(r'[^\d.]'), '');
      double numericValue = double.parse(cleanValue);

      // Handle "K" (thousands) multiplier
      if (subscribers.contains('K')) numericValue *= 1000;
      if (subscribers.contains('M')) numericValue *= 1000000;

      return numericValue > 100000;
    } catch (e) {
      // Handle parsing errors
      return false;
    }
  }

  Widget _channelNameWithBadge() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: InkWell(
            onTap: () {
              Navigator.pushNamed(context, RouteNames.channel,
                  arguments: ChannelArgs(channelId: widget.channelId));
            },
            child: Text(
              widget.channel,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
          ),
        ),
        if (_isVerified(widget.subscribers))
          Padding(
            padding: const EdgeInsets.only(left: 4.0),
            child: Icon(
              Icons.check_circle,
              size: 14,
              color: isDark ? Colors.grey[300] : Colors.grey[700],
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = Responsive.isMobile(context);
    final bool isDesktop = Responsive.isDesktop(context);
    final bool isTablet = Responsive.isTablet(context);
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isWideScreen =
        screenWidth > 800 && screenWidth <= 1023 || screenWidth >= 1200;
    //final bool whentablet = screenWidth > 800 && <=900;
    final theme = Provider.of<YouTubeTheme>(context);
    final isDark = theme.isDarkMode;
    return Container(
      //   height: size.height * 0.45,
      width: double.infinity,
      //   color: Colors.amber,
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: isTablet
                ? 20
                : isDesktop
                    ? 30
                    : 0),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Add this to prevent expansion
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                widget.title,
                style: GoogleFonts.roboto(
                  color: theme.titleColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            isMobile
                ? Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: Row(
                      children: [
                        Text(
                          maxLines: 2,
                          '${widget.views} • ${widget.publishTime}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(
                          width: 4,
                        ),
                        widget.showdescription,
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  InkWell(
                      onTap: () {
                        Navigator.pushNamed(context, RouteNames.channel,
                            arguments:
                                ChannelArgs(channelId: widget.channelId));
                      },
                      child: CustomCircleAvatar(avatarUrl: widget.avator)),
                  const SizedBox(width: 8),
                  if (!isWideScreen)
                    Expanded(
                      child: Container(
                        child: isMobile
                            ? Row(
                                children: [
                                  Expanded(
                                    child: InkWell(
                                      onTap: () {
                                        Navigator.pushNamed(
                                            context, RouteNames.channel,
                                            arguments: ChannelArgs(
                                                channelId: widget.channelId));
                                      },
                                      child: Text(
                                        widget.channel,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: isDark
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    widget.subscribers,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _channelNameWithBadge(),
                                  const SizedBox(height: 4),
                                  Text(
                                    "${widget.subscribers} subscribers",
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),

                  // Replace the channel name Text widget in the wide screen layout
                  if (isWideScreen)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _channelNameWithBadge(),
                            const SizedBox(height: 4),
                            Text(
                              "${widget.subscribers} subscribers",
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 10),
                        const SubscribeButton(),
                      ],
                    ),
                  if (isMobile) ...[
                    const Spacer(),
                    const SubscribeButton(),
                  ],
                  if (!isMobile && !isWideScreen) ...[
                    const Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: SubscribeButton(),
                    ),
                  ],
                  if (!isMobile) ...[
                    const Spacer(),
                    Row(
                      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                            height: 35,
                            //  width: 110,
                            decoration: BoxDecoration(
                              color: theme.containerBackgroundColor,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 15.0),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.thumb_up_outlined,
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black54,
                                      size: 16,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      child: Text(
                                        widget.likeCount,
                                        style: GoogleFonts.roboto(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                    const VerticalDivider(),
                                    const SizedBox(width: 8),
                                    Icon(
                                      Icons.thumb_down_outlined,
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black54,
                                      size: 16,
                                    ),
                                  ],
                                ))),
                        screenWidth > 1023 && screenWidth <= 1080
                            ? const SizedBox.shrink()
                            : _iconButton(Icons.share, 'Share',
                                iconPath: isDark
                                    ? "assets/icons/share_white.png"
                                    : "assets/icons/share.png"),
                        const SizedBox(
                          width: 8,
                        ),
                        Container(
                          height: 30,
                          width: 30,
                          decoration: BoxDecoration(
                            color: theme.containerBackgroundColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.more_horiz,
                              size: 20,
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        )
                      ],
                    ),
                  ],
                ],
              ),
            ),
            isMobile
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            height: 35,
                            decoration: BoxDecoration(
                                color: theme.containerBackgroundColor,
                                borderRadius: BorderRadius.circular(18)),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 15),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.thumb_up_outlined,
                                    size: 18,
                                    color:
                                        isDark ? Colors.white : Colors.black54,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    widget.likeCount,
                                    style: TextStyle(
                                        fontSize: 13, color: theme.titleColor),
                                  ),
                                  const SizedBox(width: 8),
                                  const VerticalDivider(),
                                  const SizedBox(width: 8),
                                  Icon(Icons.thumb_down_outlined,
                                      size: 18,
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black54),
                                ],
                              ),
                            ),
                          ),
                          _iconButton(Icons.share, 'Share',
                              iconPath: isDark
                                  ? "assets/icons/share_white.png"
                                  : "assets/icons/share.png"),
                          _iconButton(Icons.bookmark_outline, 'Save'),
                          _iconButton(Icons.download, 'Download'),
                          _iconButton(
                            Icons.flag_outlined,
                            'Report',
                          ),
                        ],
                      ),
                    ),
                  )
                : const SizedBox.shrink(),

            isMobile
                ? widget.preview
                : Flexible(
                    fit: FlexFit.loose,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 15),
                      child: ExpandableDescription(
                        views: widget.views,
                        publishTime: widget.publishTime,
                        descriptions: widget.descriptions,
                      ),
                    ),
                  ),
            // const Divider(height: 1, thickness: 1),
          ],
        ),
      ),
    );
  }

  Widget _iconButton(IconData icon, String label, {String? iconPath}) {
    final theme = Provider.of<YouTubeTheme>(context);
    final isDark = theme.isDarkMode;
    return Padding(
      padding: const EdgeInsets.only(left: 12.0),
      child: Container(
        height: 30,
        //  width: 100,
        decoration: BoxDecoration(
          color: theme.containerBackgroundColor,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Row(
            children: [
              iconPath == null
                  ? Icon(icon, color: isDark ? Colors.white : Colors.black54)
                  : Image.asset(iconPath, height: 15),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(fontSize: 13, color: theme.titleColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
