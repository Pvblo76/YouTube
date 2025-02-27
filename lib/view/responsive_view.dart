// import 'package:flutter/material.dart';
// import 'package:youtube/responsive/responsiveness.dart';
// import 'package:youtube/view/desktop_views.dart';
// import 'package:youtube/view/mobile_home_screen.dart';

// class ResponsiveView extends StatefulWidget {
//   const ResponsiveView({super.key});

//   @override
//   State<ResponsiveView> createState() => _ResponsiveViewState();
// }

// class _ResponsiveViewState extends State<ResponsiveView> {
//   final TrackingScrollController _trackingScrollController =
//       TrackingScrollController();

//   @override
//   void dispose() {
//     _trackingScrollController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () => FocusScope.of(context).unfocus,
//       child: Scaffold(
//         body: Responsive(
//           mobileView:
//               MobileHomeScreen(scrollController: _trackingScrollController),
//           desktopView:
//               DesktopViews(scrollController: _trackingScrollController),
//         ),
//       ),
//     );
//   }
// }
