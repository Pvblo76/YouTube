import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ChannelBannerImage extends StatelessWidget {
  final String bannerUrl;

  const ChannelBannerImage({Key? key, required this.bannerUrl})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return ResponsiveBannerImage(
          bannerUrl: bannerUrl,
          maxWidth: _determineBannerWidth(constraints),
        );
      },
    );
  }

  double _determineBannerWidth(BoxConstraints constraints) {
    if (kIsWeb) {
      // Web/Desktop specific sizing
      if (constraints.maxWidth > 1200) return 1920.0;
      if (constraints.maxWidth > 992) return 1280.0;
      if (constraints.maxWidth > 650) return 1024.0;
      return 640.0;
    } else {
      // Mobile specific sizing
      if (constraints.maxWidth > 600) return 600.0;
      if (constraints.maxWidth > 400) return 400.0;
      return 320.0;
    }
  }
}

class ResponsiveBannerImage extends StatelessWidget {
  final String bannerUrl;
  final double maxWidth;

  const ResponsiveBannerImage(
      {Key? key, required this.bannerUrl, required this.maxWidth})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final processedUrl = _buildResizedBannerUrl(bannerUrl, maxWidth);

    return AspectRatio(
      aspectRatio: 16 / 9, // YouTube's standard banner aspect ratio
      child: ClipRRect(
        borderRadius:
            BorderRadius.zero, // Remove border radius to match YouTube
        child: Image.network(
          processedUrl,
          fit: BoxFit.cover,
          width: double.infinity,
          errorBuilder: (context, error, stackTrace) {
            print('Banner image error: $error');
            return Container(
              color: Colors.grey[200],
              child: Center(
                child: Icon(
                  Icons.broken_image_outlined,
                  color: Colors.grey[500],
                  size: 50,
                ),
              ),
            );
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              color: Colors.grey[200],
              child: Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  String _buildResizedBannerUrl(String originalUrl, double width) {
    try {
      // Remove existing width parameters if present
      final baseUrl = originalUrl.split('=w')[0];

      // Construct new URL with specific width
      return '$baseUrl=w${width.toInt()}-fcrop64=1,00000000ffffffff-k-c0xffffffff-no-nd-rj';
    } catch (e) {
      print('URL processing error: $e');
      return originalUrl;
    }
  }
}
