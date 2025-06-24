class NewsItem {
  final String source;
  final String timeAgo;
  final String title;
  final String imageUrl;
  final List<String> tags;
  final int likes;
  final int comments;
  final String articleUrl;

  NewsItem({
    required this.source,
    required this.timeAgo,
    required this.title,
    required this.imageUrl,
    required this.tags,
    required this.likes,
    required this.comments,
    required this.articleUrl,
  });
} 