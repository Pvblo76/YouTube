class VideoListResponse {
  final String? kind;
  final String? etag;
  final List<Video>? items;
  String? nextPageToken;
  final PageInfo? pageInfo;

  VideoListResponse({
    required this.kind,
    required this.etag,
    required this.items,
    required this.nextPageToken,
    required this.pageInfo,
  });

  factory VideoListResponse.fromJson(Map<String, dynamic> json) =>
      VideoListResponse(
        kind: json["kind"],
        etag: json["etag"],
        items: json["items"] != null
            ? List<Video>.from(json["items"].map((x) => Video.fromJson(x)))
            : null,
        nextPageToken: json["nextPageToken"],
        pageInfo: json["pageInfo"] != null
            ? PageInfo.fromJson(json["pageInfo"])
            : null,
      );

  Map<String, dynamic> toJson() => {
        "kind": kind,
        "etag": etag,
        "items": items != null
            ? List<dynamic>.from(items!.map((x) => x.toJson()))
            : null,
        "nextPageToken": nextPageToken,
        "pageInfo": pageInfo?.toJson(),
      };
}

class Video {
  final String? kind;
  final String? etag;
  final String? id;
  final Snippet? snippet;
  final ContentDetails? contentDetails;
  final Statistics? statistics;
  final ChannelDetails? channelDetails;

  Video({
    this.channelDetails,
    required this.kind,
    required this.etag,
    required this.id,
    required this.snippet,
    required this.contentDetails,
    required this.statistics,
  });

  factory Video.fromJson(Map<String, dynamic> json) => Video(
        kind: json["kind"],
        etag: json["etag"],
        id: json["id"],
        snippet:
            json["snippet"] != null ? Snippet.fromJson(json["snippet"]) : null,
        contentDetails: json["contentDetails"] != null
            ? ContentDetails.fromJson(json["contentDetails"])
            : null,
        statistics: json["statistics"] != null
            ? Statistics.fromJson(json["statistics"])
            : null,
        channelDetails: json["channelDetails"] != null
            ? ChannelDetails.fromJson(json["channelDetails"])
            : null,
      );

  Map<String, dynamic> toJson() => {
        "kind": kind,
        "etag": etag,
        "id": id,
        "snippet": snippet?.toJson(),
        "contentDetails": contentDetails?.toJson(),
        "statistics": statistics?.toJson(),
        "channelDetails": channelDetails?.toJson(),
      };
}

class Snippet {
  final DateTime? publishedAt;
  final String? channelId;
  final String? title;
  final String? description;
  final Thumbnails? thumbnails;
  final String? channelTitle;
  final List<String>? tags;
  final String? categoryId;
  final String? liveBroadcastContent;
  final Localized? localized;

  Snippet({
    required this.publishedAt,
    required this.channelId,
    required this.title,
    required this.description,
    required this.thumbnails,
    required this.channelTitle,
    required this.tags,
    required this.categoryId,
    required this.liveBroadcastContent,
    required this.localized,
  });

  factory Snippet.fromJson(Map<String, dynamic> json) => Snippet(
        publishedAt: json["publishedAt"] != null
            ? DateTime.parse(json["publishedAt"])
            : null,
        channelId: json["channelId"],
        title: json["title"],
        description: json["description"],
        thumbnails: json["thumbnails"] != null
            ? Thumbnails.fromJson(json["thumbnails"])
            : null,
        channelTitle: json["channelTitle"],
        tags: json["tags"] != null
            ? List<String>.from(json["tags"].map((x) => x))
            : null,
        categoryId: json["categoryId"],
        liveBroadcastContent: json["liveBroadcastContent"],
        localized: json["localized"] != null
            ? Localized.fromJson(json["localized"])
            : null,
      );

  Map<String, dynamic> toJson() => {
        "publishedAt": publishedAt?.toIso8601String(),
        "channelId": channelId,
        "title": title,
        "description": description,
        "thumbnails": thumbnails?.toJson(),
        "channelTitle": channelTitle,
        "tags": tags != null ? List<dynamic>.from(tags!.map((x) => x)) : null,
        "categoryId": categoryId,
        "liveBroadcastContent": liveBroadcastContent,
        "localized": localized?.toJson(),
      };
}

class Thumbnails {
  final Thumbnail? defaultThumbnail;
  final Thumbnail? medium;
  final Thumbnail? high;
  final Thumbnail? standard;
  final Thumbnail? maxres;

  Thumbnails({
    required this.defaultThumbnail,
    required this.medium,
    required this.high,
    required this.standard,
    required this.maxres,
  });

  factory Thumbnails.fromJson(Map<String, dynamic> json) => Thumbnails(
        defaultThumbnail: json["default"] != null
            ? Thumbnail.fromJson(json["default"])
            : null,
        medium:
            json["medium"] != null ? Thumbnail.fromJson(json["medium"]) : null,
        high: json["high"] != null ? Thumbnail.fromJson(json["high"]) : null,
        standard: json["standard"] != null
            ? Thumbnail.fromJson(json["standard"])
            : null,
        maxres:
            json["maxres"] != null ? Thumbnail.fromJson(json["maxres"]) : null,
      );

