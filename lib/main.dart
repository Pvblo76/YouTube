import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:youtube/provider/api_providers.dart';
import 'package:youtube/provider/navigator_provider.dart';
import 'package:youtube/provider/search_provider.dart';

import 'package:youtube/theme/theme_manager.dart';
import 'package:youtube/theme/theme_animations.dart';

import 'package:youtube/widgets/routes/app_routes.dart';
import 'package:youtube/widgets/routes/routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // MediaKit.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(MyApp(prefs: prefs));
}

class MyApp extends StatefulWidget {
  final SharedPreferences prefs;
  const MyApp({
    super.key,
    required this.prefs,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ApiProviders()),
        ChangeNotifierProvider(create: (_) => NavigationState()),
        ChangeNotifierProvider(create: (_) => YouTubeTheme()),
        ChangeNotifierProvider(create: (_) => SearchProvider(widget.prefs)),
      ],
      child: Consumer<YouTubeTheme>(
        builder: (context, themeProvider, child) {
          if (!themeProvider.isInitialized) {
            return const MaterialApp(
              home: Scaffold(
                body: Center(child: CircularProgressIndicator()),
              ),
            );
          }
          return AnimatedThemeWrapper(
              child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'YouTube',
            theme: themeProvider.theme,
            initialRoute: RouteNames.home,
            onGenerateRoute: AppRouter.generateRoute,
          ));
        },
      ),
    );
  }
}

// class MyCustomScrollBehavior extends MaterialScrollBehavior {
//   // Override behavior methods and getters like dragDevices
//   @override
//   Set<PointerDeviceKind> get dragDevices => {
//         // PointerDeviceKind.touch,
//         // PointerDeviceKind.mouse,
//       };
// }
