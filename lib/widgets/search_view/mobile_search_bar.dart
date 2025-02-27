import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:youtube/theme/theme_manager.dart';
import 'package:youtube/widgets/routes/routes.dart';
import 'package:youtube/widgets/search_view/mobile_searching_view.dart';

class MobileSearchBar extends StatefulWidget {
  String query;
  MobileSearchBar({super.key, required this.query});

  @override
  State<MobileSearchBar> createState() => _MobileSearchBarState();
}

class _MobileSearchBarState extends State<MobileSearchBar> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller.text = widget.query;
  }

  @override
  void didUpdateWidget(MobileSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.query != widget.query) {
      _controller.text = widget.query;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _clearSearch() {
    setState(() {
      widget.query = '';
      _controller.clear();
    });
  }

  void _openSearch() {
    showSearch(
      context: context,
      delegate: YoutubeSearchDelegate(context: context),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<YouTubeTheme>(context);
    final isDark = theme.isDarkMode;

    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: theme.scaffoldColor,
      leading: GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, RouteNames.home);
        },
        child: const Icon(Icons.arrow_back),
      ),
      title: GestureDetector(
        onTap: _openSearch,
        child: SizedBox(
          height: 40,
          child: TextField(
            controller: _controller,
            enabled: false,
            scrollController: _scrollController,
            style: GoogleFonts.roboto(
              fontSize: 14,
              color: isDark ? Colors.white : Colors.black,
            ),
            decoration: InputDecoration(
              isCollapsed: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              suffixIcon: widget.query.isNotEmpty
                  ? IconButton(
                      icon: Icon(
                        Icons.clear,
                        size: 20,
                        color: isDark
                            ? Colors.grey.shade400
                            : Colors.grey.shade600,
                      ),
                      onPressed: _clearSearch,
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
            ),
          ),
        ),
      ),
      actions: [
        Container(
          height: 40,
          width: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
          ),
          child: const Icon(Icons.mic),
        ),
        const SizedBox(width: 20),
        Icon(
          Icons.cast, // This is the icon you are looking for

          size: 22,
          color: isDark ? Colors.white : Colors.black,
        ),
        const SizedBox(width: 20),
        Icon(
          Icons.more_vert,
          size: 24,
          color: isDark ? Colors.white : Colors.black,
        ),
        const SizedBox(width: 10),
      ],
    );
  }
}