  Map<String, dynamic> toJson() => {
        "default": defaultThumbnail?.toJson(),
        "medium": medium?.toJson(),
        "high": high?.toJson(),
        "standard": standard?.toJson(),
        "maxres": maxres?.toJson(),
      };
}

class Thumbnail {
  final String? url;
  final int? width;
  final int? height;

  Thumbnail({
    required this.url,
    required this.width,
    required this.height,
  });

  factory Thumbnail.fromJson(Map<String, dynamic> json) => Thumbnail(
        url: json["url"],
        width: json["width"],
        height: json["height"],
      );

  Map<String, dynamic> toJson() => {
        "url": url,
        "width": width,
        "height": height,
      };
}

class Localized {
  final String? title;
  final String? description;

  Localized({
    required this.title,
    required this.description,
  });

  factory Localized.fromJson(Map<String, dynamic> json) => Localized(
        title: json["title"],
        description: json["description"],
      );

  Map<String, dynamic> toJson() => {
        "title": title,
        "description": description,
      };
}

class ContentDetails {
  final String? duration;
  final String? dimension;
  final String? definition;
  final String? caption;
  final bool? licensedContent;
  final String? projection;

  ContentDetails({
    required this.duration,
    required this.dimension,
    required this.definition,
    required this.caption,
    required this.licensedContent,
    required this.projection,
  });

  factory ContentDetails.fromJson(Map<String, dynamic> json) => ContentDetails(
        duration: json["duration"],
        dimension: json["dimension"],
        definition: json["definition"],
        caption: json["caption"],
        licensedContent: json["licensedContent"],
        projection: json["projection"],
      );

  Map<String, dynamic> toJson() => {
        "duration": duration,
        "dimension": dimension,
        "definition": definition,
        "caption": caption,
        "licensedContent": licensedContent,
        "projection": projection,
      };
}

class Statistics {
  final String? viewCount;
  final String? likeCount;
  final String? favoriteCount;
  final String? commentCount;

  Statistics({
    required this.viewCount,
    required this.likeCount,
    required this.favoriteCount,
    required this.commentCount,
  });

  factory Statistics.fromJson(Map<String, dynamic> json) => Statistics(
        viewCount: json["viewCount"],
        likeCount: json["likeCount"],
        favoriteCount: json["favoriteCount"],
        commentCount: json["commentCount"],
      );

  Map<String, dynamic> toJson() => {
        "viewCount": viewCount,
        "likeCount": likeCount,
        "favoriteCount": favoriteCount,
        "commentCount": commentCount,
      };
}

class ChannelDetails {
  final String? id;
  final ChannelSnippet? snippet;
  final ChannelStatistics? statistics;

  ChannelDetails({
    required this.id,
    required this.snippet,
    required this.statistics,
  });

  factory ChannelDetails.fromJson(Map<String, dynamic> json) => ChannelDetails(
        id: json["id"],
        snippet: json["snippet"] != null
            ? ChannelSnippet.fromJson(json["snippet"])
            : null,
        statistics: json["statistics"] != null
            ? ChannelStatistics.fromJson(json["statistics"])
            : null,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "snippet": snippet?.toJson(),
        "statistics": statistics?.toJson(),
      };
}

class ChannelSnippet {
  final String? title;
  final String? description;
  final String? customUrl;
  final Thumbnails? thumbnails;

  ChannelSnippet({
    required this.title,
    required this.description,
    required this.customUrl,
    required this.thumbnails,
  });

  factory ChannelSnippet.fromJson(Map<String, dynamic> json) => ChannelSnippet(
        title: json["title"],
        description: json["description"],
        customUrl: json["customUrl"],
        thumbnails: json["thumbnails"] != null
            ? Thumbnails.fromJson(json["thumbnails"])
            : null,
      );

  Map<String, dynamic> toJson() => {
        "title": title,
        "description": description,
        "customUrl": customUrl,
        "thumbnails": thumbnails?.toJson(),
      };
}

class ChannelStatistics {
  final String? subscriberCount;
  final String? videoCount;
  final String? viewCount;

  ChannelStatistics({
    required this.subscriberCount,
    required this.videoCount,
    required this.viewCount,
  });

  factory ChannelStatistics.fromJson(Map<String, dynamic> json) =>
      ChannelStatistics(
        subscriberCount: json["subscriberCount"],
        videoCount: json["videoCount"],
        viewCount: json["viewCount"],
      );

  Map<String, dynamic> toJson() => {
        "subscriberCount": subscriberCount,
        "videoCount": videoCount,
        "viewCount": viewCount,
      };
}

class PageInfo {
  final int? totalResults;
  final int? resultsPerPage;

  PageInfo({
    required this.totalResults,
    required this.resultsPerPage,
  });

  factory PageInfo.fromJson(Map<String, dynamic> json) => PageInfo(
        totalResults: json["totalResults"],
        resultsPerPage: json["resultsPerPage"],
      );

  Map<String, dynamic> toJson() => {
        "totalResults": totalResults,
        "resultsPerPage": resultsPerPage,
      };
}
