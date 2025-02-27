import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:youtube/provider/search_provider.dart';

import 'package:youtube/responsive/responsiveness.dart';
import 'package:youtube/theme/theme_manager.dart';
import 'package:youtube/widgets/search_view/mobile_searching_view.dart';
import 'package:youtube/widgets/search_view/search.dart';

class YoutubeAppBar extends StatefulWidget {
  final String? initialQuery; // Add this parameter
  const YoutubeAppBar({Key? key, this.initialQuery}) : super(key: key);

  @override
  State<YoutubeAppBar> createState() => _YoutubeAppBarState();
}

class _YoutubeAppBarState extends State<YoutubeAppBar> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _textScrollController = ScrollController();
  final FocusNode _searchFocusNode = FocusNode();
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isOverlayVisible = false;

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(_onFocusChange);
    _searchController.addListener(_onSearchChanged);

    if (widget.initialQuery?.isNotEmpty == true) {
      _searchController.text = widget.initialQuery!;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToEnd();
      });
    }
  }

  void _scrollToEnd() {
    if (_textScrollController.hasClients) {
      _textScrollController
          .jumpTo(_textScrollController.position.maxScrollExtent);
    }
  }

  void _onFocusChange() {
    if (_searchFocusNode.hasFocus) {
      _showOverlay();
    } else {
      Future.delayed(const Duration(milliseconds: 200), () {
        if (!_searchFocusNode.hasFocus) {
          _removeOverlay();
        }
      });
    }
  }

  void _onSearchChanged() {
    if (!mounted) return;

    final searchProvider = Provider.of<SearchProvider>(context, listen: false);
    if (_searchController.text.isEmpty) {
      _removeOverlay();
    } else {
      searchProvider.getSuggestions(_searchController.text);
      if (_searchFocusNode.hasFocus) {
        _showOverlay();
      }
    }
  }

  void _onSearchSubmitted(String query) {
    if (query.isEmpty) return;

    final searchProvider = Provider.of<SearchProvider>(context, listen: false);
    searchProvider.search(query);

    _removeOverlay();
    _searchFocusNode.unfocus();

    final bool isCurrentlySearchView =
        ModalRoute.of(context)?.settings.name?.startsWith('SearchView_') ??
            false;

    if (!isCurrentlySearchView) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SearchView(Query: query),
          settings: RouteSettings(name: 'SearchView_$query'),
        ),
      ).then((_) {
        if (_searchController.text != query) {
          _searchController.text = query;
        }
      });
    } else {
      if (_searchController.text != query) {
        _searchController.text = query;
      }
      searchProvider.search(query);
    }
  }

  void _removeOverlay() {
    if (_overlayEntry != null && _isOverlayVisible) {
      _isOverlayVisible = false;
      _overlayEntry?.remove();
      _overlayEntry = null;
    }
  }

  void _showOverlay() {
    if (_overlayEntry != null || !mounted) return;

    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: 500,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, size.height + 5),
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(8),
            child: _buildSuggestionsList(),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
    _isOverlayVisible = true;
  }

  Widget _buildSuggestionsList() {
    final theme = Provider.of<YouTubeTheme>(context, listen: false);
    final isDark = theme.isDarkMode;

    return Consumer<SearchProvider>(
      builder: (context, searchProvider, _) {
        return Container(
            constraints: const BoxConstraints(
              maxHeight: 400,
            ),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey.shade900 : Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: searchProvider.isLoadingSuggestions
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isDark ? Colors.grey.shade700 : Colors.black54,
                          ),
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      itemCount: searchProvider.searchSuggestions.length,
                      itemBuilder: (context, index) {
                        var suggestion =
                            searchProvider.searchSuggestions[index];
                        return InkWell(
                          onTap: () {
                            print(
                                "Suggestion tapped: ${suggestion.text}"); // Debug print
                            _onSearchSubmitted(suggestion.text);
                          },
                          // hoverColor: isDark
                          //     ? Colors.grey.shade800
                          //     : Colors.grey.shade300,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  suggestion.type == SuggestionType.history
                                      ? Icons.history
                                      : suggestion.type ==
                                              SuggestionType.trending
                                          ? Icons.trending_up
                                          : Icons.search,
                                  color: isDark
                                      ? Colors.grey.shade400
                                      : Colors.grey.shade600,
                                  size: 20,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    suggestion.text,
                                    style: GoogleFonts.roboto(
                                      fontSize: 14,
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.north_west),
                                  onPressed: () {
                                    // Update the search field text
                                    _searchController.text = suggestion.text;

                                    // Set cursor position to end of text
                                    _searchController.selection =
                                        TextSelection.fromPosition(
                                      TextPosition(
                                          offset: suggestion.text.length),
                                    );
                                  },
                                  color: isDark
                                      ? Colors.grey.shade400
                                      : Colors.grey.shade600,
                                  iconSize: 18,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ));
      },
    );
  }

  Widget _buildSearchField(BuildContext context, bool isDark) {
    final theme = Provider.of<YouTubeTheme>(context, listen: false);
    final isDark = theme.isDarkMode;

    return CompositedTransformTarget(
      link: _layerLink,
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 640,
          minWidth: 200,
        ),
        height: 40,
        decoration: BoxDecoration(
          border: Border.all(
            color: isDark ? Colors.grey.shade900 : Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 16),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  controller: _textScrollController,
                  child: IntrinsicWidth(
                    child: SizedBox(
                      height: 40,
                      child: Center(
                        child: TextField(
                          cursorColor: isDark ? Colors.white : Colors.black,
                          controller: _searchController,
                          focusNode: _searchFocusNode,
                          textAlignVertical: TextAlignVertical.center,
                          style: GoogleFonts.roboto(
                            fontSize: 16,
                            height: 1.0,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Search',
                            hintStyle: GoogleFonts.roboto(
                              color: Colors.grey.shade600,
                              fontSize: 16,
                              height: 1.0,
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          onSubmitted: _onSearchSubmitted,
                          onTap: () {
                            // Scroll to end when field is tapped
                            if (_textScrollController.hasClients) {
                              _textScrollController.jumpTo(_textScrollController
                                  .position.maxScrollExtent);
                            }
                          },
                          onChanged: (value) {
                            // Scroll to end when text changes
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (_textScrollController.hasClients) {
                                _textScrollController.jumpTo(
                                    _textScrollController
                                        .position.maxScrollExtent);
                              }
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Container(
              height: 40,
              width: 60,
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                    color: isDark ? Colors.grey.shade900 : Colors.grey.shade200,
                  ),
                ),
                color: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: InkWell(
                onTap: () {
                  if (_searchController.text.isNotEmpty) {
                    _onSearchSubmitted(_searchController.text);
                  }
                },
                child: Icon(
                  CupertinoIcons.search,
                  color: isDark ? Colors.white : Colors.black,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _removeOverlay();
    _searchFocusNode.removeListener(_onFocusChange);
    _searchController.dispose();
    _searchFocusNode.dispose();
    _textScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = Responsive.isMobile(context);
    // final bool isDesktop = Responsive.isDesktop(context);
    final bool isTablet = Responsive.isTablet(context);
    final double screenwith = MediaQuery.of(context).size.width;
    print(" App bar screen with : ${screenwith}");
    return ResponsiveBuilder(
      builder: (context, sizingInformation) {
        if (isMobile) {
          return _buildMobileAppBar(context);
        } else if (isTablet) {
          return _buildTabletAppBar(context);
        } else {
          return _buildWebAppBar(context);
        }
      },
    );
  }

  Widget _buildMobileAppBar(BuildContext context) {
    final theme = Provider.of<YouTubeTheme>(context);
    final isDark = theme.isDarkMode;
    return AppBar(
      automaticallyImplyLeading:
          false, // This removes the default drawer/back icon

      backgroundColor: theme.scaffoldColor,
      leadingWidth: 100.0,
      leading: Padding(
        padding: const EdgeInsets.only(left: 12.0),
        child: Image.asset(isDark
            ? 'assets/images/yt_logo_dark.png'
            : 'assets/images/logo.png'),
      ),
      actions: [
        Icon(
          Icons.cast, // This is the icon you are looking for

          size: 22,
          color: isDark ? Colors.white : Colors.black,
        ),
        const SizedBox(
          width: 20,
        ),
        Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(
              CupertinoIcons.bell,
              size: 22,
              color: isDark ? Colors.white : Colors.black,
            ),
            Positioned(
              top: -5, // Adjust the top position
              right: -5, // Adjust the right position
              child: CircleAvatar(
                radius: 7, // Slightly larger radius for better visibility
                backgroundColor: Colors.red,
                child: Center(
                  child: Text(
                    '5',
                    style: GoogleFonts.roboto(
                      color: Colors.white,
                      fontSize: 10, // Adjust font size to fit inside the circle
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 20),
        IconButton(
          icon: Icon(
            CupertinoIcons.search,
            size: 24,
            color: isDark ? Colors.white : Colors.black,
          ),
          onPressed: () {
            showSearch(
              context: context,
              delegate: YoutubeSearchDelegate(context: context),
            );
          },
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  Widget _buildTabletAppBar(BuildContext context) {
    final theme = Provider.of<YouTubeTheme>(context);
    final isDark = theme.isDarkMode;
    return AppBar(
      automaticallyImplyLeading:
          false, // This removes the default drawer/back icon

      backgroundColor: theme.scaffoldColor,
      titleSpacing: 0,
      title: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: IconButton(
                icon: Icon(Icons.menu,
                    color: isDark ? Colors.white : Colors.black),
                onPressed: () {},
              ),
            ),
            const SizedBox(width: 16),
            Image.asset(
              isDark
                  ? 'assets/images/yt_logo_dark.png'
                  : 'assets/images/logo.png',
              height: 20,
              fit: BoxFit.contain,
            ),
            const Expanded(flex: 1, child: SizedBox(width: 16)),
            Expanded(
              flex: 2,
              child: _buildSearchField(context, isDark),
            ),
            const SizedBox(width: 16),
            Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
              ),
              child: Center(
                child: InkWell(
                    onTap: () {},
                    child: Icon(
                      Icons.mic,
                      color: isDark ? Colors.white : Colors.black,
                    )),
              ),
            ),
            const Expanded(flex: 1, child: SizedBox(width: 16)),
          ],
        ),
      ),
      actions: [
        Container(
          height: 35,
          width: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(17),
            color: isDark ? Colors.grey.shade900 : Colors.grey[200],
          ),
          child: Center(
            child: InkWell(
              onTap: () {},
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add,
                    color: isDark ? Colors.white : Colors.black,
                    size: 22,
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Text(
                    "Create",
                    style: GoogleFonts.roboto(
                      fontSize: 15,
                      color: isDark ? Colors.white : Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(
          width: 20,
        ),
        Stack(
          clipBehavior: Clip.none, // Ensure the circle doesn't get clipped
          children: [
            Icon(
              CupertinoIcons.bell,
              size: 22,
              color: isDark ? Colors.white : Colors.black,
            ),
            Positioned(
              top: -5, // Adjust the top position
              right: -5, // Adjust the right position
              child: CircleAvatar(
                radius: 7, // Slightly larger radius for better visibility
                backgroundColor: Colors.red,
                child: Center(
                  child: Text(
                    '5',
                    style: GoogleFonts.roboto(
                      color: Colors.white,
                      fontSize: 10, // Adjust font size to fit inside the circle
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(
          width: 20,
        ),
        CircleAvatar(
          radius: 18,
          backgroundColor: Colors.grey[300],
          backgroundImage: const AssetImage(
            "assets/images/avatar.jpg",
          ),
        ),
        const SizedBox(
          width: 15,
        )
      ],
    );
  }

  Widget _buildWebAppBar(BuildContext context) {
    final theme = Provider.of<YouTubeTheme>(context);
    final isDark = theme.isDarkMode;
    return AppBar(
      automaticallyImplyLeading:
          false, // This removes the default drawer/back icon

      backgroundColor: theme.scaffoldColor,
      titleSpacing: 0,
      title: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: IconButton(
                icon: Icon(Icons.menu,
                    color: isDark ? Colors.white : Colors.black),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              ),
            ),
            const SizedBox(width: 16),
            Image.asset(
              isDark
                  ? 'assets/images/yt_logo_dark.png'
                  : 'assets/images/logo.png',
              height: 20,
              fit: BoxFit.contain,
            ),
            const Expanded(flex: 1, child: SizedBox(width: 16)),
            Expanded(
              flex: 2,
              child: _buildSearchField(context, isDark),
            ),
            const SizedBox(width: 16),
            Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: theme.containerBackgroundColor,
              ),
              child: Center(
                child: InkWell(
                    onTap: () {},
                    child: Icon(
                      Icons.mic,
                      color: isDark ? Colors.white : Colors.black,
                    )),
              ),
            ),
            const Expanded(flex: 1, child: SizedBox(width: 16)),
          ],
        ),
      ),
      actions: [
        Container(
          height: 35,
          width: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(17),
            color: theme.containerBackgroundColor,
          ),
          child: Center(
            child: InkWell(
              onTap: () {},
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add,
                    color: isDark ? Colors.white : Colors.black,
                    size: 22,
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Text(
                    "Create",
                    style: GoogleFonts.roboto(
                      fontSize: 15,
                      color: theme.titleColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(
          width: 20,
        ),
        Stack(
          clipBehavior: Clip.none, // Ensure the circle doesn't get clipped
          children: [
            Icon(
              CupertinoIcons.bell,
              size: 22,
              color: isDark ? Colors.white : Colors.black,
            ),
            Positioned(
              top: -5, // Adjust the top position
              right: -5, // Adjust the right position
              child: CircleAvatar(
                radius: 7, // Slightly larger radius for better visibility
                backgroundColor: Colors.red,
                child: Center(
                  child: Text(
                    '5',
                    style: GoogleFonts.roboto(
                      color: Colors.white,
                      fontSize: 10, // Adjust font size to fit inside the circle
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(
          width: 20,
        ),
        CircleAvatar(
          radius: 18,
          backgroundColor: Colors.grey[300],
          backgroundImage: const AssetImage(
            "assets/images/avatar.jpg",
          ),
        ),
        const SizedBox(
          width: 15,
        )
      ],
    );
  }
}
