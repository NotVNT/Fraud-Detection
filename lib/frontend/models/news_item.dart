class NewsItem {
  final String source;
  final String timeAgo;
  final String title;
  final String imageUrl;
  final String articleUrl;
  final List<String> tags;
  final int likes;
  final int comments;
  final String category;
  final DateTime publishDate;

  NewsItem({
    required this.source,
    required this.timeAgo,
    required this.title,
    required this.imageUrl,
    required this.articleUrl,
    required this.tags,
    required this.likes,
    required this.comments,
    this.category = 'Chung',
    DateTime? publishDate,
  }) : this.publishDate = publishDate ?? DateTime.now();
} 