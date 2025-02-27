import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:youtube/provider/api_providers.dart';
import 'package:youtube/theme/theme_manager.dart';

class QuotaExceededErrorPage extends StatelessWidget {
  const QuotaExceededErrorPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<YouTubeTheme>(context);
    final apiProvider = Provider.of<ApiProviders>(context, listen: false);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Container(
          color: theme.scaffoldColor,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Lottie Animation
              // Lottie.asset(
              //   'assets/images/avatar.jpg',
              //   width: 250,
              //   height: 250,
              //   repeat: true,
              // ),

              const SizedBox(height: 30),

              // Error Title
              const Text(
                'API Quota Limit Reached',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),

              const SizedBox(height: 15),

              // Error Message
              const Text(
                'Oops! We\'ve reached the YouTube API quota limit. Please try again later.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 30),

              // Retry Button
              ElevatedButton(
                onPressed: () {
                  apiProvider.fetchVideos(apiProvider.lastQuery,
                      forceRefetch: true);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Retry',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
