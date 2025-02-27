class Channel {
  final String? id;
  final String? title;
  final String? localizedTitle;
  final String? description;
  final String? localizedDescription;
  final String? avatar;
  final String? bannerImageUrl;
  final String? subscriberCount;
  final String? videoCount;
  final String? viewCount;
  final String? country;
  final String? customUrl;

  Channel({
    this.customUrl,
    this.id,
    this.title,
    this.localizedTitle,
    this.description,
    this.localizedDescription,
    this.avatar,
    this.bannerImageUrl,
    this.subscriberCount,
    this.videoCount,
    this.viewCount,
    this.country,
  });

  factory Channel.fromJson(Map<String, dynamic> json) {
    return Channel(
      id: json['id'],
      title: json['snippet']?['title'],
      customUrl: json['snippet']?['customUrl'],
      localizedTitle: json['snippet']?['localized']?['title'],
      description: json['snippet']?['description'],
      localizedDescription: json['snippet']?['localized']?['description'],
      avatar: json['snippet']?['thumbnails']?['default']?['url'],
      bannerImageUrl: json['brandingSettings']?['image']?['bannerExternalUrl'],
      subscriberCount: json['statistics']?['subscriberCount'],
      videoCount: json['statistics']?['videoCount'],
      viewCount: json['statistics']?['viewCount'],
      country: json['snippet']?['country'],
    );
  }
}
