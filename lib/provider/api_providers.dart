import 'package:flutter/material.dart';
import 'package:youtube/model/channel.dart';
import 'package:youtube/model/comments_model.dart';
import 'package:youtube/model/videos_model.dart';
import 'package:youtube/network/repository/home_api_repo.dart';
import 'package:youtube/network/response/api_respones.dart';

class ApiProviders extends ChangeNotifier {
  final HomeApiRepo repo = HomeApiRepo();

  ApiRespones<VideoListResponse> videoResponse = ApiRespones.loading();
  ApiRespones<VideoListResponse> shortsResponse = ApiRespones.loading();
  ApiRespones<Channel> channelResponse = ApiRespones.loading();
  ApiRespones<VideoListResponse> recommendationResponse = ApiRespones.loading();
  ApiRespones<VideoListResponse> channelVideosResponse = ApiRespones.loading();
  final Map<String, String> _nextPageTokens = {};
  final Map<String, VideoListResponse> _cachedResponses = {};
  bool isLoadingMore = false;
  String? _nextPageToken;
  List<Video> channelVideosList = [];
  List<Video> videoList = [];
  List<Video> recommendedList = [];
  Channel? channel;
  final _cachedChannelDetails = <String, ChannelDetails>{};
  String? _currentQuery;
  List<Video> shortsList = [];
  final Map<String, String> _shortsNextPageTokens = {};
  final Map<String, VideoListResponse> _cachedShortsResponses = {};
  bool isLoadingMoreShorts = false;
  String? _currentShortsQuery;
  // Add these new variables for state persistence
  int _selectedTabIndex = 0;
  String _lastQuery = "ai OR coding OR season OR netflix";

  final String _lastShortQuery =
      "sports shorts OR motivational shorts OR shorts";
  // Getters for the new state variables
  int get selectedTabIndex => _selectedTabIndex;
  String get lastQuery => _lastQuery;
  String get lastShortQery => _lastShortQuery;
  bool isLoadingChannelVideos = false;

  ApiRespones<CommentThreadListResponse> commentResponse =
      ApiRespones.loading();
  final Map<String, String> _commentNextPageTokens = {};
  final Map<String, CommentThreadListResponse> _cachedCommentResponses = {};
  List<CommentThread> commentsList = [];
  bool isLoadingMoreComments = false;
  String? _currentVideoIdForComments;

  void setCommentData(ApiRespones<CommentThreadListResponse> response) {
    commentResponse = response;
    notifyListeners();
  }

  void setChannelVideosData(ApiRespones<VideoListResponse> response) {
    channelVideosResponse = response;
    notifyListeners();
  }

  // Method to update selected tab and query
  void updateSelectedTab(int index, String query) {
    _selectedTabIndex = index;
    _lastQuery = query;
    notifyListeners();
  }

  void setApiData(ApiRespones<VideoListResponse> response) {
    videoResponse = response;
    notifyListeners();
  }

  void setRecomendationsData(ApiRespones<VideoListResponse> response) {
    recommendationResponse = response;
    notifyListeners();
  }

  void setChannel(ApiRespones<Channel> response) {
    channelResponse = response;
    notifyListeners();
  }

  void setShortsData(ApiRespones<VideoListResponse> response) {
    shortsResponse = response;
    notifyListeners();
  }

  Future<void> fetchComments(String videoId,
      {bool forceRefetch = false, String order = 'relevance'}) async {
    if (!forceRefetch &&
        _currentVideoIdForComments == videoId &&
        _cachedCommentResponses.containsKey(videoId)) {
      final cachedResponse = _cachedCommentResponses[videoId]!;
      final updatedResponse = CommentThreadListResponse(
        kind: cachedResponse.kind,
        etag: cachedResponse.etag,
        nextPageToken: _commentNextPageTokens[videoId],
        pageInfo: cachedResponse.pageInfo,
        items: commentsList,
      );
      setCommentData(ApiRespones.complete(updatedResponse));
      return;
    }

    if (forceRefetch || _currentVideoIdForComments != videoId) {
      clearComments();
      _currentVideoIdForComments = videoId;
      setCommentData(ApiRespones.loading());

      try {
        final data = await repo.getComments(
          videoId,
        );

        commentsList = data.items ?? [];
        _commentNextPageTokens[videoId] = data.nextPageToken ?? '';
        _cachedCommentResponses[videoId] = data;
        setCommentData(ApiRespones.complete(data));
      } catch (error) {
        setCommentData(ApiRespones.error(error.toString()));
      }
    }
  }

