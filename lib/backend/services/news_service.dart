import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart';
import '../../frontend/models/news_item.dart';

class NewsService {
  // Base URL for ZNews
  static const String baseUrl = 'https://znews.vn';
  
  // Method to fetch news from ZNews
  Future<List<NewsItem>> fetchZNewsArticles({int page = 1, String category = ''}) async {
    try {
      // Construct the URL with pagination and category
      String pageUrl;
      
      if (category.isNotEmpty) {
        // Category specific URL
        pageUrl = page > 1 
            ? '$baseUrl/$category/trang-$page.html'
            : '$baseUrl/$category.html';
      } else {
        // General news URL
        pageUrl = page > 1 
            ? '$baseUrl/tin-tuc-thoi-su/trang-$page.html'
            : '$baseUrl/tin-tuc-thoi-su.html';
      }
          
      print('Fetching news from: $pageUrl');
      
      // Send HTTP request to ZNews
      final response = await http.get(Uri.parse(pageUrl));
      
      if (response.statusCode == 200) {
        // Parse the HTML content
        Document document = parser.parse(response.body);
        
        // Extract news articles
        List<Element> articleElements = document.querySelectorAll('article.article-item');
        
        // Convert HTML elements to NewsItem objects
        List<NewsItem> newsItems = [];
        
        for (var article in articleElements) {
          try {
            // Extract the title
            final titleElement = article.querySelector('.article-title a');
            final title = titleElement?.text.trim() ?? 'No title';
            
            // Skip articles with no title or "No title" 
            if (title.isEmpty || title == 'No title') {
              continue;
            }
            
            // Extract the URL
            final url = titleElement?.attributes['href'] ?? '';
            final articleUrl = url.startsWith('http') ? url : '$baseUrl$url';
            
            // Extract the image URL
            final imgElement = article.querySelector('.article-thumbnail img');
            String imageUrl = '';
            
            // Try multiple ways to get the image URL
            if (imgElement != null) {
              // Try src attribute first
              imageUrl = imgElement.attributes['src'] ?? '';
              
              // If src is empty, try data-src (common for lazy loading)
              if (imageUrl.isEmpty) {
                imageUrl = imgElement.attributes['data-src'] ?? '';
              }
              
              // If data-src is empty, try data-original (another lazy loading approach)
              if (imageUrl.isEmpty) {
                imageUrl = imgElement.attributes['data-original'] ?? '';
              }
              
              // Skip base64 encoded images or data URLs - these cause decoding errors
              if (imageUrl.contains('data:image') || imageUrl.contains('base64') || imageUrl.contains('blogspot')) {
                imageUrl = 'no_image';
              }
              
              // Handle relative URLs
              if (imageUrl.isNotEmpty && !imageUrl.startsWith('http') && imageUrl != 'no_image') {
                imageUrl = imageUrl.startsWith('/') ? 'https://znews.vn$imageUrl' : 'https://znews.vn/$imageUrl';
              }
            }
            
            // If all attempts failed, use special marker
            if (imageUrl.isEmpty) {
              imageUrl = 'no_image';
              // Only print if we have a valid title
              if (title != 'No title' && title.isNotEmpty) {
                print('No image for: ${title.length > 30 ? title.substring(0, 30) : title}...');
              }
            }
            
            // Extract the source (ZNews)
            const source = 'ZNews';
            
            // Extract time
            final timeElement = article.querySelector('.article-meta .friendly-time');
            final timeAgo = timeElement?.text ?? 'Vừa xong';
            
            // Extract category
            String newsCategory = 'Chung';
            final categoryElement = article.querySelector('.article-meta .category');
            if (categoryElement != null) {
              newsCategory = categoryElement.text;
            } else {
              // Try to determine category from URL
              if (articleUrl.contains('thoi-su')) {
                newsCategory = 'Thời sự';
              } else if (articleUrl.contains('the-gioi')) {
                newsCategory = 'Thế giới';
              } else if (articleUrl.contains('kinh-doanh')) {
                newsCategory = 'Kinh doanh';
              } else if (articleUrl.contains('giai-tri')) {
                newsCategory = 'Giải trí';
              } else if (articleUrl.contains('the-thao')) {
                newsCategory = 'Thể thao';
              } else if (articleUrl.contains('phap-luat')) {
                newsCategory = 'Pháp luật';
              } else if (articleUrl.contains('giao-duc')) {
                newsCategory = 'Giáo dục';
              } else if (articleUrl.contains('suc-khoe')) {
                newsCategory = 'Sức khỏe';
              } else if (articleUrl.contains('doi-song')) {
                newsCategory = 'Đời sống';
              } else if (articleUrl.contains('du-lich')) {
                newsCategory = 'Du lịch';
              }
            }
            
            // Parse publish date from timeAgo
            DateTime publishDate = DateTime.now();
            
            try {
              if (timeAgo.contains(':')) {
                // Today's article with time format "HH:MM"
                final timeParts = timeAgo.split(':');
                if (timeParts.length == 2) {
                  final hour = int.tryParse(timeParts[0].trim()) ?? 0;
                  final minute = int.tryParse(timeParts[1].trim()) ?? 0;
                  publishDate = DateTime(
                    publishDate.year,
                    publishDate.month,
                    publishDate.day,
                    hour,
                    minute,
                  );
                }
              } else if (timeAgo.contains('/')) {
                // Article with date format "DD/MM/YYYY"
                final dateParts = timeAgo.split('/');
                if (dateParts.length == 3) {
                  final day = int.tryParse(dateParts[0].trim()) ?? 1;
                  final month = int.tryParse(dateParts[1].trim()) ?? 1;
                  int year = int.tryParse(dateParts[2].trim()) ?? DateTime.now().year;
                  // Fix for 2-digit year format
                  if (year < 100) {
                    year += 2000;
                  }
                  publishDate = DateTime(year, month, day);
                }
              } else if (timeAgo.toLowerCase().contains('hôm qua')) {
                // Article from "Yesterday"
                publishDate = DateTime.now().subtract(const Duration(days: 1));
              } else if (timeAgo.toLowerCase().contains('giờ') || timeAgo.toLowerCase().contains('tiếng')) {
                // "X hours ago" format
                final regex = RegExp(r'(\d+)\s*(?:giờ|tiếng)');
                final match = regex.firstMatch(timeAgo);
                if (match != null) {
                  final hours = int.tryParse(match.group(1) ?? '0') ?? 0;
                  publishDate = DateTime.now().subtract(Duration(hours: hours));
                }
              } else if (timeAgo.toLowerCase().contains('ngày') || timeAgo.toLowerCase().contains('hôm')) {
                // "X days ago" format
                final regex = RegExp(r'(\d+)\s*(?:ngày|hôm)');
                final match = regex.firstMatch(timeAgo);
                if (match != null) {
                  final days = int.tryParse(match.group(1) ?? '0') ?? 0;
                  if (days > 0) {
                    publishDate = DateTime.now().subtract(Duration(days: days));
                  }
                }
              } else if (timeAgo.toLowerCase().contains('tuần')) {
                // "X weeks ago" format
                final regex = RegExp(r'(\d+)\s*tuần');
                final match = regex.firstMatch(timeAgo);
                if (match != null) {
                  final weeks = int.tryParse(match.group(1) ?? '0') ?? 0;
                  publishDate = DateTime.now().subtract(Duration(days: weeks * 7));
                }
              } else if (timeAgo.toLowerCase().contains('tháng')) {
                // "X months ago" format
                final regex = RegExp(r'(\d+)\s*tháng');
                final match = regex.firstMatch(timeAgo);
                if (match != null) {
                  final months = int.tryParse(match.group(1) ?? '0') ?? 0;
                  // Approximate months as 30 days
                  publishDate = DateTime.now().subtract(Duration(days: months * 30));
                }
              } else if (timeAgo.toLowerCase().contains('phút')) {
                // "X minutes ago" format - very recent
                publishDate = DateTime.now();
              } else if (timeAgo.toLowerCase().contains('vừa xong') || 
                         timeAgo.toLowerCase().contains('vừa')) {
                // "Just now" - very recent
                publishDate = DateTime.now();
              }
              
              // Normalize the date by removing seconds and milliseconds for more consistent comparison
              publishDate = DateTime(
                publishDate.year,
                publishDate.month,
                publishDate.day,
                publishDate.hour,
                publishDate.minute,
              );
              
              // Debug info
              print('Article: ${title.length > 40 ? title.substring(0, 40) : title}... | Date: ${publishDate.toString()} | Raw: $timeAgo');
            } catch (e) {
              print('Error parsing date from: $timeAgo - $e');
            }
            
            // Extract tags
            List<String> tags = ['tin tức'];
            final tagElements = article.querySelectorAll('.article-meta .tags a');
            if (tagElements.isNotEmpty) {
              tags = tagElements.map((tag) => tag.text).toList();
            } else {
              // Add category as a tag if no tags found
              tags.add(newsCategory);
            }
            
            // Add to the list
            newsItems.add(NewsItem(
              source: source,
              timeAgo: timeAgo,
              title: title,
              imageUrl: imageUrl,
              articleUrl: articleUrl,
              tags: tags,
              likes: 0,  // Default values
              comments: 0,
              category: newsCategory,
              publishDate: publishDate,
            ));
          } catch (e) {
            print('Error parsing article: $e');
            continue;
          }
        }
        
        print('Loaded ${newsItems.length} articles from page $page');
        return newsItems;
      } else {
        throw Exception('Failed to load news: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching news: $e');
      return [];
    }
  }
  
  // New method to fetch article content
  Future<Map<String, dynamic>> fetchArticleContent(String url) async {
    try {
      // Send HTTP request to article URL
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        // Parse the HTML content
        Document document = parser.parse(response.body);
        
        // Extract article title
        final titleElement = document.querySelector('h1.the-article-title');
        final title = titleElement?.text.trim() ?? '';
        
        // Extract article description/summary
        final descElement = document.querySelector('.the-article-summary');
        final description = descElement?.text.trim() ?? '';
        
        // Extract main article content
        final contentElement = document.querySelector('.the-article-body');
        List<Map<String, dynamic>> contentBlocks = [];
        
        if (contentElement != null) {
          // Process paragraphs
          final paragraphs = contentElement.querySelectorAll('p');
          for (var p in paragraphs) {
            contentBlocks.add({
              'type': 'paragraph',
              'content': p.text.trim(),
            });
          }
          
          // Process images
          final figures = contentElement.querySelectorAll('figure');
          for (var figure in figures) {
            final imgElement = figure.querySelector('img');
            final captionElement = figure.querySelector('figcaption');
            
            String imageUrl = '';
            if (imgElement != null) {
              // Try data-src first (lazy loading)
              imageUrl = imgElement.attributes['data-src'] ?? '';
              
              // If data-src is empty, try src
              if (imageUrl.isEmpty) {
                imageUrl = imgElement.attributes['src'] ?? '';
              }
              
              // Handle relative URLs
              if (imageUrl.isNotEmpty && !imageUrl.startsWith('http')) {
                imageUrl = imageUrl.startsWith('/') ? 'https://znews.vn$imageUrl' : 'https://znews.vn/$imageUrl';
              }
            }
            
            // Skip if no image found
            if (imageUrl.isEmpty) {
              continue;
            }
            
            contentBlocks.add({
              'type': 'image',
              'url': imageUrl,
              'caption': captionElement?.text.trim() ?? '',
            });
          }
        }
        
        // Extract author info
        final authorElement = document.querySelector('.author');
        final author = authorElement?.text.trim() ?? 'ZNews';
        
        // Extract publish time
        final timeElement = document.querySelector('.the-article-meta .the-article-publish');
        final publishTime = timeElement?.text.trim() ?? '';
        
        return {
          'title': title,
          'description': description,
          'content': contentBlocks,
          'author': author,
          'publishTime': publishTime,
          'url': url,
        };
      } else {
        throw Exception('Failed to load article content: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching article content: $e');
      throw Exception('Không thể tải nội dung bài viết');
    }
  }
  
  // Available categories in ZNews
  List<String> getCategories() {
    return [
      'thoi-su',
      'the-gioi',
      'kinh-doanh',
      'giai-tri',
      'the-thao',
      'phap-luat',
      'giao-duc',
      'suc-khoe',
      'doi-song',
      'du-lich',
    ];
  }
  
  // Get category display names
  Map<String, String> getCategoryNames() {
    return {
      'thoi-su': 'Thời sự',
      'the-gioi': 'Thế giới',
      'kinh-doanh': 'Kinh doanh',
      'giai-tri': 'Giải trí',
      'the-thao': 'Thể thao',
      'phap-luat': 'Pháp luật',
      'giao-duc': 'Giáo dục',
      'suc-khoe': 'Sức khỏe',
      'doi-song': 'Đời sống',
      'du-lich': 'Du lịch',
    };
  }
} 