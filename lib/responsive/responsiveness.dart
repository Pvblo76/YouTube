import 'package:flutter/material.dart';

class Responsive extends StatelessWidget {
  final Widget mobileView;
  final Widget? tabletView;
  final Widget desktopView;

  const Responsive({
    super.key,
    required this.mobileView,
    this.tabletView,
    required this.desktopView,
  });

  // Breakpoints based on common device sizes
  static const int mobileBreakpoint = 650; // Changed from 600
  static const int tabletBreakpoint = 1024; // Changed from 1000
  static const int desktopBreakpoint = 1280; // Added for larger screens

  // Static methods for checking device type
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobileBreakpoint;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= mobileBreakpoint &&
      MediaQuery.of(context).size.width < tabletBreakpoint;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= tabletBreakpoint;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Mobile devices (phones and small tablets)
        if (constraints.maxWidth < mobileBreakpoint) {
          return mobileView;
        }
        // Tablet devices (large tablets and small laptops)
        else if (constraints.maxWidth >= mobileBreakpoint &&
            constraints.maxWidth < tabletBreakpoint) {
          return tabletView ?? mobileView;
        }
        // Desktop devices
        else {
          return desktopView;
        }
      },
    );
  }
}
