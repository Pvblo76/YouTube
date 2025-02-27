import 'package:flutter/material.dart';

class CustomVideoThumbnail extends StatefulWidget {
  final String thumbnailUrl;
  final bool isMobile;
  final double? customAspectRatio;

  const CustomVideoThumbnail({
    super.key,
    required this.thumbnailUrl,
    this.isMobile = true,
    this.customAspectRatio,
  });

  @override
  State<CustomVideoThumbnail> createState() => _CustomVideoThumbnailState();
}

class _CustomVideoThumbnailState extends State<CustomVideoThumbnail> {
  ImageProvider? _thumbnailImage;
  bool _hasError = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadThumbnailImage();
  }

  @override
  void didUpdateWidget(CustomVideoThumbnail oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.thumbnailUrl != widget.thumbnailUrl) {
      _loadThumbnailImage();
    }
  }

  void _loadThumbnailImage() {
    setState(() {
      _isLoading = true;
    });

    _thumbnailImage = NetworkImage(widget.thumbnailUrl)
      ..resolve(ImageConfiguration()).addListener(
        ImageStreamListener(
          (info, call) {
            if (mounted) {
              setState(() {
                _hasError = false;
                _isLoading = false;
              });
            }
          },
          onError: (exception, stackTrace) {
            if (mounted) {
              setState(() {
                _hasError = true;
                _isLoading = false;
              });
            }
          },
        ),
      );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Icon(
          Icons.play_circle_outline,
          size: 48,
          color: Colors.grey[400],
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(
              Colors.grey.shade500,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: widget.customAspectRatio ?? 16 / 9,
      child: ClipRRect(
        borderRadius:
            widget.isMobile ? BorderRadius.zero : BorderRadius.circular(15),
        child: _isLoading
            ? _buildLoadingIndicator()
            : _hasError
                ? _buildPlaceholder()
                : Image(
                    image: _thumbnailImage ?? NetworkImage(widget.thumbnailUrl),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        _buildPlaceholder(),
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return _buildLoadingIndicator();
                    },
                  ),
      ),
    );
  }
}
