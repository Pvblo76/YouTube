import 'package:flutter/material.dart';
import 'package:youtube/base_layout.dart';
import 'package:youtube/model/videos_model.dart';
import 'package:youtube/view/channel_page.dart';
import 'package:youtube/view/desktop_shorts.dart';
import 'package:youtube/view/home_page.dart';
import 'package:youtube/view/profile_page.dart';
import 'package:youtube/view/subscriptions_page.dart';
import 'package:youtube/view/upload_page.dart';
import 'package:youtube/view/video_details_page.dart';
import 'package:youtube/widgets/channel_info/channel_about_sections_for_mobile.dart';
import 'package:youtube/widgets/routes/routes.dart';
import 'package:youtube/widgets/search_view/search.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    Widget page;

    switch (settings.name) {
      case RouteNames.home:
        page = const HomePage();
        break;
      case RouteNames.shorts:
        page = const DesktopShorts();
        break;
      case RouteNames.upload:
        page = const UploadPage();
        break;
      case RouteNames.subscription:
        page = const SubscriptionsPage();
        break;
      case RouteNames.profile:
        page = const ProfilePage();
        break;
      case RouteNames.videoPlay:
        final args = settings.arguments as VideoPlayArgs;
        page = VideoPlayPage(
          id: args.channelId,
          video: args.video,
        );
        break;
      case RouteNames.channel:
        final args = settings.arguments as ChannelArgs;
        page = ChannelPage(
          id: args.channelId,
        );
        break;
      case RouteNames.about:
        final args = settings.arguments as Aboutchannle;
        page = CahnnelAbout(
            descriptions: args.description,
            name: args.name,
            subscriber: args.subscriber,
            videocount: args.videocount,
            viewcount: args.viewcount,
            country: args.country);
        break;
      case RouteNames.searchview:
        final args = settings.arguments as SearchArgs;
        page = SearchView(Query: args.query);
      default:
        page = Scaffold(
          body: Center(
            child: Text('No route defined for ${settings.name}'),
          ),
        );
    }

    // Wrap all pages with BaseLayout
    return MaterialPageRoute(
      builder: (_) => BaseLayout(child: page),
    );
  }

  AppRouter._();
}

class VideoPlayArgs {
  final String channelId;
  final Video video;

  VideoPlayArgs({
    required this.channelId,
    required this.video,
  });
}

class ChannelArgs {
  final String channelId;

  ChannelArgs({
    required this.channelId,
  });
}

class Aboutchannle {
  final String name;
  final String description;
  final String subscriber;
  final String videocount;
  final String viewcount;
  final String country;
  Aboutchannle({
    required this.name,
    required this.description,
    required this.subscriber,
    required this.videocount,
    required this.viewcount,
    required this.country,
  });
}

class SearchArgs {
  final String query;

  SearchArgs({required this.query});
}
