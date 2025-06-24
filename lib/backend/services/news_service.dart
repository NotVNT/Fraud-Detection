import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart';
import '../../frontend/models/news_item.dart';

class NewsService {
  // Base URL for ZNews
  static const String baseUrl = 'https://znews.vn';
  
  // Method to fetch news from ZNews
  Future<List<NewsItem>> fetchZNewsArticles() async {
    try {
      // Send HTTP request to ZNews
      final response = await http.get(Uri.parse('$baseUrl/tin-tuc-thoi-su.html'));
      
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
            final title = titleElement?.text ?? 'No title';
            
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
              
              // Handle relative URLs
              if (imageUrl.isNotEmpty && !imageUrl.startsWith('http')) {
                imageUrl = imageUrl.startsWith('/') ? 'https://znews.vn$imageUrl' : 'https://znews.vn/$imageUrl';
              }
            }
            
            // If all attempts failed, use placeholder
            if (imageUrl.isEmpty) {
              imageUrl = 'https://via.placeholder.com/400x200?text=No+Image';
              print('No image found for article: $title');
            }
            
            // Extract the source (ZNews)
            const source = 'ZNews';
            
            // Extract time
            final timeElement = article.querySelector('.article-meta .friendly-time');
            final timeAgo = timeElement?.text ?? 'Vừa xong';
            
            // Add to the list
            newsItems.add(NewsItem(
              source: source,
              timeAgo: timeAgo,
              title: title,
              imageUrl: imageUrl,
              articleUrl: articleUrl,
              tags: ['tin tức'], // Default tag
              likes: 0,  // Default values
              comments: 0,
            ));
            
            // Limit to 10 articles
            if (newsItems.length >= 10) break;
            
          } catch (e) {
            print('Error parsing article: $e');
            continue;
          }
        }
        
        return newsItems;
      } else {
        throw Exception('Failed to load news: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching news: $e');
      return [];
    }
  }
} 