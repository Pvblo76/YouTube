import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:youtube/theme/theme_manager.dart';

class TabletDrawerItems extends StatefulWidget {
  final String title;
  final IconData? icon;
  final Widget? image;
  final bool isSelected;
  final VoidCallback onTap;

  const TabletDrawerItems({
    super.key,
    required this.title,
    this.icon,
    this.image,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  State<TabletDrawerItems> createState() => _TabletDrawerItemsState();
}

class _TabletDrawerItemsState extends State<TabletDrawerItems> {
  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<YouTubeTheme>(context);
    final isDark = theme.isDarkMode;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: widget.onTap,
        hoverColor: theme.containerBackgroundColor,
        child: Container(
            height: 80,
            width: 60,
            decoration: BoxDecoration(
              color: getBackgroundColor(widget.isSelected, isDark),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (widget.icon != null)
                    Icon(
                      widget.icon,
                      size: 24,
                      color: getIconColor(widget.isSelected, isDark),
                    )
                  else if (widget.image != null)
                    widget.image!,
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      widget.title,
                      style: getTextStyle(widget.isSelected, isDark))
                ],
              ),
            )),
      ),
    );
  }

  Color getBackgroundColor(bool isSelected, bool isDark) {
    if (isDark && isSelected) {
      return Colors.grey.shade900;
    } else if (!isDark && isSelected) {
      return Colors.grey[300]!;
    }
    return Colors.transparent;
  }

  Color getIconColor(bool isSelected, bool isDark) {
    if (isDark && isSelected) {
      return Colors.white;
    } else if (!isDark && isSelected) {
      return Colors.black;
    } else if (isDark) {
      return Colors.white.withOpacity(0.8);
    }
    return Colors.grey[700]!;
  }

  Color getTextColor(bool isSelected, bool isDark) {
    if (!isDark && isSelected) {
      return Colors.black;
    } else if (isDark && isSelected) {
      return Colors.white;
    } else if (isDark) {
      return Colors.white;
    }
    return Colors.grey[900]!;
  }

  TextStyle getTextStyle(bool isSelected, bool isDark) {
    return GoogleFonts.roboto(
      fontSize: 14,
      fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
      color: getTextColor(isSelected, isDark),
    );
  }
}