  Future<void> fetchMoreComments(
    String videoId,
  ) async {
    if (_commentNextPageTokens[videoId]?.isNotEmpty == true &&
        !isLoadingMoreComments) {
      isLoadingMoreComments = true;

      try {
        final data = await repo.getComments(
          videoId,
          pageToken: _commentNextPageTokens[videoId],
        );

        if (data.items != null && data.items.isNotEmpty) {
          commentsList.addAll(data.items);
          _commentNextPageTokens[videoId] = data.nextPageToken ?? '';
          _cachedCommentResponses[videoId] = data;
        } else {
          _commentNextPageTokens[videoId] = '';
        }

        final updatedResponse = CommentThreadListResponse(
          kind: data.kind,
          etag: data.etag,
          nextPageToken: _commentNextPageTokens[videoId],
          pageInfo: data.pageInfo,
          items: commentsList,
        );
        setCommentData(ApiRespones.complete(updatedResponse));
      } catch (error) {
        setCommentData(ApiRespones.error(error.toString()));
      } finally {
        isLoadingMoreComments = false;
      }
    }
  }

  Future<void> fetchChannel(String id) async {
    setChannel(ApiRespones.loading());
    try {
      final data = await repo.getChannel(id);
      channel = data;
      setChannel(ApiRespones.complete(data));
    } catch (error) {
      setChannel(ApiRespones.error(error.toString()));
    }
  }

  // Initial fetch of channel videos
  Future<void> fetchChannelVideos(String channelId) async {
    setChannelVideosData(ApiRespones.loading());
    channelVideosList.clear();

    try {
      final data = await repo.getVideos(channelId);
      channelVideosList = data.items ?? [];
      _nextPageToken = data.nextPageToken;
      setChannelVideosData(ApiRespones.complete(data));
    } catch (error) {
      setChannelVideosData(ApiRespones.error(error.toString()));
    }
  }

  // Load more Channel videos
  Future<void> fetchMoreChannelVideos(String channelId) async {
    if (_nextPageToken?.isNotEmpty == true && !isLoadingChannelVideos) {
      isLoadingChannelVideos = true;

      try {
        final data = await repo.getVideos(
          channelId,
          pageToken: _nextPageToken,
        );

        if (data.items != null && data.items!.isNotEmpty) {
          channelVideosList.addAll(data.items!);
          _nextPageToken = data.nextPageToken;

          final updatedResponse = VideoListResponse(
            kind: data.kind,
            etag: data.etag,
            nextPageToken: _nextPageToken,
            pageInfo: data.pageInfo,
            items: channelVideosList,
          );
          setChannelVideosData(ApiRespones.complete(updatedResponse));
        }
      } catch (error) {
        setChannelVideosData(ApiRespones.error(error.toString()));
      } finally {
        isLoadingChannelVideos = false;
      }
    }
  }

  // Modified fetchVideos method with forceRefetch parameter

  Future<void> fetchVideos(String query, {bool forceRefetch = false}) async {
    if (!forceRefetch &&
        _currentQuery == query &&
        _cachedResponses.containsKey(query)) {
      final cachedResponse = _cachedResponses[query]!;
      final updatedResponse = VideoListResponse(
        kind: cachedResponse.kind,
        etag: cachedResponse.etag,
        nextPageToken: _nextPageTokens[query],
        pageInfo: cachedResponse.pageInfo,
        items: videoList.map((video) {
          // Ensure cached channel details are attached
          if (video.snippet?.channelId != null) {
            final channelId = video.snippet!.channelId!;
            if (_cachedChannelDetails.containsKey(channelId)) {
              return Video(
                kind: video.kind,
                etag: video.etag,
                id: video.id,
                snippet: video.snippet,
                contentDetails: video.contentDetails,
                statistics: video.statistics,
                channelDetails: _cachedChannelDetails[channelId],
              );
            }
          }
          return video;
        }).toList(),
      );
      setApiData(ApiRespones.complete(updatedResponse));
      return;
    }

    if (forceRefetch || _currentQuery != query) {
      clearVideos();
      _currentQuery = query;
      setApiData(ApiRespones.loading());

      try {
        final data = await repo.fetchRelatedVideosWithDetails(query);

        // Cache channel details
        if (data.items != null) {
          for (var video in data.items!) {
            if (video.channelDetails != null &&
                video.snippet?.channelId != null) {
              _cachedChannelDetails[video.snippet!.channelId!] =
                  video.channelDetails!;
            }
          }
        }

        videoList = data.items ?? [];
        _nextPageTokens[query] = data.nextPageToken ?? '';
        _cachedResponses[query] = data;
        setApiData(ApiRespones.complete(data));
      } catch (error) {
        setApiData(ApiRespones.error(error.toString()));
      }
    }
  }

