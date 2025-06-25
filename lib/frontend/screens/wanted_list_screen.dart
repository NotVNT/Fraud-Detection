import 'package:flutter/material.dart';
import '../../backend/services/wanted_service.dart';
import '../models/wanted_person.dart';
import 'package:url_launcher/url_launcher.dart';

class WantedListScreen extends StatefulWidget {
  const WantedListScreen({super.key});

  @override
  State<WantedListScreen> createState() => _WantedListScreenState();
}

class _WantedListScreenState extends State<WantedListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final WantedService _wantedService = WantedService();
  String _filterType = 'all';
  List<WantedPerson> _wantedList = [];
  List<WantedPerson> _filteredList = [];
  bool _isLoading = true;
  String _errorMessage = '';
  int _currentPage = 1;
  bool _isLoadingMore = false;
  
  @override
  void initState() {
    super.initState();
    _loadWantedPersons();
  }
  
  Future<void> _loadWantedPersons({bool refresh = false}) async {
    try {
      setState(() {
        if (refresh) {
          _currentPage = 1;
          _wantedList = [];
          _filteredList = [];
        }
        _isLoading = _currentPage == 1;
        _isLoadingMore = _currentPage > 1;
        _errorMessage = '';
      });
      
      final wantedPersons = await _wantedService.fetchWantedPersons(page: _currentPage);
      
      setState(() {
        if (refresh || _currentPage == 1) {
          _wantedList = wantedPersons;
        } else {
          _wantedList.addAll(wantedPersons);
        }
        _applyFilters();
        _isLoading = false;
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Không thể tải dữ liệu: $e';
        _isLoading = false;
        _isLoadingMore = false;
      });
    }
  }
  
  void _loadMoreData() {
    _currentPage++;
    _loadWantedPersons();
  }
  
  void _refreshData() {
    _loadWantedPersons(refresh: true);
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterList(String query) {
    setState(() {
      _applyFilters(query: query);
    });
  }
  
  void _applyFilters({String? query}) {
    final searchQuery = query ?? _searchController.text;
    
    if (searchQuery.isEmpty && _filterType == 'all') {
      _filteredList = List.from(_wantedList);
      return;
    }
    
    _filteredList = _wantedList.where((person) {
      bool matchesSearch = true;
      if (searchQuery.isNotEmpty) {
        matchesSearch = person.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
                        person.address.toLowerCase().contains(searchQuery.toLowerCase()) ||
                        person.crime.toLowerCase().contains(searchQuery.toLowerCase());
      }
      
      bool matchesFilter = true;
      if (_filterType != 'all') {
        // Filter by crime type
        switch (_filterType) {
          case 'financial':
            matchesFilter = person.crime.toLowerCase().contains('tài sản') || 
                           person.crime.toLowerCase().contains('tiền') ||
                           person.crime.toLowerCase().contains('lừa đảo');
            break;
          case 'cyber':
            matchesFilter = person.crime.toLowerCase().contains('mạng') || 
                           person.crime.toLowerCase().contains('công nghệ') ||
                           person.crime.toLowerCase().contains('máy tính');
            break;
          case 'identity':
            matchesFilter = person.crime.toLowerCase().contains('giả danh') || 
                           person.crime.toLowerCase().contains('giả mạo');
            break;
          case 'violent':
            matchesFilter = person.crime.toLowerCase().contains('giết người') || 
                           person.crime.toLowerCase().contains('thương tích') ||
                           person.crime.toLowerCase().contains('cố ý gây thương');
            break;
          default:
            matchesFilter = true;
        }
      }
      
      return matchesSearch && matchesFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh Sách Truy Nã'),
        backgroundColor: Colors.purple.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              _showInfoDialog();
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.purple.shade700,
              Colors.purple.shade500,
              Colors.purple.shade300,
            ],
          ),
        ),
        child: Column(
          children: [
            _buildSearchBar(),
            _buildCategoryFilter(),
            Expanded(
              child: _isLoading
                  ? _buildLoadingState()
                  : _errorMessage.isNotEmpty
                      ? _buildErrorState()
                      : _filteredList.isEmpty
                          ? _buildEmptyState()
                          : _buildWantedList(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.purple.shade700,
        onPressed: () {
          _launchUrl('https://truyna.bocongan.gov.vn/');
        },
        child: const Icon(Icons.public, color: Colors.white),
        tooltip: 'Truy cập trang web chính thức',
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể mở liên kết')),
      );
    }
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: Colors.white,
          ),
          SizedBox(height: 16),
          Text(
            'Đang tải dữ liệu...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: Colors.white.withOpacity(0.6),
          ),
          const SizedBox(height: 16),
          Text(
            'Đã xảy ra lỗi',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _refreshData,
            icon: const Icon(Icons.refresh),
            label: const Text('Thử lại'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.purple.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Tìm kiếm theo tên, địa điểm, tội danh...',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 16),
              ),
              onChanged: _filterList,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.clear),
            color: Colors.grey,
            onPressed: () {
              _searchController.clear();
              _filterList('');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Container(
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildFilterChip('all', 'Tất cả'),
          const SizedBox(width: 8),
          _buildFilterChip('financial', 'Tội về tài sản'),
          const SizedBox(width: 8),
          _buildFilterChip('violent', 'Tội bạo lực'),
          const SizedBox(width: 8),
          _buildFilterChip('cyber', 'Tội công nghệ'),
          const SizedBox(width: 8),
          _buildFilterChip('identity', 'Giả danh'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String type, String label) {
    final isSelected = _filterType == type;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _filterType = type;
          _applyFilters();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.purple.shade700 : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.purple.shade700 : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 80,
            color: Colors.white.withOpacity(0.6),
          ),
          const SizedBox(height: 16),
          Text(
            'Không tìm thấy kết quả',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Hãy thử tìm kiếm với từ khóa khác',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWantedList() {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        if (!_isLoadingMore && 
            scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
          _loadMoreData();
          return true;
        }
        return false;
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _filteredList.length + (_isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _filteredList.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(color: Colors.white),
              ),
            );
          }
          
          final person = _filteredList[index];
          return _buildWantedCard(person);
        },
      ),
    );
  }

  Widget _buildWantedCard(WantedPerson person) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.purple.shade700,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.warning_amber,
                  color: Colors.white,
                ),
                const SizedBox(width: 8),
                Text(
                  _getCrimeCategory(person.crime),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  person.decisionNumber,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  person.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _buildInfoRow(Icons.calendar_today, 'Năm sinh: ${person.birthYear}'),
                const SizedBox(height: 4),
                _buildInfoRow(Icons.location_on, person.address),
                const SizedBox(height: 4),
                _buildInfoRow(Icons.people, person.parentNames),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Text(
                    'Đang truy nã',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 0),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tội danh:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 8),
                Text(person.crime),
                const SizedBox(height: 8),
                Text(
                  'Đơn vị ra quyết định: ${person.issuingUnit}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildActionButton(
                      Icons.share,
                      'Chia sẻ',
                      Colors.blue,
                      onPressed: () {},
                    ),
                    _buildActionButton(
                      Icons.open_in_browser,
                      'Chi tiết',
                      Colors.orange,
                      onPressed: () {
                        if (person.detailUrl.isNotEmpty) {
                          _launchUrl(person.detailUrl);
                        }
                      },
                    ),
                    _buildActionButton(
                      Icons.phone,
                      'Báo tin',
                      Colors.green,
                      onPressed: () {
                        _launchUrl('tel:069 2345 860');
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.grey,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.grey.shade700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(IconData icon, String label, Color color, {required Function() onPressed}) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: color, size: 20),
      label: Text(
        label,
        style: TextStyle(color: color),
      ),
    );
  }

  String _getCrimeCategory(String crime) {
    final crimeLower = crime.toLowerCase();
    
    if (crimeLower.contains('giết người')) {
      return 'Tội giết người';
    } else if (crimeLower.contains('trộm cắp') || crimeLower.contains('cướp')) {
      return 'Tội về tài sản';
    } else if (crimeLower.contains('gây thương tích') || crimeLower.contains('cố ý gây')) {
      return 'Tội gây thương tích';
    } else if (crimeLower.contains('ma túy')) {
      return 'Tội về ma túy';
    } else if (crimeLower.contains('giao thông')) {
      return 'Vi phạm giao thông';
    } else if (crimeLower.contains('lừa đảo')) {
      return 'Lừa đảo';
    } else if (crimeLower.contains('gây rối')) {
      return 'Gây rối trật tự';
    }
    
    // Default category
    return 'Đối tượng truy nã';
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thông tin'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Đây là danh sách các đối tượng truy nã từ Cổng thông tin điện tử của Bộ Công An.',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 8),
            Text(
              'Lưu ý:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            SizedBox(height: 4),
            Text(
              '• Thông tin được cập nhật từ trang web chính thức của Bộ Công An',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 4),
            Text(
              '• Nếu nhận ra đối tượng, hãy báo với cơ quan công an gần nhất',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 4),
            Text(
              '• Không tự ý tiếp cận hoặc đe dọa đối tượng',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 8),
            Text(
              'Nguồn: truyna.bocongan.gov.vn',
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đã hiểu'),
          ),
        ],
      ),
    );
  }
} 