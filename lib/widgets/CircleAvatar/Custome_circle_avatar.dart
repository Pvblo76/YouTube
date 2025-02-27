import 'package:flutter/material.dart';

class CustomCircleAvatar extends StatefulWidget {
  final String avatarUrl;
  final bool isMobile;
  final double? customSize;

  const CustomCircleAvatar({
    super.key,
    required this.avatarUrl,
    this.isMobile = true,
    this.customSize,
  });

  @override
  State<CustomCircleAvatar> createState() => _CustomCircleAvatarState();
}

class _CustomCircleAvatarState extends State<CustomCircleAvatar> {
  ImageProvider? _avatarImage;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadAvatarImage();
  }

  @override
  void didUpdateWidget(CustomCircleAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.avatarUrl != widget.avatarUrl) {
      _loadAvatarImage();
    }
  }

  void _loadAvatarImage() {
    _avatarImage = NetworkImage(widget.avatarUrl)
      ..resolve(ImageConfiguration()).addListener(
        ImageStreamListener(
          (info, call) {
            if (mounted) {
              setState(() {
                _hasError = false;
              });
            }
          },
          onError: (exception, stackTrace) {
            if (mounted) {
              setState(() {
                _hasError = true;
              });
            }
          },
        ),
      );
  }

  Widget _buildErrorIcon(double size) {
    return Center(
      child: Icon(
        Icons.account_circle,
        size: size,
        color: Colors.grey[400],
      ),
    );
  }

  Widget _buildLoadingIndicator(double size, ImageChunkEvent? loadingProgress) {
    return Center(
      child: SizedBox(
        width: size * 0.5,
        height: size * 0.5,
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
            Colors.grey.shade500,
          ),
          value: loadingProgress?.expectedTotalBytes != null
              ? loadingProgress!.cumulativeBytesLoaded /
                  loadingProgress.expectedTotalBytes!
              : null,
          strokeWidth: 2,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double size = widget.customSize ?? (widget.isMobile ? 50.0 : 40.0);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey[200],
      ),
      clipBehavior: Clip.antiAlias,
      child: _hasError
          ? _buildErrorIcon(size)
          : Image(
              image: _avatarImage ?? NetworkImage(widget.avatarUrl),
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  _buildErrorIcon(size),
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return _buildLoadingIndicator(size, loadingProgress);
              },
            ),
    );
  }
}
