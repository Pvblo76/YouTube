import 'package:youtube/model/channel.dart';
import 'package:youtube/model/comments_model.dart';
import 'package:http/http.dart' as http;
import 'package:youtube/model/videos_model.dart';

import 'package:youtube/network/exceptions/app_exceptions.dart';
import 'package:youtube/network/services/network_api_services.dart';

class HomeApiRepo {
  final response = NetworkApiServices();
// Fetch Video for spcific Channel
  Future<VideoListResponse> getVideos(String channelId,
      {String? pageToken}) async {
    try {
      // Step 1: Fetch related video IDs (first API call)
      var searchEndpoint = Uri.https(
        'www.googleapis.com',
        '/youtube/v3/search',
        {
          'key': 'AIzaSyCj7m7PN6Sf1hcXge8N5iK3SExoWsRmj-k',
          'part': 'snippet',
          'type': 'video',
          'channelId': channelId,
          'maxResults': '10', // Adjust maxResults as needed
          if (pageToken != null) 'pageToken': pageToken,
          'order': 'viewCount', // Sort by popularity
        },
      );

      print(searchEndpoint);
      dynamic searchResponse =
          await response.getApiResponse(searchEndpoint.toString());

      if (searchResponse == null || !searchResponse.containsKey('items')) {
        throw FetchDataExceptions(
            'Failed to load related videos or no items found');
      }

      // Extract video IDs
      List<String> videoIds = [];
      for (var item in searchResponse['items']) {
        if (item['id'] != null && item['id']['videoId'] != null) {
          videoIds.add(item['id']['videoId']);
        }
      }

      // Retrieve the nextPageToken from the search response
      String? nextPageToken = searchResponse['nextPageToken'];

      if (videoIds.isEmpty) {
        throw FetchDataExceptions('No related video IDs found');
      }

      // Step 2: Fetch video details (second API call)
      var videoDetailsEndpoint = Uri.https(
        'youtube.googleapis.com',
        '/youtube/v3/videos',
        {
          'part': 'snippet,contentDetails,statistics',
          'fields':
              'items(id,snippet(title,channelTitle,channelId,thumbnails,publishedAt,description),statistics(viewCount,likeCount,commentCount),contentDetails(duration))',
          'id': videoIds.join(','),
          'key': 'AIzaSyCj7m7PN6Sf1hcXge8N5iK3SExoWsRmj-k',
        },
      );
      print(videoDetailsEndpoint);

      dynamic detailsResponse =
          await response.getApiResponse(videoDetailsEndpoint.toString());

      if (detailsResponse == null || !detailsResponse.containsKey('items')) {
        throw FetchDataExceptions('Failed to load video details');
      }

      // Process and return the VideoListResponse
      VideoListResponse videoList = VideoListResponse.fromJson(detailsResponse);
      videoList.nextPageToken = nextPageToken; // Set the token for pagination

      return videoList;
    } catch (e) {
      print("Exception in fetchRelatedVideosWithDetails: ${e.toString()}");
      throw FetchDataExceptions(e.toString());
    }
  }

  // Fetch comments for currently playing vdieo
  Future<CommentThreadListResponse> getComments(String videoId,
      {String? pageToken}) async {
    try {
      var commentsEndpoint = Uri.https(
        'www.googleapis.com',
        '/youtube/v3/commentThreads',
        {
          'key': 'AIzaSyCj7m7PN6Sf1hcXge8N5iK3SExoWsRmj-k',
          'part': 'snippet,replies',
          'videoId': videoId,
          'maxResults': '10',
          if (pageToken != null) 'pageToken': pageToken,
          'order': 'relevance', // Default to 'relevance' for top comments
        },
      );

      print('Comments endpoint: $commentsEndpoint');

      dynamic commentResponse =
          await response.getApiResponse(commentsEndpoint.toString());

      if (commentResponse == null || !commentResponse.containsKey('items')) {
        throw FetchDataExceptions(
            'Failed to load comments or no comments found');
      }

      // Create CommentListResponse object
      CommentThreadListResponse commentList =
          CommentThreadListResponse.fromJson(commentResponse);
      return commentList;
    } catch (e) {
      print("Exception in getComments: ${e.toString()}");
      throw FetchDataExceptions(e.toString());
    }
  }

