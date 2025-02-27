import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youtube/provider/search_provider.dart';
import 'package:youtube/theme/theme_manager.dart';
import 'package:youtube/widgets/routes/app_routes.dart';
import 'package:youtube/widgets/routes/routes.dart';

class YoutubeSearchDelegate extends SearchDelegate<String> {
  final BuildContext context;

  YoutubeSearchDelegate({required this.context})
      : super(
          searchFieldLabel: 'Search',
          searchFieldStyle: GoogleFonts.roboto(
            fontSize: 16,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black87,
          ),
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.search,
        );

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: Icon(
            Icons.clear,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey.shade400
                : Colors.grey.shade600,
          ),
          onPressed: () {
            query = '';
            showSuggestions(context);
          },
        ),
      if (query.isEmpty)
        IconButton(
          icon: const Icon(Icons.mic),
          onPressed: () {
            // Implement voice search functionality
          },
        ),
      const SizedBox(width: 8),
    ];
  }

  @override
  ThemeData appBarTheme(BuildContext context) {
    final theme = Theme.of(context);
    final themes = Provider.of<YouTubeTheme>(context);
    final isDark = themes.isDarkMode;

    return theme.copyWith(
      appBarTheme: AppBarTheme(
        surfaceTintColor: Colors.transparent,
        backgroundColor: themes.scaffoldColor,
        elevation: 0,
        iconTheme: IconThemeData(
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: GoogleFonts.roboto(
          color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
          fontSize: 16,
        ),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none),
        filled: true,
        fillColor: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      ),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.trim().isEmpty) return const SizedBox();

    close(context, query); // Close the search delegate before navigating

    Future.delayed(Duration.zero, () {
      Navigator.pushNamed(context, RouteNames.searchview,
          arguments: SearchArgs(query: query));
    });

    return const Center(child: CircularProgressIndicator());
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final searchProvider = Provider.of<SearchProvider>(context, listen: false);
    if (query.isNotEmpty) {
      print("Current Query : ${query}");
      searchProvider.getSuggestions(query);
    }
    final theme = Provider.of<YouTubeTheme>(context);
    final isDark = theme.isDarkMode;

    return Container(
      color: theme.scaffoldColor,
      child: Consumer<SearchProvider>(
        builder: (context, searchProvider, _) {
          if (searchProvider.isLoadingSuggestions) {
            return Center(
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isDark ? Colors.grey.shade700 : Colors.black54,
                ),
              ),
            );
          }

          return ListView.builder(
            itemCount: searchProvider.searchSuggestions.length,
            itemBuilder: (context, index) {
              var suggestion = searchProvider.searchSuggestions[index];
              return ListTile(
                leading: Icon(
                  suggestion.type == SuggestionType.history
                      ? Icons.history
                      : suggestion.type == SuggestionType.trending
                          ? Icons.trending_up
                          : Icons.search,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
                title: Text(
                  suggestion.text,
                  style: GoogleFonts.roboto(
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.north_west),
                  onPressed: () {
                    query = suggestion.text;
                  },
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
                onTap: () {
                  query = suggestion.text;
                  showResults(context);
                },
              );
            },
          );
        },
      ),
    );
  }
}
