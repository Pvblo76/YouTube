import 'package:flutter/material.dart';

class VideoDetailsBottomSheets extends StatefulWidget {
  final String title;
  final String description;
  final int viewCount;
  final DateTime uploadDate;
  final String channelName;
  final String channelAvatar;
  final int subscriberCount;
  final List<Comment> comments;

  const VideoDetailsBottomSheets({
    Key? key,
    required this.title,
    required this.description,
    required this.viewCount,
    required this.uploadDate,
    required this.channelName,
    required this.channelAvatar,
    required this.subscriberCount,
    required this.comments,
  }) : super(key: key);

  @override
  _VideoDetailsBottomSheetsState createState() =>
      _VideoDetailsBottomSheetsState();
}

class _VideoDetailsBottomSheetsState extends State<VideoDetailsBottomSheets> {
  void _showDescriptionSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
          ),
          child: Column(
            children: [
              // Drag handle
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildStatsRow(),
                    const SizedBox(height: 16),
                    _buildChannelInfo(),
                    const Divider(height: 32),
                    Text(widget.description),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCommentsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
          ),
          child: Column(
            children: [
              // Drag handle
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Text(
                      'Comments ${widget.comments.length}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              _buildCommentInput(),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: widget.comments.length,
                  itemBuilder: (context, index) => CommentTile(
                    comment: widget.comments[index],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVideoInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(
              '${_formatNumber(widget.viewCount)} views',
              style: const TextStyle(color: Colors.grey),
            ),
            const Text(' • '),
            Text(
              _formatTimeAgo(widget.uploadDate),
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
        TextButton(
          onPressed: _showDescriptionSheet,
          child: const Text(
            '...more',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      ],
    );
  }

  Widget _buildCommentsPreview() {
    return InkWell(
      onTap: _showCommentsSheet,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Comments ${widget.comments.length}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (widget.comments.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundImage: NetworkImage(
                      widget.comments.first.userAvatar,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.comments.first.text,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Text(
          '${_formatNumber(widget.viewCount)} views',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 8),
        Text(
          _formatTimeAgo(widget.uploadDate),
          style: const TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildChannelInfo() {
    return Row(
      children: [
        CircleAvatar(
          backgroundImage: NetworkImage(widget.channelAvatar),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.channelName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                '${_formatNumber(widget.subscriberCount)} subscribers',
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
        TextButton(
          onPressed: () {},
          child: const Text(
            'SUBSCRIBE',
            style: TextStyle(color: Colors.red),
          ),
        ),
      ],
    );
  }

  Widget _buildCommentInput() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 16,
            child: Icon(Icons.person),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Add a comment...',
                border: UnderlineInputBorder(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  String _formatTimeAgo(DateTime date) {
    final difference = DateTime.now().difference(date);
    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} years ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} months ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else {
      return 'Today';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildVideoInfo(),
        const Divider(),
        _buildCommentsPreview(),
      ],
    );
  }
}

class Comment {
  final String username;
  final String userAvatar;
  final String text;
  final DateTime timestamp;
  final int likes;
  final List<Comment> replies;

  Comment({
    required this.username,
    required this.userAvatar,
    required this.text,
    required this.timestamp,
    required this.likes,
    this.replies = const [],
  });
}

class CommentTile extends StatelessWidget {
  final Comment comment;

  const CommentTile({Key? key, required this.comment}) : super(key: key);

  String _formatTimeAgo(DateTime date) {
    final difference = DateTime.now().difference(date);
    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} years ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} months ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else {
      return 'Today';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundImage: NetworkImage(comment.userAvatar),
          ),
          const SizedBox(width: 16.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      comment.username,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 8.0),
                    Text(
                      _formatTimeAgo(comment.timestamp),
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 4.0),
                Text(comment.text),
                const SizedBox(height: 8.0),
                Row(
                  children: [
                    const Icon(Icons.thumb_up_outlined, size: 16.0),
                    const SizedBox(width: 4.0),
                    Text('${comment.likes}'),
                    const SizedBox(width: 16.0),
                    const Icon(Icons.thumb_down_outlined, size: 16.0),
                    const SizedBox(width: 16.0),
                    const Text('REPLY'),
                  ],
                ),
                if (comment.replies.isNotEmpty) ...[
                  const SizedBox(height: 8.0),
                  InkWell(
                    onTap: () {},
                    child: Row(
                      children: [
                        const Icon(
                          Icons.subdirectory_arrow_right,
                          color: Colors.blue,
                        ),
                        const SizedBox(width: 8.0),
                        Text(
                          '${comment.replies.length} replies',
                          style: const TextStyle(color: Colors.blue),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