  // Home Feed video list...

  Future<VideoListResponse> fetchRelatedVideosWithDetails(String query,
      {String? pageToken}) async {
    try {
      // Step 1: Fetch related video IDs
      var searchEndpoint = Uri.https(
        'www.googleapis.com',
        '/youtube/v3/search',
        {
          'key': 'AIzaSyCj7m7PN6Sf1hcXge8N5iK3SExoWsRmj-k',
          'part': 'snippet',
          'type': 'video',
          'q': query,
          'maxResults': '10',
          if (pageToken != null) 'pageToken': pageToken,
        },
      );

      dynamic searchResponse =
          await response.getApiResponse(searchEndpoint.toString());

      if (searchResponse == null || !searchResponse.containsKey('items')) {
        throw FetchDataExceptions(
            'Failed to load related videos or no items found');
      }

      // Extract video IDs and channel IDs
      List<String> videoIds = [];
      Set<String> channelIds = {}; // Using Set to avoid duplicates
      for (var item in searchResponse['items']) {
        if (item['id'] != null && item['id']['videoId'] != null) {
          videoIds.add(item['id']['videoId']);
        }
        if (item['snippet'] != null && item['snippet']['channelId'] != null) {
          channelIds.add(item['snippet']['channelId']);
        }
      }

      String? nextPageToken = searchResponse['nextPageToken'];

      if (videoIds.isEmpty) {
        throw FetchDataExceptions('No related video IDs found');
      }

      // Step 2: Fetch video details
      var videoDetailsEndpoint = Uri.https(
        'youtube.googleapis.com',
        '/youtube/v3/videos',
        {
          'part': 'snippet,contentDetails,statistics',
          'fields':
              'items(id,snippet(title,channelTitle,channelId,thumbnails,publishedAt,description),statistics(viewCount,likeCount,commentCount),contentDetails(duration))',
          'id': videoIds.join(','),
          'key': 'AIzaSyCj7m7PN6Sf1hcXge8N5iK3SExoWsRmj-k',
        },
      );
      print(videoDetailsEndpoint);
      dynamic detailsResponse =
          await response.getApiResponse(videoDetailsEndpoint.toString());

      if (detailsResponse == null || !detailsResponse.containsKey('items')) {
        throw FetchDataExceptions('Failed to load video details');
      }

      // Step 3: Fetch channel details
      var channelDetailsEndpoint = Uri.https(
        'youtube.googleapis.com',
        '/youtube/v3/channels',
        {
          'part': 'snippet,statistics',
          'id': channelIds.join(','),
          'key': 'AIzaSyCj7m7PN6Sf1hcXge8N5iK3SExoWsRmj-k',
        },
      );

      dynamic channelResponse =
          await response.getApiResponse(channelDetailsEndpoint.toString());

      if (channelResponse != null && channelResponse.containsKey('items')) {
        // Create a map of channel details for quick lookup
        Map<String, dynamic> channelDetailsMap = {};
        for (var channel in channelResponse['items']) {
          channelDetailsMap[channel['id']] = channel;
        }

        // Add channel details to video items
        for (var video in detailsResponse['items']) {
          String? channelId = video['snippet']['channelId'];
          if (channelId != null && channelDetailsMap.containsKey(channelId)) {
            video['channelDetails'] = channelDetailsMap[channelId];
          }
        }
      }

      // Process and return the VideoListResponse
      VideoListResponse videoList = VideoListResponse.fromJson(detailsResponse);
      videoList.nextPageToken = nextPageToken;

      return videoList;
    } catch (e) {
      print("Exception in fetchRelatedVideosWithDetails: ${e.toString()}");
      throw FetchDataExceptions(e.toString());
    }
  }
  // Fetching Short videos...

