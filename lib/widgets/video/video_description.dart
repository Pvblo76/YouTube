import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:youtube/responsive/responsiveness.dart';
import 'package:youtube/theme/theme_manager.dart';

class ExpandableDescription extends StatefulWidget {
  final String views;
  final String publishTime;
  final String descriptions;

  const ExpandableDescription({
    Key? key,
    required this.views,
    required this.publishTime,
    required this.descriptions,
  }) : super(key: key);

  @override
  State<ExpandableDescription> createState() => _ExpandableDescriptionState();
}

class _ExpandableDescriptionState extends State<ExpandableDescription> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<YouTubeTheme>(context);
    final isDark = theme.isDarkMode;
    final bool isMobile = Responsive.isMobile(context);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: theme.containerBackgroundColor,
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Views and publish time
            isMobile
                ? SizedBox.shrink()
                : Text(
                    '${widget.views} views • ${widget.publishTime}',
                    style: GoogleFonts.roboto(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: theme.channelInfoColor,
                    ),
                  ),
            const SizedBox(height: 8),

            // Description text
            AnimatedCrossFade(
              firstChild: _buildCollapsedDescription(),
              secondChild: _buildExpandedDescription(),
              crossFadeState: _isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 200),
            ),

            // Show more/less button
            InkWell(
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  _isExpanded ? 'Show less' : 'Show more',
                  style: GoogleFonts.roboto(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCollapsedDescription() {
    final theme = Provider.of<YouTubeTheme>(context);
    final isDark = theme.isDarkMode;
    return Text(
      widget.descriptions,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: GoogleFonts.roboto(
        fontSize: 14,
        color: isDark ? Colors.white : Colors.black87,
        height: 1.4,
      ),
    );
  }

  Widget _buildExpandedDescription() {
    final theme = Provider.of<YouTubeTheme>(context);
    final isDark = theme.isDarkMode;
    return Text(
      widget.descriptions,
      style: GoogleFonts.roboto(
        fontSize: 14,
        color: isDark ? Colors.white : Colors.black87,
        height: 1.4,
      ),
    );
  }
}
