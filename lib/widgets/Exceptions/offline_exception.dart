import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:youtube/provider/api_providers.dart';
import 'package:youtube/theme/theme_manager.dart';

class NoInternetPage extends StatefulWidget {
  const NoInternetPage({Key? key}) : super(key: key);

  @override
  State<NoInternetPage> createState() => _NoInternetPageState();
}

class _NoInternetPageState extends State<NoInternetPage> {
  @override
  Widget build(BuildContext context) {
    final apiProvider = Provider.of<ApiProviders>(context, listen: false);

    final theme = Provider.of<YouTubeTheme>(context);
    final isDark = theme.isDarkMode;
    return Center(
      child: Container(
        width: double.infinity,
        color: theme.scaffoldColor,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              height: 60,
            ),
            // YouTube-style offline illustration
            SizedBox(
              height: 200,
              width: 200,
              child: Image.asset(
                'assets/images/offline.png',
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(height: 20),

            // Error message title
            Text(
              'Connect to the internet',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.grey[800]),
            ),

            const SizedBox(height: 10),

            // Descriptive error text
            Text(
              "You're offline. Check your connection.",
              style: TextStyle(
                  fontSize: 16,
                  color: isDark ? Colors.white : Colors.grey[600]),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 20),

            // Retry button
            ElevatedButton(
              onPressed: () {
                // Add retry logic here
                apiProvider.fetchVideos(apiProvider.lastQuery,
                    forceRefetch: true);
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8))),
              child: const Text(
                'Retry',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            )
          ],
        ),
      ),
    );
  }
}