  Future<VideoListResponse> getShorts(String query, {String? pageToken}) async {
    try {
      // Step 1: Fetch related video IDs
      var shortsEndpoint = Uri.https(
        'www.googleapis.com',
        '/youtube/v3/search',
        {
          'key': 'AIzaSyCj7m7PN6Sf1hcXge8N5iK3SExoWsRmj-k',
          'part': 'snippet',
          'type': 'video',
          'q': query,
          'videoDuration': 'short', // Fetch short videos
          'order': 'viewCount', // Sort by most viewed (popular)

          'maxResults': '10', // Number of results per page

          if (pageToken != null) 'pageToken': pageToken,
        },
      );

      dynamic searchResponse =
          await response.getApiResponse(shortsEndpoint.toString());

      if (searchResponse == null || !searchResponse.containsKey('items')) {
        throw FetchDataExceptions(
            'Failed to load related videos or no items found');
      }

      // Extract video IDs and channel IDs
      List<String> videoIds = [];
      Set<String> channelIds = {}; // Using Set to avoid duplicates
      for (var item in searchResponse['items']) {
        if (item['id'] != null && item['id']['videoId'] != null) {
          videoIds.add(item['id']['videoId']);
        }
        if (item['snippet'] != null && item['snippet']['channelId'] != null) {
          channelIds.add(item['snippet']['channelId']);
        }
      }

      String? nextPageToken = searchResponse['nextPageToken'];

      if (videoIds.isEmpty) {
        throw FetchDataExceptions('No related video IDs found');
      }

      // Step 2: Fetch video details
      var videoDetailsEndpoint = Uri.https(
        'youtube.googleapis.com',
        '/youtube/v3/videos',
        {
          'part': 'snippet,contentDetails,statistics',
          'fields':
              'items(id,snippet(title,channelTitle,channelId,thumbnails,publishedAt,description),statistics(viewCount,likeCount,commentCount),contentDetails(duration))',
          'id': videoIds.join(','),
          'key': 'AIzaSyCj7m7PN6Sf1hcXge8N5iK3SExoWsRmj-k',
        },
      );
      print("Short Ulr : ${videoDetailsEndpoint}");

      dynamic detailsResponse =
          await response.getApiResponse(videoDetailsEndpoint.toString());

      if (detailsResponse == null || !detailsResponse.containsKey('items')) {
        throw FetchDataExceptions('Failed to load video details');
      }

      // Step 3: Fetch channel details
      var channelDetailsEndpoint = Uri.https(
        'youtube.googleapis.com',
        '/youtube/v3/channels',
        {
          'part': 'snippet,statistics',
          'id': channelIds.join(','),
          'key': 'AIzaSyCj7m7PN6Sf1hcXge8N5iK3SExoWsRmj-k',
        },
      );

      dynamic channelResponse =
          await response.getApiResponse(channelDetailsEndpoint.toString());

      if (channelResponse != null && channelResponse.containsKey('items')) {
        // Create a map of channel details for quick lookup
        Map<String, dynamic> channelDetailsMap = {};
        for (var channel in channelResponse['items']) {
          channelDetailsMap[channel['id']] = channel;
        }

        // Add channel details to video items
        for (var video in detailsResponse['items']) {
          String? channelId = video['snippet']['channelId'];
          if (channelId != null && channelDetailsMap.containsKey(channelId)) {
            video['channelDetails'] = channelDetailsMap[channelId];
          }
        }
      }

      // Process and return the VideoListResponse
      VideoListResponse videoList = VideoListResponse.fromJson(detailsResponse);
      videoList.nextPageToken = nextPageToken;

      return videoList;
    } catch (e) {
      print("Exception in fetchRelatedVideosWithDetails: ${e.toString()}");
      throw FetchDataExceptions(e.toString());
    }
  }

