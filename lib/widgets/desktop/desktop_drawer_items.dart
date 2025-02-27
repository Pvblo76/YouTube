import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:youtube/theme/theme_manager.dart';

class DrawerItems extends StatefulWidget {
  final String title;
  final IconData? icon;
  final Widget? image;
  final bool isSelected;
  final VoidCallback onTap;

  const DrawerItems({
    Key? key,
    required this.title,
    this.icon,
    this.image,
    this.isSelected = false,
    required this.onTap,
  }) : super(key: key);

  @override
  State<DrawerItems> createState() => _DrawerItemsState();
}

class _DrawerItemsState extends State<DrawerItems> {
  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<YouTubeTheme>(context);
    final isDark = theme.isDarkMode;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: InkWell(
        hoverColor: theme.containerBackgroundColor,
        borderRadius: BorderRadius.circular(10),
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: getBackgroundColor(widget.isSelected, isDark),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                if (widget.icon != null)
                  Icon(
                    widget.icon,
                    size: 24,
                    color: getIconColor(widget.isSelected, isDark),
                  )
                else if (widget.image != null)
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: widget.image!,
                  ),
                const SizedBox(width: 24),
                Expanded(
                  child: Text(
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    widget.title,
                    style: getTextStyle(widget.isSelected, isDark),
                  ),
                ),
              ],
            ),
          ),
        ),
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
