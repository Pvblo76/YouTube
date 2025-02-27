class Formates {
  String timeAgo(String dateString) {
    DateTime dateTime = DateTime.parse(dateString); // Parse the ISO date string
    Duration difference =
        DateTime.now().difference(dateTime); // Calculate the time difference

    if (difference.inSeconds < 60) {
      return '${difference.inSeconds} seconds ago';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()} week${(difference.inDays / 7).floor() == 1 ? '' : 's'} ago';
    } else if (difference.inDays < 365) {
      return '${(difference.inDays / 30).floor()} month${(difference.inDays / 30).floor() == 1 ? '' : 's'} ago';
    } else {
      return '${(difference.inDays / 365).floor()} year${(difference.inDays / 365).floor() == 1 ? '' : 's'} ago';
    }
  }

  String formatViewCount(String viewCount) {
    int views = int.parse(viewCount); // Convert the view count to an integer

    if (views >= 1000000000) {
      return '${(views / 1000000000).toStringAsFixed(1)}B views'; // Format for billions
    } else if (views >= 1000000) {
      return '${(views / 1000000).toStringAsFixed(1)}M views'; // Format for millions
    } else if (views >= 1000) {
      return '${(views / 1000).toStringAsFixed(1)}K views'; // Format for thousands
    } else {
      return views.toString(); // Return the exact view count if less than 1,000
    }
  }

  String formatsubCount(String subCount) {
    int views = int.parse(subCount); // Convert the view count to an integer

    if (views >= 1000000000) {
      return '${(views / 1000000000).toStringAsFixed(1)}B'; // Format for billions
    } else if (views >= 1000000) {
      return '${(views / 1000000).toStringAsFixed(1)}M'; // Format for millions
    } else if (views >= 1000) {
      return '${(views / 1000).toStringAsFixed(1)}K'; // Format for thousands
    } else {
      return views.toString(); // Return the exact view count if less than 1,000
    }
  }

  String formatLikes(String likeCountStr) {
    int count = int.parse(likeCountStr); // Convert string to integer

    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    } else {
      return count.toString();
    }
  }

  String videoDurations(String duration) {
    // Regular expression to extract hours, minutes, and seconds
    final regExp = RegExp(r'PT(?:(\d+)H)?(?:(\d+)M)?(?:(\d+)S)?');
    final match = regExp.firstMatch(duration);

    if (match != null) {
      final hours = int.tryParse(match.group(1) ?? '0') ?? 0;
      final minutes = int.tryParse(match.group(2) ?? '0') ?? 0;
      final seconds = int.tryParse(match.group(3) ?? '0') ?? 0;

      // Format as HH:MM:SS or MM:SS
      if (hours > 0) {
        return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
      } else {
        return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
      }
    }

    return '00:00'; // Default if duration is invalid
  }
}