  Future<void> fetchMoreVideos(String query) async {
    if (_nextPageTokens[query]?.isNotEmpty == true && !isLoadingMore) {
      isLoadingMore = true;

      try {
        final data = await repo.fetchRelatedVideosWithDetails(
          query,
          pageToken: _nextPageTokens[query],
        );

        if (data.items != null && data.items!.isNotEmpty) {
          // Cache new channel details
          for (var video in data.items!) {
            if (video.channelDetails != null &&
                video.snippet?.channelId != null) {
              _cachedChannelDetails[video.snippet!.channelId!] =
                  video.channelDetails!;
            }
          }

          videoList.addAll(data.items!);
          _nextPageTokens[query] = data.nextPageToken ?? '';
          _cachedResponses[query] = data;
        } else {
          _nextPageTokens[query] = '';
        }

        final updatedResponse = VideoListResponse(
          kind: data.kind,
          etag: data.etag,
          nextPageToken: _nextPageTokens[query],
          pageInfo: data.pageInfo,
          items: videoList.map((video) {
            // Ensure channel details are attached from cache
            if (video.snippet?.channelId != null) {
              final channelId = video.snippet!.channelId!;
              if (_cachedChannelDetails.containsKey(channelId)) {
                return Video(
                  kind: video.kind,
                  etag: video.etag,
                  id: video.id,
                  snippet: video.snippet,
                  contentDetails: video.contentDetails,
                  statistics: video.statistics,
                  channelDetails: _cachedChannelDetails[channelId],
                );
              }
            }
            return video;
          }).toList(),
        );
        setApiData(ApiRespones.complete(updatedResponse));
      } catch (error) {
        setApiData(ApiRespones.error(error.toString()));
      } finally {
        isLoadingMore = false;
      }
    }
  }

// Fetch shorts with caching
  Future<void> fetchShorts(String query, {bool forceRefetch = false}) async {
    if (!forceRefetch &&
        _currentShortsQuery == query &&
        _cachedShortsResponses.containsKey(query)) {
      final cachedResponse = _cachedShortsResponses[query]!;
      final updatedResponse = VideoListResponse(
        kind: cachedResponse.kind,
        etag: cachedResponse.etag,
        nextPageToken: _shortsNextPageTokens[query],
        pageInfo: cachedResponse.pageInfo,
        items: shortsList.map((video) {
          if (video.snippet?.channelId != null) {
            final channelId = video.snippet!.channelId!;
            if (_cachedChannelDetails.containsKey(channelId)) {
              return Video(
                kind: video.kind,
                etag: video.etag,
                id: video.id,
                snippet: video.snippet,
                contentDetails: video.contentDetails,
                statistics: video.statistics,
                channelDetails: _cachedChannelDetails[channelId],
              );
            }
          }
          return video;
        }).toList(),
      );
      setShortsData(ApiRespones.complete(updatedResponse));
      return;
    }

    if (forceRefetch || _currentShortsQuery != query) {
      clearShorts();
      _currentShortsQuery = query;
      setShortsData(ApiRespones.loading());

      try {
        final data = await repo.getShorts(query);

        // Cache channel details
        if (data.items != null) {
          for (var video in data.items!) {
            if (video.channelDetails != null &&
                video.snippet?.channelId != null) {
              _cachedChannelDetails[video.snippet!.channelId!] =
                  video.channelDetails!;
            }
          }
        }

        shortsList = data.items ?? [];
        _shortsNextPageTokens[query] = data.nextPageToken ?? '';
        _cachedShortsResponses[query] = data;
        setShortsData(ApiRespones.complete(data));
      } catch (error) {
        setShortsData(ApiRespones.error(error.toString()));
      }
    }
  }

