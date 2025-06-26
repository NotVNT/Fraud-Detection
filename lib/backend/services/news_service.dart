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
                print('No image for: ${title.substring(0, title.length > 30 ? 30 : title.length)}...');
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
                  final year = int.tryParse(dateParts[2].trim()) ?? DateTime.now().year;
                  publishDate = DateTime(year, month, day);
                }
              } else if (timeAgo.toLowerCase().contains('hôm qua')) {
                // Bài đăng "Hôm qua"
                publishDate = DateTime.now().subtract(const Duration(days: 1));
              } else if (timeAgo.toLowerCase().contains('ngày')) {
                // Bài đăng trong khoảng "X ngày trước"
                final parts = timeAgo.split(' ');
                for (int i = 0; i < parts.length; i++) {
                  if (parts[i].toLowerCase() == 'ngày' && i > 0) {
                    final days = int.tryParse(parts[i-1]) ?? 0;
                    if (days > 0) {
                      publishDate = DateTime.now().subtract(Duration(days: days));
                      break;
                    }
                  }
                }
              }
              
              // Debug info
              print('Article: ${title.substring(0, title.length > 40 ? 40 : title.length)}... | Date: ${publishDate.toString()} | Raw: $timeAgo');
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