import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/news_item.dart';
import '../../backend/services/news_service.dart';
import 'package:intl/intl.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> with SingleTickerProviderStateMixin {
  final NewsService _newsService = NewsService();
  List<NewsItem> _newsItems = [];
  List<NewsItem> _filteredNewsItems = [];
  late AnimationController _animationController;
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasError = false;
  String _errorMessage = '';
  int _currentPage = 1;
  bool _hasMoreData = true;
  final ScrollController _scrollController = ScrollController();
  String _selectedCategory = '';
  String _dateFilter = 'all'; // 'all', 'today', 'week', 'month'
  
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
    
    // Add scroll listener for pagination
    _scrollController.addListener(_scrollListener);
    
    // Initialize filtered items
    _filteredNewsItems = [];
  }
  
  void _scrollListener() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.8 &&
        !_isLoading && 
        !_isLoadingMore && 
        _hasMoreData) {
      _loadMoreNews();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
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
      );
      
      setState(() {
        _newsItems = news;
        _debugPrintArticleDates(); // Debug dates
        _applyFilters();
        _isLoading = false;
        _hasMoreData = news.isNotEmpty;
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
  
  // For debugging dates
  void _debugPrintArticleDates() {
    if (_newsItems.isEmpty) {
      print('No articles to debug');
      return;
    }
    
    print('===== DEBUG DATES =====');
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekAgo = today.subtract(const Duration(days: 6));
    final monthAgo = today.subtract(const Duration(days: 29));
    
    int todayCount = 0;
    int weekCount = 0;
    int monthCount = 0;
    
    for (var item in _newsItems) {
      final itemDate = DateTime(
        item.publishDate.year,
        item.publishDate.month,
        item.publishDate.day,
      );
      
      if (itemDate.isAtSameMomentAs(today)) {
        todayCount++;
      }
      
      if (!itemDate.isBefore(weekAgo)) {
        weekCount++;
      }
      
      if (!itemDate.isBefore(monthAgo)) {
        monthCount++;
      }
    }
    
    print('Today count: $todayCount articles');
    print('Week count: $weekCount articles');
    print('Month count: $monthCount articles');
    print('Total articles: ${_newsItems.length}');
    print('=======================');
  }

  void _applyFilters() {
    List<NewsItem> filtered = List.from(_newsItems);
    
    // Apply date filter
    if (_dateFilter != 'all') {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      
      filtered = filtered.where((item) {
        // Đảm bảo ngày của item là đối tượng DateTime hợp lệ
        if (item.publishDate == null) {
          return false;
        }
        
        final publishDate = item.publishDate;
        final itemDate = DateTime(publishDate.year, publishDate.month, publishDate.day);
        
        switch (_dateFilter) {
          case 'today':
            // Chỉ lấy bài đăng trong ngày hôm nay
            return itemDate.isAtSameMomentAs(today);
            
          case 'week':
            // 7 ngày gần nhất kể từ hôm nay trở về trước
            final weekAgo = today.subtract(const Duration(days: 6)); 
            
            // So sánh ngày tháng
            return !itemDate.isBefore(weekAgo);
            
          case 'month':
            // 30 ngày gần nhất kể từ hôm nay trở về trước
            final monthAgo = today.subtract(const Duration(days: 29)); 
            
            // So sánh ngày tháng
            return !itemDate.isBefore(monthAgo);
            
          default:
            return true;
        }
      }).toList();
    }
    
    setState(() {
      _filteredNewsItems = filtered;
      print('Applied filters: ${_filteredNewsItems.length} items remaining from ${_newsItems.length}');
    });
  }
  
  Future<void> _loadMoreNews() async {
    if (_isLoadingMore) return;
    
    setState(() {
      _isLoadingMore = true;
    });
    
    try {
      _currentPage++;
      final moreNews = await _newsService.fetchZNewsArticles(
        page: _currentPage,
        category: _selectedCategory,
      );
      
      setState(() {
        if (moreNews.isNotEmpty) {
          _newsItems.addAll(moreNews);
          _applyFilters();
          _hasMoreData = moreNews.length >= 5; // Assuming 5 is the page size
        } else {
          _hasMoreData = false;
        }
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
    await _loadNews();
  }
  
  void _changeCategory(String category) {
    if (_selectedCategory != category) {
      setState(() {
        _selectedCategory = category;
        _currentPage = 1;
      });
      _refreshNews();
    }
  }
  
  void _changeDateFilter(String filter) {
    if (_dateFilter != filter) {
      setState(() {
        _dateFilter = filter;
      });
      _applyFilters();
    }
  }

  Future<void> _openArticle(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không thể mở bài viết'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
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
        title: const Text('Tin Tức Nóng', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white.withOpacity(0.1),
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
          child: _isLoading ? _buildLoadingState() : 
                 _hasError ? _buildErrorState(_errorMessage) :
                 _newsItems.isEmpty ? _buildEmptyState() : 
                 _buildNewsListView(),
        ),
      ),
    );
  }

  Widget _buildNewsListView() {
    return Column(
      children: [
        // Category tabs
        _buildCategoryTabs(),
        
        // Date filter
        _buildDateFilter(),
        
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
                      Flexible(
                        child: Text(
                          '${_filteredNewsItems.length} bài viết',
                          style: const TextStyle(
                            color: Colors.white70,
                          ),
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ],
                  ),
                ),
                // News list
                Expanded(
                  child: _filteredNewsItems.isEmpty 
                      ? _dateFilter != 'all'
                          ? _buildNoFilterMatchState()
                          : _newsItems.isEmpty 
                              ? _buildEmptyState()
                              : _buildNoFilterMatchState()
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                          itemCount: _filteredNewsItems.length + (_isLoadingMore || _hasMoreData ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index < _filteredNewsItems.length) {
                              return _buildAnimatedNewsCard(_filteredNewsItems[index], index);
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
        color: Colors.indigo.shade900.withOpacity(0.3),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: [
            _buildCategoryTab('', 'Tất cả'),
            ..._categories.map((category) => _buildCategoryTab(
              category, 
              _categoryNames[category] ?? category,
            )),
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
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.1),
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
  
  Widget _buildDateFilter() {
    return Container(
      height: 40,
      color: Colors.black.withOpacity(0.1),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            const Text(
              'Lọc theo: ',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(width: 8),
            _buildDateFilterChip('all', 'Tất cả'),
            const SizedBox(width: 8),
            _buildDateFilterChip('today', 'Hôm nay'),
            const SizedBox(width: 8),
            _buildDateFilterChip('week', '7 ngày'),
            const SizedBox(width: 8),
            _buildDateFilterChip('month', '30 ngày'),
            if (_dateFilter != 'all') ...[
              const SizedBox(width: 16),
              // Hiển thị khoảng thời gian đang lọc
              _buildDateRangeText(),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildDateFilterChip(String filter, String label) {
    final isSelected = _dateFilter == filter;
    
    return GestureDetector(
      onTap: () => _changeDateFilter(filter),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.white : Colors.white30,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.indigo.shade900 : Colors.white,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
  
  Widget _buildDateRangeText() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    String dateText = '';
    IconData icon = Icons.calendar_today_outlined;
    
    switch (_dateFilter) {
      case 'today':
        final dateFormat = DateFormat('dd/MM/yyyy');
        dateText = dateFormat.format(today);
        icon = Icons.today;
        break;
      case 'week':
        final weekAgo = today.subtract(const Duration(days: 6));
        final dateFormat = DateFormat('dd/MM');
        dateText = '${dateFormat.format(weekAgo)} - ${dateFormat.format(today)}';
        icon = Icons.date_range;
        break;
      case 'month':
        final monthAgo = today.subtract(const Duration(days: 29));
        final dateFormat = DateFormat('dd/MM');
        dateText = '${dateFormat.format(monthAgo)} - ${dateFormat.format(today)}';
        icon = Icons.date_range;
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.indigo.shade900.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white70),
          const SizedBox(width: 4),
          Text(
            dateText,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildNoFilterMatchState() {
    String filterText = '';
    switch (_dateFilter) {
      case 'today':
        filterText = 'hôm nay';
        break;
      case 'week':
        filterText = '7 ngày qua';
        break;
      case 'month':
        filterText = '30 ngày qua';
        break;
      default:
        filterText = '';
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.filter_list, color: Colors.white.withOpacity(0.6), size: 60),
          const SizedBox(height: 16),
          Text(
            'Không có bài viết nào ${filterText.isNotEmpty ? 'trong $filterText' : 'phù hợp'}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Thử thay đổi bộ lọc hoặc danh mục để xem nhiều bài viết hơn',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton.icon(
                onPressed: () => _changeDateFilter('all'),
                icon: const Icon(Icons.refresh, color: Colors.white),
                label: const Text('Xóa bộ lọc thời gian', style: TextStyle(color: Colors.white)),
              ),
              if (_selectedCategory.isNotEmpty)
                TextButton.icon(
                  onPressed: () => _changeCategory(''),
                  icon: const Icon(Icons.category_outlined, color: Colors.white),
                  label: const Text('Xem tất cả danh mục', style: TextStyle(color: Colors.white)),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoadMoreIndicator() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: _isLoadingMore 
          ? const CircularProgressIndicator(color: Colors.white)
          : TextButton(
              onPressed: _hasMoreData ? _loadMoreNews : null,
              child: Text(
                _hasMoreData ? 'Tải thêm tin tức' : 'Đã tải hết tin',
                style: const TextStyle(color: Colors.white70),
              ),
            ),
      ),
    );
  }

  Widget _buildAnimatedNewsCard(NewsItem news, int index) {
    // Calculate animation delay based on current page and index
    final int absoluteIndex = (_currentPage - 1) * 10 + index;
    final int delayedIndex = index % 10; // Only animate the first 10 items per page
    
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
        height: 220,
        margin: const EdgeInsets.only(bottom: 20),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background Image with error handling
              _buildNewsImage(news.imageUrl),
              // Gradient Overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.2),
                      Colors.black.withOpacity(0.8),
                    ],
                    stops: const [0.4, 0.6, 1.0],
                  ),
                ),
              ),
              // Source tag in top-right
              if (news.imageUrl != 'no_image')
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.photo_camera, size: 12, color: Colors.white70),
                        const SizedBox(width: 4),
                        Text(
                          news.source,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.white70,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              // Content
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            news.source.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            news.timeAgo,
                            style: const TextStyle(color: Colors.white70, fontSize: 13),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.black45,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            news.category,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      news.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                      ),
                    ),
                    if (news.tags.isNotEmpty && news.tags.length > 1)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Row(
                          children: [
                            Icon(Icons.tag, size: 12, color: Colors.white60),
                            const SizedBox(width: 4),
                            Text(
                              '${news.tags.length} thẻ',
                              style: TextStyle(
                                color: Colors.white60,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildNewsImage(String imageUrl) {
    // Kiểm tra nếu không có hình ảnh
    if (imageUrl == 'no_image') {
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.indigo.shade900,
              Colors.indigo.shade800,
              Colors.indigo.shade700,
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_not_supported, color: Colors.white70, size: 40),
            const SizedBox(height: 8),
            const Text(
              'Không có hình ảnh',
              style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      );
    }
    
    // Skip processing base64 or data URLs
    if (imageUrl.contains('data:image') || imageUrl.contains('base64')) {
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Colors.indigo.shade800,
              Colors.indigo.shade900,
              Colors.deepPurple.shade900,
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.broken_image, color: Colors.white70, size: 40),
            const SizedBox(height: 8),
            const Text(
              'Hình ảnh không hỗ trợ',
              style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      );
    }
    
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.indigo.shade900.withOpacity(0.5),
              Colors.indigo.shade800.withOpacity(0.3),
              Colors.indigo.shade700.withOpacity(0.5),
            ],
          ),
        ),
        child: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white60),
            strokeWidth: 2,
          ),
        ),
      ),
      errorWidget: (context, url, error) {
        // print('Error loading image: $url - $error');
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.indigo.shade800,
                Colors.indigo.shade900,
                Colors.deepPurple.shade900,
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.white70, size: 40),
              const SizedBox(height: 8),
              const Text(
                'Không tải được hình ảnh',
                style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        );
      },
      // Fix for HTTP 403 errors - add headers
      httpHeaders: const {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
        'Accept': 'image/webp,image/apng,image/*,*/*;q=0.8',
        'Accept-Encoding': 'gzip, deflate, br',
        'Referer': 'https://znews.vn/',
      },
      // Increase memory cache size
      cacheKey: 'news_${imageUrl.hashCode}',
      memCacheHeight: 500,
      memCacheWidth: 1000,
      maxHeightDiskCache: 500,
      maxWidthDiskCache: 1000,
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.white),
          SizedBox(height: 20),
          Text('Đang tải tin tức...', style: TextStyle(color: Colors.white70, fontSize: 16)),
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
            const Icon(Icons.cloud_off_rounded, color: Colors.white70, size: 60),
            const SizedBox(height: 20),
            const Text(
              'Lỗi kết nối',
              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
            style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
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