  // Fetch more shorts with pagination
  Future<void> fetchMoreShorts(String query) async {
    if (_shortsNextPageTokens[query]?.isNotEmpty == true &&
        !isLoadingMoreShorts) {
      isLoadingMoreShorts = true;

      try {
        final data = await repo.getShorts(
          query,
          pageToken: _shortsNextPageTokens[query],
        );

        if (data.items != null && data.items!.isNotEmpty) {
          // Cache new channel details
          for (var video in data.items!) {
            if (video.channelDetails != null &&
                video.snippet?.channelId != null) {
              _cachedChannelDetails[video.snippet!.channelId!] =
                  video.channelDetails!;
            }
          }

          shortsList.addAll(data.items!);
          _shortsNextPageTokens[query] = data.nextPageToken ?? '';
          _cachedShortsResponses[query] = data;
        } else {
          _shortsNextPageTokens[query] = '';
        }

        final updatedResponse = VideoListResponse(
          kind: data.kind,
          etag: data.etag,
          nextPageToken: _shortsNextPageTokens[query],
          pageInfo: data.pageInfo,
          items: shortsList.map((video) {
            if (video.snippet?.channelId != null) {
              final channelId = video.snippet!.channelId!;
              if (_cachedChannelDetails.containsKey(channelId)) {
                return Video(
                  kind: video.kind,
                  etag: video.etag,
                  id: video.id,
                  snippet: video.snippet,
                  contentDetails: video.contentDetails,
                  statistics: video.statistics,
                  channelDetails: _cachedChannelDetails[channelId],
                );
              }
            }
            return video;
          }).toList(),
        );
        setShortsData(ApiRespones.complete(updatedResponse));
      } catch (error) {
        setShortsData(ApiRespones.error(error.toString()));
      } finally {
        isLoadingMoreShorts = false;
      }
    }
  }

  // Modified fetchRelatedVideos with caching consideration
  Future<void> fetchRelatedVideos(String query,
      {bool forceRefetch = false}) async {
    String cacheKey = 'related_$query';

    if (!forceRefetch && _cachedResponses.containsKey(cacheKey)) {
      final cachedResponse = _cachedResponses[cacheKey]!;
      setRecomendationsData(ApiRespones.complete(cachedResponse));
      return;
    }

    setRecomendationsData(ApiRespones.loading());
    try {
      final data = await repo.fetchRelatedVideosWithDetails(query);
      recommendedList = data.items ?? [];
      _nextPageTokens[cacheKey] = data.nextPageToken ?? '';
      _cachedResponses[cacheKey] = data;
      setRecomendationsData(ApiRespones.complete(data));
    } catch (error) {
      setRecomendationsData(ApiRespones.error(error.toString()));
    }
  }

  Future<void> fetchMoreRelatedVideos(String query) async {
    String cacheKey = 'related_$query';
    if (_nextPageTokens[cacheKey]?.isNotEmpty == true && !isLoadingMore) {
      isLoadingMore = true;

      try {
        final data = await repo.fetchRelatedVideosWithDetails(
          query,
          pageToken: _nextPageTokens[cacheKey],
        );

        if (data.items != null && data.items!.isNotEmpty) {
          recommendedList.addAll(data.items!);
          _nextPageTokens[cacheKey] = data.nextPageToken ?? '';
          _cachedResponses[cacheKey] = data;
        } else {
          _nextPageTokens[cacheKey] = '';
        }

        final updatedResponse = VideoListResponse(
          kind: data.kind,
          etag: data.etag,
          nextPageToken: _nextPageTokens[cacheKey],
          pageInfo: data.pageInfo,
          items: recommendedList,
        );
        setRecomendationsData(ApiRespones.complete(updatedResponse));
      } catch (error) {
        setRecomendationsData(ApiRespones.error(error.toString()));
      } finally {
        isLoadingMore = false;
      }
    }
  }

  void clearComments() {
    commentsList.clear();
    _commentNextPageTokens.clear();
    _cachedCommentResponses.clear();
    _currentVideoIdForComments = null;
    setCommentData(ApiRespones.loading());
  }

  void clearVideos() {
    videoList.clear();
    _nextPageTokens.clear();
    _cachedResponses.clear();
    _currentQuery = null;
    setApiData(ApiRespones.loading());
  }

  // Clear shorts data
  void clearShorts() {
    shortsList.clear();
    _shortsNextPageTokens.clear();
    _cachedShortsResponses.clear();
    _currentShortsQuery = null;
    setShortsData(ApiRespones.loading());
  }

  bool shouldReloadVideos(String query) {
    return _currentQuery != query || videoList.isEmpty;
  }

  // Helper method to check if shorts should be reloaded
  bool shouldReloadShorts(String query) {
    return _currentShortsQuery != query || shortsList.isEmpty;
  }

  bool shouldReloadComments(String videoId) {
    return _currentVideoIdForComments != videoId || commentsList.isEmpty;
  }

  // New method to clear specific cache
  void clearCache(String query) {
    // super.clearCache(query);
    _cachedCommentResponses.clear();
    _commentNextPageTokens.clear();
    _cachedShortsResponses.remove(query);
    _shortsNextPageTokens.remove(query);
    _cachedResponses.remove(query);
    _cachedResponses.remove('related_$query');
    _nextPageTokens.remove(query);
    _nextPageTokens.remove('related_$query');
  }
}