  Future<VideoListResponse> getCatVideos(String id, {String? pageToken}) async {
    var endpoint =
        "https://www.googleapis.com/youtube/v3/videos?key=AIzaSyCj7m7PN6Sf1hcXge8N5iK3SExoWsRmj-k&part=snippet,contentDetails,statistics&chart=mostPopular&type=&videoCategoryId=$id&regionCode=PK&type=video&maxResults=25";

    // Append the pageToken if it exists
    if (pageToken != null && pageToken.isNotEmpty) {
      endpoint += "&pageToken=$pageToken";
    }

    print(endpoint); // Debug print to check the endpoint with pageToken

    try {
      // Fetch the API response
      dynamic result = await response.getApiResponse(endpoint.toString());

      // Ensure the result is not null and is a valid Map
      if (result != null && result is Map<String, dynamic>) {
        //   print('API Response: $result');

        // Check if items exist in the response and process them accordingly
        if (result.containsKey('items') && result['items'] != null) {
          // Check if the nextPageToken exists
          if (result.containsKey('nextPageToken')) {
            String nextPageToken = result['nextPageToken'];
            print("Next Page Token: $nextPageToken");
            // You can store this token or return it for future API requests
            // For example, you could pass it back in the response or store it in a class-level variable
          }

          // Process and return the VideoListResponse
          return VideoListResponse.fromJson(result);
        } else {
          throw FetchDataExceptions('No items found in the response');
        }
      } else {
        throw FetchDataExceptions('Invalid response format');
      }
    } catch (e) {
      // Print and throw exceptions for debugging
      print("Exception in HomeApiRepo: ${e.toString()}");
      throw FetchDataExceptions(e.toString());
    }
  }

  // fetching informations for specific channel...
  Future<Channel> getChannel(String id) async {
    var endpoint =
        "https://www.googleapis.com/youtube/v3/channels?key=AIzaSyCj7m7PN6Sf1hcXge8N5iK3SExoWsRmj-k"
        "&part=snippet,contentDetails,statistics,brandingSettings&id=$id";

    try {
      // Fetch the API response
      dynamic result = await response.getApiResponse(endpoint);
      print(endpoint); // Debug print to check the endpoint
      // Ensure the response is valid and has expected structure
      if (result != null &&
          result is Map<String, dynamic> &&
          result['items'] != null) {
        final List<dynamic> items = result['items'];
        if (items.isNotEmpty) {
          return Channel.fromJson(items[0]); // Parse first item if it exists
        } else {
          throw FetchDataExceptions('Channel not found in response.');
        }
      } else {
        throw FetchDataExceptions('Invalid response format from YouTube API.');
      }
    } catch (e) {
      // Log and throw the error for further handling
      print("Exception in getChannel: ${e.toString()}");
      throw FetchDataExceptions(
          'Failed to fetch channel data: ${e.toString()}');
    }
  }

  Future<List<String>> fetchSearchSuggestions(String query) async {
    try {
      final response = await http.get(Uri.parse(
        'https://corsproxy.io/?https://clients1.google.com/complete/search?client=youtube&gs_ri=youtube&ds=yt&q=$query',
      ));

      if (response.statusCode == 200) {
        final List<String> suggestions = [];
        final data = response.body;

        // Split the response and extract suggestions
        data.split('[').forEach((part) {
          final matches = RegExp(r'"([^"]*)"').firstMatch(part);
          if (matches != null && matches.group(1) != null) {
            // Skip the first suggestion as it's the query itself
            if (suggestions.isEmpty && matches.group(1) == query) {
              return;
            }
            suggestions.add(matches.group(1)!);
          }
        });

        return suggestions;
      } else {
        throw Exception('Failed to load suggestions');
      }
    } catch (e) {
      throw Exception('Error fetching suggestions: $e');
    }
  }
}
