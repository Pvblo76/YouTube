import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:youtube/responsive/responsiveness.dart';
import 'package:youtube/theme/theme_manager.dart';

class YouTubeComments extends StatefulWidget {
  final String currentUserAvatar;
  final List<CommentData> comments;
  final String commentsCount;
  final bool isDesktop;

  const YouTubeComments({
    Key? key,
    required this.currentUserAvatar,
    required this.comments,
    this.isDesktop = false,
    required this.commentsCount,
  }) : super(key: key);

  @override
  State<YouTubeComments> createState() => _YouTubeCommentsState();
}

class _YouTubeCommentsState extends State<YouTubeComments> {
  final TextEditingController _commentController = TextEditingController();
  ValueNotifier<bool> _isCommentButtonEnabled = ValueNotifier<bool>(false);
  bool _isCommenting = false;
  String _sortBy = 'Top comments';

  ImageProvider? _avatarImage;
  bool _hasError = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _isCommentButtonEnabled = ValueNotifier<bool>(false);
    _commentController.addListener(_updateCommentButtonState);
    _loadAvatarImage();
    _loadComments();
  }

  void _updateCommentButtonState() {
    _isCommentButtonEnabled.value = _commentController.text.trim().isNotEmpty;
  }

  void _loadAvatarImage() {
    _avatarImage = NetworkImage(widget.currentUserAvatar)
      ..resolve(const ImageConfiguration()).addListener(
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

  Widget _buildAvatar() {
    final double size = 35.0;
    final theme = Provider.of<YouTubeTheme>(context);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey[200],
      ),
      clipBehavior: Clip.antiAlias, // Ensures perfect circular clipping
      child: _hasError
          ? Center(
              child: Icon(
                Icons.account_circle,
                size: size,
                color: Colors.grey[400],
              ),
            )
          : Image(
              image: _avatarImage ?? NetworkImage(widget.currentUserAvatar),
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Center(
                  child: Icon(
                    Icons.account_circle,
                    size: size,
                    color: Colors.grey[400],
                  ),
                );
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: SizedBox(
                    width:
                        size * 0.5, // Make loader slightly smaller than avatar
                    height: size * 0.5,
                    child: CircularProgressIndicator(
                      color: theme.verifiedIconColor,
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                      strokeWidth: 2,
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _cancelComment() {
    setState(() {
      _isCommenting = false;
      _commentController.clear();
      _focusNode.unfocus();
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    _focusNode.dispose();
    _isCommentButtonEnabled.dispose();
    super.dispose();
  }

  // Method to save comments to SharedPreferences
  Future<void> _saveComments() async {
    final prefs = await SharedPreferences.getInstance();
    final comments = widget.comments
        .map((comment) => {
              'username': comment.username,
              'userAvatar': comment.userAvatar,
              'text': comment.text,
              'timestamp': comment.timestamp,
              'likes': comment.likes,
              'replies': comment.replies,
            })
        .toList();
    await prefs.setString('comments', comments.toString());
  }

  // Method to load comments from SharedPreferences
  Future<void> _loadComments() async {
    final prefs = await SharedPreferences.getInstance();
    final savedComments = prefs.getString('comments');
    if (savedComments != null) {
      setState(() {
        // Parse and load saved comments
        widget.comments.clear();
        // Add parsed comments back to the list
        // (You can implement a parsing method to handle this.)
      });
    }
  }

  // Method to handle posting a comment
  void _postComment() {
    final newComment = CommentData(
      username: 'Imran', // Replace with the current user's name
      userAvatar: 'https://avatars.githubusercontent.com/u/48078961?v=4',
      text: _commentController.text.trim(),
      timestamp: 'Just now', // Replace with current timestamp logic
      likes: 0,
      replies: 0,
    );
    setState(() {
      widget.comments.insert(0, newComment);
      _commentController.clear();
      _isCommenting = false;
      _focusNode.unfocus();
    });
    _saveComments(); // Save the updated comments
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = Responsive.isMobile(context);
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: Responsive.isTablet(context)
              ? 20
              : Responsive.isDesktop(context)
                  ? 30
                  : 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          isMobile ? const SizedBox.shrink() : _buildCommentsHeader(),
          const SizedBox(height: 16),
          if (widget.isDesktop) ...[
            _buildDesktopCommentInput(),
          ] else ...[
            _buildMobileCommentInput(),
          ],
          const SizedBox(height: 24),
          _buildCommentsList(),
        ],
      ),
    );
  }

  Widget _buildCommentsHeader() {
    final theme = Provider.of<YouTubeTheme>(context);
    final isDark = theme.isDarkMode;
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: widget.isDesktop ? 0 : 16.0,
      ),
      child: Row(
        children: [
          Text(
            '${widget.commentsCount} Comments',
            style: GoogleFonts.roboto(
              fontSize: 16,
              color: isDark ? Colors.white : Colors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 32),
          PopupMenuButton<String>(
            child: Row(
              children: [
                Icon(Icons.sort,
                    size: 20, color: isDark ? Colors.white : Colors.grey[800]),
                const SizedBox(width: 8),
                Text(
                  _sortBy,
                  style: GoogleFonts.roboto(
                    fontSize: 14,
                    color: isDark ? Colors.white : Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'Top comments',
                child: Text('Top comments'),
              ),
              const PopupMenuItem(
                value: 'Newest first',
                child: Text('Newest first'),
              ),
            ],
            onSelected: (value) {
              setState(() => _sortBy = value);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopCommentInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.grey[400],
            backgroundImage: NetworkImage(widget.currentUserAvatar),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _commentController,
                  focusNode: _focusNode,
                  onTap: () {
                    setState(() => _isCommenting = true);
                  },
                  style: GoogleFonts.roboto(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Add a comment...',
                    hintStyle: GoogleFonts.roboto(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    border: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey[600]!),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  minLines: 1,
                  maxLines: 5,
                  textCapitalization: TextCapitalization.sentences,
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  child: SizedBox(
                    height: _isCommenting ? 52 : 0,
                    child: _isCommenting
                        ? Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: _cancelComment,
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                  ),
                                  child: Text(
                                    'Cancel',
                                    style: GoogleFonts.roboto(
                                      color: Colors.grey[800],
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                ValueListenableBuilder<bool>(
                                  valueListenable: _isCommentButtonEnabled,
                                  builder: (context, isEnabled, _) {
                                    return ElevatedButton(
                                      onPressed:
                                          isEnabled ? _postComment : null,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: isEnabled
                                            ? Colors.blue
                                            : Colors.grey[300],
                                        disabledBackgroundColor:
                                            Colors.grey[300],
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(18),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 8,
                                        ),
                                        elevation: 0,
                                      ),
                                      child: Text(
                                        'Comment',
                                        style: GoogleFonts.roboto(
                                          color: isEnabled
                                              ? Colors.white
                                              : Colors.grey[500],
                                          fontSize: 14,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileCommentInput() {
    final theme = Provider.of<YouTubeTheme>(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          _buildAvatar(),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              height: 35,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: theme.containerBackgroundColor),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _commentController,
                  decoration: InputDecoration(
                    filled: false,
                    hintText: 'Add a comment...',
                    hintStyle: GoogleFonts.roboto(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.comments.length,
      itemBuilder: (context, index) {
        final comment = widget.comments[index];
        return CommentTile(
          comment: comment,
          isDesktop: widget.isDesktop,
        );
      },
    );
  }
}

class CommentTile extends StatefulWidget {
  final CommentData comment;
  final bool isDesktop;

  const CommentTile({
    Key? key,
    required this.comment,
    required this.isDesktop,
  }) : super(key: key);

  @override
  State<CommentTile> createState() => _CommentTileState();
}

class _CommentTileState extends State<CommentTile> {
  ImageProvider? _avatarImage;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadAvatarImage();
  }

  void _loadAvatarImage() {
    _avatarImage = NetworkImage(widget.comment.userAvatar)
      ..resolve(const ImageConfiguration()).addListener(
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

  Widget _buildAvatar() {
    final double size = 30.0;
    final theme = Provider.of<YouTubeTheme>(context);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey[200],
      ),
      clipBehavior: Clip.antiAlias, // Ensures perfect circular clipping
      child: _hasError
          ? Center(
              child: Icon(
                Icons.account_circle,
                size: size,
                color: Colors.grey[400],
              ),
            )
          : Image(
              image: _avatarImage ?? NetworkImage(widget.comment.userAvatar),
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Center(
                  child: Icon(
                    Icons.account_circle,
                    size: size,
                    color: Colors.grey[400],
                  ),
                );
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: SizedBox(
                    width:
                        size * 0.5, // Make loader slightly smaller than avatar
                    height: size * 0.5,
                    child: CircularProgressIndicator(
                      color: theme.verifiedIconColor,
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                      strokeWidth: 2,
                    ),
                  ),
                );
              },
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<YouTubeTheme>(context);
    final isDark = theme.isDarkMode;
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: widget.isDesktop ? 0 : 5.0,
        vertical: 16.0,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAvatar(),
          // CustomCircleAvatar(avatarUrl: widget.comment.userAvatar),
          // CircleAvatar(
          //   radius: 18,
          //   backgroundImage: NetworkImage(comment.userAvatar),
          // ),
          SizedBox(width: widget.isDesktop ? 16 : 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      widget.comment.username,
                      style: GoogleFonts.roboto(
                        fontSize: widget.isDesktop ? 13 : 10,
                        color: isDark ? Colors.white : Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.comment.timestamp,
                      style: GoogleFonts.roboto(
                        fontSize: widget.isDesktop ? 12 : 10,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  widget.comment.text,
                  style: GoogleFonts.roboto(
                    color: isDark ? Colors.white : Colors.black,
                    fontSize: widget.isDesktop ? 14 : 12,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildActionButton(Icons.thumb_up_outlined,
                        widget.comment.likes.toString(), context),
                    const SizedBox(width: 8),
                    _buildActionButton(Icons.thumb_down_outlined, '', context),
                    const SizedBox(width: 24),
                    _buildReplyButton(context),
                  ],
                ),
                if (widget.comment.replies > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: _buildViewRepliesButton(widget.comment.replies),
                  ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
            iconSize: 20,
            color: Colors.grey[700],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return InkWell(
      onTap: () {},
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: isDark ? Colors.white : Colors.grey[700],
          ),
          if (label.isNotEmpty) ...[
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.roboto(
                fontSize: 12,
                color: isDark ? Colors.grey[500] : Colors.grey[700],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildReplyButton(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return TextButton(
      onPressed: () {},
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: const Size(0, 0),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        'Reply',
        style: GoogleFonts.roboto(
          fontSize: 13,
          color: isDark ? Colors.white : Colors.grey[800],
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildViewRepliesButton(int replyCount) {
    return TextButton.icon(
      onPressed: () {},
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: const Size(0, 0),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      icon: const Icon(
        Icons.keyboard_arrow_down,
        size: 18,
        color: Colors.blueAccent,
      ),
      label: Text(
        '$replyCount replies',
        style: GoogleFonts.rubik(
          fontSize: 14,
          color: Colors.blueAccent,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class CommentData {
  final String username;
  final String userAvatar;
  final String text;
  final String timestamp;
  final int likes;
  final int replies;

  CommentData({
    required this.username,
    required this.userAvatar,
    required this.text,
    required this.timestamp,
    required this.likes,
    required this.replies,
  });
}
