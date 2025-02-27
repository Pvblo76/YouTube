import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:youtube/model/categories.dart';
import 'package:youtube/responsive/responsiveness.dart';
import 'package:youtube/theme/theme_manager.dart';

class SecondaryAppbar extends StatefulWidget {
  final Function(int) onTabSelected;
  final int selectedIndex;
  final bool showCompassIcon;

  const SecondaryAppbar({
    super.key,
    required this.onTabSelected,
    required this.selectedIndex,
    required this.showCompassIcon,
  });

  @override
  State<SecondaryAppbar> createState() => _SecondaryAppbarState();
}

class _SecondaryAppbarState extends State<SecondaryAppbar> {
  late ScrollController _tabScrollController;
  bool _canScrollLeft = false;
  bool _canScrollRight = true;

  @override
  void initState() {
    super.initState();
    _tabScrollController = ScrollController();
    _tabScrollController.addListener(_updateScrollButtons);
  }

  void _updateScrollButtons() {
    setState(() {
      _canScrollLeft = _tabScrollController.offset > 0;
      _canScrollRight = _tabScrollController.offset <
          _tabScrollController.position.maxScrollExtent;
    });
  }

  void _scrollCategories(bool scrollRight) {
    if (_tabScrollController.hasClients) {
      final scrollOffset = scrollRight
          ? _tabScrollController.offset + 200
          : _tabScrollController.offset - 200;

      _tabScrollController.animateTo(
        scrollOffset.clamp(0.0, _tabScrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _tabScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final theme = Provider.of<YouTubeTheme>(context);
    final isDark = theme.isDarkMode;
    final List<String> categoryNames = Categories.categoryMap.keys.toList();

    return Stack(
      children: [
        Row(
          children: [
            // Left scroll button
            if (!isMobile)
              AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: _canScrollLeft ? 1.0 : 0.0,
                child: IconButton(
                  icon: Icon(Icons.chevron_left,
                      color: isDark ? Colors.white : Colors.black),
                  onPressed:
                      _canScrollLeft ? () => _scrollCategories(false) : null,
                ),
              ),

            // Expandable category list
            Expanded(
              child: NotificationListener<ScrollNotification>(
                onNotification: (ScrollNotification scrollInfo) {
                  _updateScrollButtons();
                  return true;
                },
                child: SizedBox(
                  height: 40,
                  child: ListView.builder(
                    controller: _tabScrollController,
                    scrollDirection: Axis.horizontal,
                    physics: const ClampingScrollPhysics(),
                    itemCount:
                        (widget.showCompassIcon ? 1 : 0) + categoryNames.length,
                    itemBuilder: (context, index) {
                      if (widget.showCompassIcon && index == 0) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: GestureDetector(
                            onTap: () {
                              Scaffold.of(context).openDrawer();
                            },
                            child: Chip(
                              side: BorderSide.none,
                              backgroundColor: isDark
                                  ? Colors.grey.shade900
                                  : Colors.grey.shade200,
                              label: Icon(
                                CupertinoIcons.compass,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                        );
                      }

                      final categoryIndex =
                          widget.showCompassIcon ? index - 1 : index;
                      final isSelected = widget.showCompassIcon
                          ? widget.selectedIndex == categoryIndex
                          : widget.selectedIndex == categoryIndex;

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: InkWell(
                          onTap: () {
                            widget.onTabSelected(categoryIndex);
                          },
                          child: Chip(
                            side: BorderSide.none,
                            backgroundColor:
                                _getChipBackgroundColor(isSelected, isDark),
                            label: Text(
                              categoryNames[categoryIndex],
                              style: GoogleFonts.roboto(
                                  fontWeight: FontWeight.w500,
                                  color: _getChipTextColor(isSelected, isDark)),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            // Right scroll button
            if (!isMobile)
              IconButton(
                icon: Icon(Icons.chevron_right,
                    color: isDark ? Colors.white : Colors.black),
                onPressed:
                    _canScrollRight ? () => _scrollCategories(true) : null,
              ),
          ],
        ),
      ],
    );
  }

  Color _getChipBackgroundColor(bool isSelected, bool isDark) {
    if (isDark && isSelected) {
      return Colors.grey.shade200;
    } else if (!isDark && isSelected) {
      return Colors.black;
    } else if (isDark) {
      return Colors.grey.shade900;
    } else {
      return Colors.grey.shade200;
    }
  }

  Color _getChipTextColor(bool isSelected, bool isDark) {
    if (isDark && isSelected) {
      return Colors.black;
    } else if (!isDark && isSelected) {
      return Colors.white;
    } else if (isDark) {
      return Colors.grey.shade300;
    } else {
      return Colors.black;
    }
  }
}
