import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youtube/model/categories.dart';

class ChannelTabController extends StatefulWidget {
  final Function(int) onTabSelected;
  final int selectedIndex;

  const ChannelTabController({
    super.key,
    required this.onTabSelected,
    required this.selectedIndex,
  });

  @override
  State<ChannelTabController> createState() => _ChannelTabControllerState();
}

class _ChannelTabControllerState extends State<ChannelTabController> {
  int? hoveredIndex;

  @override
  Widget build(BuildContext context) {
    final List<String> tabNames = ChannelTabs.tabs.keys.toList();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      height: 48, // Increased height to accommodate the indicator
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFE5E5E5),
            width: 1,
          ),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(
            tabNames.length,
            (index) {
              final isSelected = widget.selectedIndex == index;
              final isHovered = hoveredIndex == index;

              return MouseRegion(
                onEnter: (_) => setState(() => hoveredIndex = index),
                onExit: (_) => setState(() => hoveredIndex = null),
                child: InkWell(
                  onTap: () => widget.onTabSelected(index),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: isSelected ? Colors.black : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          tabNames[index],
                          style: GoogleFonts.roboto(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: (isSelected || isHovered)
                                ? (isDark ? Colors.white : Colors.black)
                                : (isDark ? Colors.white : Colors.black87)
                                    .withOpacity(0.7),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
