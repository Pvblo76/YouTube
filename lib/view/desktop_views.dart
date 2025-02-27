import 'package:flutter/material.dart';

class DesktopViews extends StatefulWidget {
  final TrackingScrollController scrollController;
  const DesktopViews({super.key, required this.scrollController});

  @override
  State<DesktopViews> createState() => _DesktopViewsState();
}

class _DesktopViewsState extends State<DesktopViews> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 800,
      child: CustomScrollView(
        controller: widget.scrollController,
      ),
    );
  }
}
