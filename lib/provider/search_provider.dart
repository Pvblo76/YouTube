import 'dart:async';

import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:youtube/model/videos_model.dart';
import 'package:youtube/network/repository/home_api_repo.dart';
import 'package:youtube/network/response/api_respones.dart';

class SearchProvider extends ChangeNotifier {
  final HomeApiRepo repo = HomeApiRepo();
  final SharedPreferences _prefs;
  static const String _searchHistoryKey = 'search_history';
  static const int _maxHistoryItems = 10;

  // Debounce timer for search suggestions
  Timer? _debounceTimer;
  static const Duration _debounceDuration = Duration(milliseconds: 300);

  // Search results state
  ApiRespones<VideoListResponse> searchResponse = ApiRespones.loading();
  List<Video> searchResults = [];
  String? _currentSearchQuery;
  String? _nextPageToken;
  bool isLoadingMore = false;

  // Search suggestions state
  List<SearchSuggestion> searchSuggestions = [];
  bool isLoadingSuggestions = false;

  // Search history
  List<String> _searchHistory = [];

  SearchProvider(this._prefs) {
    _loadSearchHistory();
  }

  // Load search history from SharedPreferences
  void _loadSearchHistory() {
    final history = _prefs.getStringList(_searchHistoryKey);
    if (history != null) {
      _searchHistory = history;
      notifyListeners();
    }
  }

  // Save search history to SharedPreferences
  Future<void> _saveSearchHistory() async {
    await _prefs.setStringList(_searchHistoryKey, _searchHistory);
  }

  // Add search query to history
  void addToHistory(String query) {
    if (query.trim().isEmpty) return;

    // Remove if exists and add to front
    _searchHistory.remove(query);
    _searchHistory.insert(0, query);

    // Keep only last N items
    if (_searchHistory.length > _maxHistoryItems) {
      _searchHistory = _searchHistory.sublist(0, _maxHistoryItems);
    }

    _saveSearchHistory();
    notifyListeners();
  }

  // Remove item from history
  Future<void> removeFromHistory(String query) async {
    _searchHistory.remove(query);
    await _saveSearchHistory();
    notifyListeners();
  }

  // Clear entire search history
  Future<void> clearHistory() async {
    _searchHistory.clear();
    await _saveSearchHistory();
    notifyListeners();
  }

  // Get search suggestions with debouncing
  Future<void> getSuggestions(String query) async {
    // Cancel any pending debounce timer
    _debounceTimer?.cancel();

    if (query.trim().isEmpty) {
      // Show recent searches and trending searches when empty
      searchSuggestions = [
        ..._searchHistory.map((item) => SearchSuggestion(
              text: item,
              type: SuggestionType.history,
            )),
        // You could add trending searches here from your API
      ];
      notifyListeners();
      return;
    }

    // Set up debounce timer
    _debounceTimer = Timer(_debounceDuration, () async {
      isLoadingSuggestions = true;
      notifyListeners();

      try {
        // Get API suggestions
        final apiSuggestions = await repo.fetchSearchSuggestions(query);

        // Combine history matches and API suggestions
        final historyMatches = _searchHistory
            .where((item) => item.toLowerCase().contains(query.toLowerCase()))
            .map((item) => SearchSuggestion(
                  text: item,
                  type: SuggestionType.history,
                ));

        final apiMatches = apiSuggestions.map((suggestion) => SearchSuggestion(
              text: suggestion,
              type: SuggestionType.suggestion,
            ));

        searchSuggestions = [
          ...historyMatches,
          ...apiMatches
              .where((suggestion) => !_searchHistory.contains(suggestion.text))
        ];
      } catch (error) {
        // Fallback to history matches only
        searchSuggestions = _searchHistory
            .where((item) => item.toLowerCase().contains(query.toLowerCase()))
            .map((item) => SearchSuggestion(
                  text: item,
                  type: SuggestionType.history,
                ))
            .toList();
      }

      isLoadingSuggestions = false;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  // Perform search
  Future<void> search(String query, {bool forceRefresh = false}) async {
    if (query.trim().isEmpty) return;

    if (!forceRefresh && _currentSearchQuery == query) return;

    _currentSearchQuery = query;
    searchResponse = ApiRespones.loading();
    searchResults.clear();
    _nextPageToken = null;
    notifyListeners();

    try {
      final response = await repo.fetchRelatedVideosWithDetails(query);

      searchResults = response.items ?? [];
      _nextPageToken = response.nextPageToken;
      searchResponse = ApiRespones.complete(response);

      // Add to history only on successful search
      addToHistory(query);
    } catch (error) {
      searchResponse = ApiRespones.error(error.toString());
    }

    notifyListeners();
  }

  // Load more search results
  Future<void> loadMore() async {
    if (_nextPageToken == null ||
        isLoadingMore ||
        _currentSearchQuery == null) {
      return;
    }

    isLoadingMore = true;
    notifyListeners();

    try {
      final response = await repo.fetchRelatedVideosWithDetails(
        _currentSearchQuery!,
        pageToken: _nextPageToken,
      );

      if (response.items != null && response.items!.isNotEmpty) {
        searchResults.addAll(response.items!);
        _nextPageToken = response.nextPageToken;

        final updatedResponse = VideoListResponse(
          kind: response.kind,
          etag: response.etag,
          nextPageToken: _nextPageToken,
          pageInfo: response.pageInfo,
          items: searchResults,
        );

        searchResponse = ApiRespones.complete(updatedResponse);
      } else {
        _nextPageToken = null;
      }
    } catch (error) {
      searchResponse = ApiRespones.error(error.toString());
    } finally {
      isLoadingMore = false;
      notifyListeners();
    }
  }

  // Clear search results
  void clearSearch() {
    searchResults.clear();
    _currentSearchQuery = null;
    _nextPageToken = null;
    searchResponse = ApiRespones.loading();
    notifyListeners();
  }

  // Get current search state
  String? get currentQuery => _currentSearchQuery;
  List<String> get searchHistory => _searchHistory;
  bool get hasMoreResults => _nextPageToken != null;
}

enum SuggestionType {
  history,
  trending,
  suggestion,
}

class SearchSuggestion {
  final String text;
  final SuggestionType type;
  final String? thumbnail;

  SearchSuggestion({
    required this.text,
    required this.type,
    this.thumbnail,
  });
}
