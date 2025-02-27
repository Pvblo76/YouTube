class CommentThreadListResponse {
  final String kind;
  final String etag;
  final String? nextPageToken;
  final PageInfo pageInfo;
  final List<CommentThread> items;

  CommentThreadListResponse({
    required this.kind,
    required this.etag,
    this.nextPageToken,
    required this.pageInfo,
    required this.items,
  });

  factory CommentThreadListResponse.fromJson(Map<String, dynamic> json) {
    return CommentThreadListResponse(
      kind: json['kind'],
      etag: json['etag'],
      nextPageToken: json['nextPageToken'],
      pageInfo: PageInfo.fromJson(json['pageInfo']),
      items: (json['items'] as List)
          .map((item) => CommentThread.fromJson(item))
          .toList(),
    );
  }
}

class PageInfo {
  final int totalResults;
  final int resultsPerPage;

  PageInfo({
    required this.totalResults,
    required this.resultsPerPage,
  });

  factory PageInfo.fromJson(Map<String, dynamic> json) {
    return PageInfo(
      totalResults: json['totalResults'],
      resultsPerPage: json['resultsPerPage'],
    );
  }
}

class CommentThread {
  final String kind;
  final String etag;
  final String id;
  final Snippet snippet;
  final Replies? replies;

  CommentThread({
    required this.kind,
    required this.etag,
    required this.id,
    required this.snippet,
    this.replies,
  });

  factory CommentThread.fromJson(Map<String, dynamic> json) {
    return CommentThread(
      kind: json['kind'],
      etag: json['etag'],
      id: json['id'],
      snippet: Snippet.fromJson(json['snippet']),
      replies:
          json['replies'] != null ? Replies.fromJson(json['replies']) : null,
    );
  }
}

class Snippet {
  final String channelId;
  final String videoId;
  final TopLevelComment topLevelComment;
  final bool canReply;
  final int totalReplyCount;
  final bool isPublic;

  Snippet({
    required this.channelId,
    required this.videoId,
    required this.topLevelComment,
    required this.canReply,
    required this.totalReplyCount,
    required this.isPublic,
  });

  factory Snippet.fromJson(Map<String, dynamic> json) {
    return Snippet(
      channelId: json['channelId'],
      videoId: json['videoId'],
      topLevelComment: TopLevelComment.fromJson(json['topLevelComment']),
      canReply: json['canReply'],
      totalReplyCount: json['totalReplyCount'],
      isPublic: json['isPublic'],
    );
  }
}

class TopLevelComment {
  final String kind;
  final String etag;
  final String id;
  final SnippetDetail snippet;

  TopLevelComment({
    required this.kind,
    required this.etag,
    required this.id,
    required this.snippet,
  });

  factory TopLevelComment.fromJson(Map<String, dynamic> json) {
    return TopLevelComment(
      kind: json['kind'],
      etag: json['etag'],
      id: json['id'],
      snippet: SnippetDetail.fromJson(json['snippet']),
    );
  }
}

class SnippetDetail {
  final String channelId;
  final String videoId;
  final String textDisplay;
  final String textOriginal;
  final String authorDisplayName;
  final String authorProfileImageUrl;
  final String authorChannelUrl;
  final AuthorChannelId authorChannelId;
  final bool canRate;
  final String viewerRating;
  final int likeCount;
  final String publishedAt;
  final String updatedAt;

  SnippetDetail({
    required this.channelId,
    required this.videoId,
    required this.textDisplay,
    required this.textOriginal,
    required this.authorDisplayName,
    required this.authorProfileImageUrl,
    required this.authorChannelUrl,
    required this.authorChannelId,
    required this.canRate,
    required this.viewerRating,
    required this.likeCount,
    required this.publishedAt,
    required this.updatedAt,
  });

  factory SnippetDetail.fromJson(Map<String, dynamic> json) {
    return SnippetDetail(
      channelId: json['channelId'],
      videoId: json['videoId'],
      textDisplay: json['textDisplay'],
      textOriginal: json['textOriginal'],
      authorDisplayName: json['authorDisplayName'],
      authorProfileImageUrl: json['authorProfileImageUrl'],
      authorChannelUrl: json['authorChannelUrl'],
      authorChannelId: AuthorChannelId.fromJson(json['authorChannelId']),
      canRate: json['canRate'],
      viewerRating: json['viewerRating'],
      likeCount: json['likeCount'],
      publishedAt: json['publishedAt'],
      updatedAt: json['updatedAt'],
    );
  }
}

class AuthorChannelId {
  final String value;

  AuthorChannelId({required this.value});

  factory AuthorChannelId.fromJson(Map<String, dynamic> json) {
    return AuthorChannelId(value: json['value']);
  }
}

class Replies {
  final List<TopLevelComment> comments;

  Replies({required this.comments});

  factory Replies.fromJson(Map<String, dynamic> json) {
    return Replies(
      comments: (json['comments'] as List)
          .map((comment) => TopLevelComment.fromJson(comment))
          .toList(),
    );
  }
}
