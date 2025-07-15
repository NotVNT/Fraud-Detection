import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../backend/services/news_service.dart';
import '../models/news_item.dart';

class ArticleDetailScreen extends StatefulWidget {
  final NewsItem newsItem;

  const ArticleDetailScreen({required this.newsItem, super.key});

  @override
  State<ArticleDetailScreen> createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen> {
  final NewsService _newsService = NewsService();
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  Map<String, dynamic> _articleContent = {};

  @override
  void initState() {
    super.initState();
    _loadArticleContent();
  }

  Future<void> _loadArticleContent() async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });

      final content = await _newsService.fetchArticleContent(
        widget.newsItem.articleUrl,
      );

      setState(() {
        _articleContent = content;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _openOriginalArticle() async {
    final Uri uri = Uri.parse(widget.newsItem.articleUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không thể mở bài viết gốc'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: const Color(0xFF1a237e),
      appBar: AppBar(
        title: Text(
          widget.newsItem.source,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white.withValues(alpha: 0.1),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_browser),
            onPressed: _openOriginalArticle,
            tooltip: 'Mở bài viết gốc',
          ),
        ],
        flexibleSpace: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.transparent),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1a237e), // Indigo 900
              Color(0xFF283593), // Indigo 700
              Color(0xFF3f51b5), // Indigo 500
            ],
          ),
        ),
        child: SafeArea(
          child: _isLoading
              ? _buildLoadingState()
              : _hasError
              ? _buildErrorState(_errorMessage)
              : _buildArticleContent(),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.white),
          SizedBox(height: 20),
          Text(
            'Đang tải nội dung bài viết...',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.white70, size: 60),
            const SizedBox(height: 20),
            const Text(
              'Không thể tải bài viết',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Lỗi: $error',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _loadArticleContent,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Thử lại'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: _openOriginalArticle,
                  icon: const Icon(Icons.open_in_browser),
                  label: const Text('Mở bài gốc'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.blueAccent,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArticleContent() {
    // If no content loaded yet
    if (_articleContent.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.article_outlined,
              color: Colors.white.withValues(alpha: 0.6),
              size: 60,
            ),
            const SizedBox(height: 16),
            const Text(
              'Không có nội dung',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final title = _articleContent['title'] ?? widget.newsItem.title;
    final description = _articleContent['description'] ?? '';
    final List<Map<String, dynamic>> content = List<Map<String, dynamic>>.from(
      _articleContent['content'] ?? [],
    );
    final author = _articleContent['author'] ?? '';
    final publishTime =
        _articleContent['publishTime'] ?? widget.newsItem.timeAgo;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Featured image
          if (widget.newsItem.imageUrl != 'no_image')
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: CachedNetworkImage(
                imageUrl: widget.newsItem.imageUrl,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  height: 200,
                  color: Colors.indigo.shade800,
                  child: const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  height: 200,
                  color: Colors.indigo.shade800,
                  child: const Icon(
                    Icons.broken_image,
                    color: Colors.white70,
                    size: 40,
                  ),
                ),
              ),
            ),

          // Category and time
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    widget.newsItem.category.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    publishTime,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          // Title
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                height: 1.3,
              ),
            ),
          ),

          // Description
          if (description.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(
                description,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  fontStyle: FontStyle.italic,
                  height: 1.5,
                ),
              ),
            ),

          // Divider
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Container(
              height: 1,
              color: Colors.white.withValues(alpha: 0.1),
            ),
          ),

          // Content blocks
          ...content.map((block) {
            if (block['type'] == 'paragraph') {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  block['content'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    height: 1.6,
                  ),
                ),
              );
            } else if (block['type'] == 'image') {
              return Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CachedNetworkImage(
                        imageUrl: block['url'],
                        width: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          height: 200,
                          color: Colors.indigo.shade800,
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          height: 200,
                          color: Colors.indigo.shade800,
                          child: const Icon(
                            Icons.broken_image,
                            color: Colors.white70,
                            size: 40,
                          ),
                        ),
                      ),
                    ),
                    if ((block['caption'] ?? '').isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          block['caption'],
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }
            return const SizedBox();
          }).toList(),

          // Author
          if (author.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 24, bottom: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Icon(Icons.person, size: 14, color: Colors.white70),
                  const SizedBox(width: 6),
                  Text(
                    author,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),

          // Source link
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(top: 24),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Nguồn bài viết:',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 4),
                InkWell(
                  onTap: _openOriginalArticle,
                  child: Text(
                    widget.newsItem.articleUrl,
                    style: const TextStyle(
                      color: Colors.lightBlueAccent,
                      decoration: TextDecoration.underline,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
