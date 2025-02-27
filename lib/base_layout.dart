import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:youtube/provider/navigator_provider.dart';
import 'package:youtube/widgets/nav_bar.dart';
import 'package:youtube/widgets/routes/routes.dart';

class BaseLayout extends StatefulWidget {
  final Widget child;

  const BaseLayout({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  State<BaseLayout> createState() => _BaseLayoutState();
}

class _BaseLayoutState extends State<BaseLayout> {
  final List<String> _routes = [
    RouteNames.home,
    RouteNames.shorts,
    RouteNames.upload,
    RouteNames.subscription,
    RouteNames.profile,
  ];

  void _onItemTapped(BuildContext context, int index) {
    final navigationState =
        Provider.of<NavigationState>(context, listen: false);
    if (navigationState.currentIndex != index) {
      navigationState.updateIndex(index);
      Navigator.pushReplacementNamed(context, _routes[index]);
    }
  }

  int _getInitialIndex(String? currentRoute) {
    return _routes.indexOf(currentRoute ?? RouteNames.home);
  }

  bool _isMobileView(BuildContext context) {
    return MediaQuery.of(context).size.width < 600;
  }

  @override
  Widget build(BuildContext context) {
    final String? currentRoute = ModalRoute.of(context)?.settings.name;
    final bool hideOnSpecificRoutes = ![
      RouteNames.videoPlay,
      RouteNames.channel,
      RouteNames.about,
    ].contains(currentRoute);

    // Initialize the navigation state with the current route
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (currentRoute != null && _routes.contains(currentRoute)) {
        final navigationState =
            Provider.of<NavigationState>(context, listen: false);
        navigationState.updateIndex(_getInitialIndex(currentRoute));
      }
    });

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: Builder(
        builder: (context) {
          final bool showBottomNav =
              _isMobileView(context) && hideOnSpecificRoutes;

          if (!showBottomNav) {
            return const SizedBox.shrink();
          }

          return Consumer<NavigationState>(
            builder: (context, navigationState, child) {
              return BottomNavBar(
                currentIndex: navigationState.currentIndex,
                onTap: (index) => _onItemTapped(context, index),
              );
            },
          );
        },
      ),
    );
  }
}
