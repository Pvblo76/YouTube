class ChannelListResponse {
  final String kind;
  final String etag;
  final PageInfo pageInfo;
  final List<Channel> items;

  ChannelListResponse({
    required this.kind,
    required this.etag,
    required this.pageInfo,
    required this.items,
  });

  factory ChannelListResponse.fromJson(Map<String, dynamic> json) {
    return ChannelListResponse(
      kind: json['kind'],
      etag: json['etag'],
      pageInfo: PageInfo.fromJson(json['pageInfo']),
      items: List<Channel>.from(
        json['items'].map((item) => Channel.fromJson(item)),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'kind': kind,
      'etag': etag,
      'pageInfo': pageInfo.toJson(),
      'items': items.map((channel) => channel.toJson()).toList(),
    };
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

  Map<String, dynamic> toJson() {
    return {
      'totalResults': totalResults,
      'resultsPerPage': resultsPerPage,
    };
  }
}

class Channel {
  final String kind;
  final String etag;
  final String id;
  final Snippet snippet;
  final Statistics statistics;

  Channel({
    required this.kind,
    required this.etag,
    required this.id,
    required this.snippet,
    required this.statistics,
  });

  factory Channel.fromJson(Map<String, dynamic> json) {
    return Channel(
      kind: json['kind'],
      etag: json['etag'],
      id: json['id'],
      snippet: Snippet.fromJson(json['snippet']),
      statistics: Statistics.fromJson(json['statistics']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'kind': kind,
      'etag': etag,
      'id': id,
      'snippet': snippet.toJson(),
      'statistics': statistics.toJson(),
    };
  }
}

class Snippet {
  final String title;
  final String description;
  final String customUrl;
  final String publishedAt;
  final Thumbnails thumbnails;
  final Localized localized;
  final String country;

  Snippet({
    required this.title,
    required this.description,
    required this.customUrl,
    required this.publishedAt,
    required this.thumbnails,
    required this.localized,
    required this.country,
  });

  factory Snippet.fromJson(Map<String, dynamic> json) {
    return Snippet(
      title: json['title'],
      description: json['description'],
      customUrl: json['customUrl'],
      publishedAt: json['publishedAt'],
      thumbnails: Thumbnails.fromJson(json['thumbnails']),
      localized: Localized.fromJson(json['localized']),
      country: json['country'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'customUrl': customUrl,
      'publishedAt': publishedAt,
      'thumbnails': thumbnails.toJson(),
      'localized': localized.toJson(),
      'country': country,
    };
  }
}

class Thumbnails {
  final ThumbnailInfo defaultThumb;
  final ThumbnailInfo medium;
  final ThumbnailInfo high;

  Thumbnails({
    required this.defaultThumb,
    required this.medium,
    required this.high,
  });

  factory Thumbnails.fromJson(Map<String, dynamic> json) {
    return Thumbnails(
      defaultThumb: ThumbnailInfo.fromJson(json['default']),
      medium: ThumbnailInfo.fromJson(json['medium']),
      high: ThumbnailInfo.fromJson(json['high']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'default': defaultThumb.toJson(),
      'medium': medium.toJson(),
      'high': high.toJson(),
    };
  }
}

class ThumbnailInfo {
  final String url;
  final int width;
  final int height;

  ThumbnailInfo({
    required this.url,
    required this.width,
    required this.height,
  });

  factory ThumbnailInfo.fromJson(Map<String, dynamic> json) {
    return ThumbnailInfo(
      url: json['url'],
      width: json['width'],
      height: json['height'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'width': width,
      'height': height,
    };
  }
}

class Localized {
  final String title;
  final String description;

  Localized({
    required this.title,
    required this.description,
  });

  factory Localized.fromJson(Map<String, dynamic> json) {
    return Localized(
      title: json['title'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
    };
  }
}

class Statistics {
  final String viewCount;
  final String subscriberCount;
  final bool hiddenSubscriberCount;
  final String videoCount;

  Statistics({
    required this.viewCount,
    required this.subscriberCount,
    required this.hiddenSubscriberCount,
    required this.videoCount,
  });

  factory Statistics.fromJson(Map<String, dynamic> json) {
    return Statistics(
      viewCount: json['viewCount'],
      subscriberCount: json['subscriberCount'],
      hiddenSubscriberCount: json['hiddenSubscriberCount'],
      videoCount: json['videoCount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'viewCount': viewCount,
      'subscriberCount': subscriberCount,
      'hiddenSubscriberCount': hiddenSubscriberCount,
      'videoCount': videoCount,
    };
  }
}
