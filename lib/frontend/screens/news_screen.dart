import 'dart:ui';
import 'package:flutter/material.dart';
// import 'package:url_launcher/url_launcher.dart'; flag = 0
import '../models/news_item.dart';
import '../../backend/services/news_service.dart';
import 'article_detail_screen.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen>
    with SingleTickerProviderStateMixin {
  final NewsService _newsService = NewsService();
  List<NewsItem> _newsItems = []; // Store currently loaded news
  late AnimationController _animationController;
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasError = false;
  String _errorMessage = '';
  int _currentPage = 1;
  bool _hasMoreData = true;
  final ScrollController _scrollController = ScrollController();
  String _selectedCategory = '';
  static const int _itemsPerPage = 10; // Load 10 items at a time

  // Get the list of available categories
  List<String> get _categories => _newsService.getCategories();
  Map<String, String> get _categoryNames => _newsService.getCategoryNames();

  @override
  void initState() {
    super.initState();
    _loadNews();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    // Removed scroll listener - using manual "Load More" button instead
  }

  // Removed scroll listener - using manual "Load More" button instead

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadNews() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
    });

    try {
      final news = await _newsService.fetchZNewsArticles(
        page: _currentPage,
        category: _selectedCategory,
        limit: _itemsPerPage,
      );

      setState(() {
        _newsItems = news;
        _isLoading = false;
        // Check if we got fewer items than expected (end of data)
        _hasMoreData = news.length >= _itemsPerPage;
        _animationController.forward(from: 0.0);
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _loadMoreNews() async {
    if (_isLoadingMore || !_hasMoreData) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      _currentPage++;
      final moreNews = await _newsService.fetchZNewsArticles(
        page: _currentPage,
        category: _selectedCategory,
        limit: _itemsPerPage,
      );

      setState(() {
        _newsItems.addAll(moreNews);
        // Check if we got fewer items than expected (end of data)
        _hasMoreData = moreNews.length >= _itemsPerPage;
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingMore = false;
        _currentPage--; // Revert page increment on error
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể tải thêm tin: ${e.toString()}'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  Future<void> _refreshNews() async {
    _currentPage = 1;
    _newsItems.clear();
    await _loadNews();
  }

  void _changeCategory(String category) {
    if (_selectedCategory != category) {
      setState(() {
        _selectedCategory = category;
        _currentPage = 1;
        _newsItems.clear();
      });
      _refreshNews();
    }
  }

  // Manual load more method
  void _loadMoreManually() {
    if (!_isLoadingMore && _hasMoreData) {
      _loadMoreNews();
    }
  }

  Future<void> _openArticle(String url) async {
    // Navigate to article detail screen instead of opening URL
    if (!mounted) return;

    // Find the news item with the given URL
    final newsItem = _newsItems.firstWhere(
      (item) => item.articleUrl == url,
      orElse: () => _newsItems.first,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ArticleDetailScreen(newsItem: newsItem),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: const Color(0xFF1a237e),
      appBar: AppBar(
        title: const Text(
          'Tin Tức Nóng',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white.withValues(alpha: 0.1),
        foregroundColor: Colors.white,
        elevation: 0,
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
              : _newsItems.isEmpty
              ? _buildEmptyState()
              : _buildNewsListView(),
        ),
      ),
    );
  }

  Widget _buildNewsListView() {
    return Column(
      children: [
        // Category tabs
        _buildCategoryTabs(),

        // News list
        Expanded(
          child: RefreshIndicator(
            onRefresh: _refreshNews,
            color: Colors.white,
            backgroundColor: const Color(0xFF283593),
            child: Column(
              children: [
                // Page indicator
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          'Trang $_currentPage',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                // News list
                Expanded(
                  child: _newsItems.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                          itemCount:
                              _newsItems.length +
                              (_hasMoreData || _isLoadingMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index < _newsItems.length) {
                              return _buildAnimatedNewsCard(
                                _newsItems[index],
                                index,
                              );
                            } else {
                              // Show loading indicator at the bottom
                              return _buildLoadMoreIndicator();
                            }
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryTabs() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.indigo.shade900.withValues(alpha: 0.3),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: [
            _buildCategoryTab('', 'Tất cả'),
            ..._categories.map(
              (category) => _buildCategoryTab(
                category,
                _categoryNames[category] ?? category,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryTab(String category, String displayName) {
    final isSelected = _selectedCategory == category;

    return GestureDetector(
      onTap: () => _changeCategory(category),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white
              : Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            displayName,
            style: TextStyle(
              color: isSelected ? Colors.indigo.shade900 : Colors.white,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 13,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadMoreIndicator() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: _isLoadingMore
            ? Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 12),
                    Text(
                      'Đang tải thêm tin tức...',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              )
            : _hasMoreData
            ? Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: ElevatedButton.icon(
                  onPressed: _loadMoreManually,
                  icon: const Icon(Icons.expand_more, size: 20),
                  label: const Text(
                    'Tải thêm tin tức',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.15),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    elevation: 0,
                  ),
                ),
              )
            : Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      color: Colors.white60,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Đã tải hết tin tức',
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildAnimatedNewsCard(NewsItem news, int index) {
    // Calculate animation delay based on current page and index
    // final int absoluteIndex = (_currentPage - 1) * 10 + index; flag = 2
    final int delayedIndex =
        index % 10; // Only animate the first 10 items per page

    final animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(
          (0.1 * delayedIndex).clamp(0.0, 1.0),
          (0.1 * delayedIndex + 0.5).clamp(0.0, 1.0),
          curve: Curves.easeOutCubic,
        ),
      ),
    );

    // Only apply animation to new items
    if (_currentPage > 1 && index >= _newsItems.length - 10) {
      // For newly loaded items
      return FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.5),
            end: Offset.zero,
          ).animate(animation),
          child: _buildNewsCard(news),
        ),
      );
    } else {
      // For already loaded items, no animation
      return _buildNewsCard(news);
    }
  }

  Widget _buildNewsCard(NewsItem news) {
    return GestureDetector(
      onTap: () => _openArticle(news.articleUrl),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: Colors.grey.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header với thời gian và category
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: Colors.orange.shade200,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      news.category,
                      style: TextStyle(
                        color: Colors.orange.shade700,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            news.timeAgo,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Title
              Text(
                news.title,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.blueGrey.shade800,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  height: 1.4,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 12),
              // Footer với tags và read more indicator
              Row(
                children: [
                  if (news.tags.isNotEmpty && news.tags.length > 1) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blueGrey.shade50,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.local_offer,
                            size: 10,
                            color: Colors.blueGrey.shade500,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '${news.tags.length} thẻ',
                            style: TextStyle(
                              color: Colors.blueGrey.shade600,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blueGrey.shade700,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Đọc thêm',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 10,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
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
            'Đang tải tin tức...',
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
            const Icon(
              Icons.cloud_off_rounded,
              color: Colors.white70,
              size: 60,
            ),
            const SizedBox(height: 20),
            const Text(
              'Lỗi kết nối',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Không thể tải dữ liệu: $error',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _refreshNews,
              icon: const Icon(Icons.refresh),
              label: const Text('Thử lại'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.black,
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.article_outlined, color: Colors.white70, size: 60),
          SizedBox(height: 20),
          Text(
            'Không có tin tức',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Hiện tại không có bài viết nào để hiển thị.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
