class Categories {
  static Map<String, String?> categoryMap = {
    'All': null, // Null means "all" categories (no filter)
    'Trending': null, // Handled by YouTube Trending API, not a category
    'Mobile app development': '20',
    'News': '25', // News & Politics
    'Coding': '28', // Science & Technology
    '8K resolution': '2',
    'Technology': '28', // Science & Technology
    'Entertainment': '24', // Travel & Events
    'Health & Fitness': '17', // Sports (closest match for health & fitness)
    'Music': '10', // Music
    '4K resolution': '3',
    'Thrillers': '9',
    'Gaming': '20', // Gaming
    'Movies & TV Shows': '24', // Entertainment
    'Sports': '17', // Sports
    'Fashion & Beauty': '26', // Howto & Style
    'Comedy': '23', // Comedy
    'Food': '26', // Howto & Style (Food falls under this)
    'Science & Nature': '28', // Science & Technology
  };
}

class ChannelTabs {
  static Map<String, String> tabs = {
    "Home": "1",
    "Videos": "2",
    "Playlists": "3",
    "Community": "4",
  };
}
