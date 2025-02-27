import 'package:flutter/material.dart';
import 'package:youtube/view/video_details_sections.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: VideoDetailsBottomSheets(
      title: 'Making of The Gentlemen | Guy Ritchie | Netflix',
      description: 'Your video description...',
      viewCount: 525000,
      uploadDate: DateTime.now().subtract(const Duration(days: 300)),
      channelName: 'Still Watching Netflix',
      channelAvatar: 'channel_avatar_url',
      subscriberCount: 8410000,
      comments: [
        Comment(
          username: 'User1',
          userAvatar: 'avatar_url',
          text: 'Brilliant show, hope there\'s season 2',
          timestamp: DateTime.now(),
          likes: 100,
          replies: [],
        ),
        // More comments...
      ],
    ));
  }
}
