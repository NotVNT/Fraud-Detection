import 'package:flutter/material.dart';

class WantedListScreen extends StatefulWidget {
  const WantedListScreen({super.key});

  @override
  State<WantedListScreen> createState() => _WantedListScreenState();
}

class _WantedListScreenState extends State<WantedListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _filterType = 'all';
  List<WantedPerson> _filteredList = [];
  
  @override
  void initState() {
    super.initState();
    _filteredList = _wantedList;
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterList(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredList = _wantedList.where((person) {
          if (_filterType == 'all') return true;
          return person.category == _filterType;
        }).toList();
      } else {
        _filteredList = _wantedList.where((person) {
          final nameMatch = person.name.toLowerCase().contains(query.toLowerCase());
          final locationMatch = person.lastLocation.toLowerCase().contains(query.toLowerCase());
          final categoryMatch = _filterType == 'all' || person.category == _filterType;
          
          return (nameMatch || locationMatch) && categoryMatch;
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh Sách Quy Nã'),
        backgroundColor: Colors.purple.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
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
              child: _filteredList.isEmpty
                  ? _buildEmptyState()
                  : _buildWantedList(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.purple.shade700,
        onPressed: () {
          _showReportDialog();
        },
        child: const Icon(Icons.add_alert, color: Colors.white),
        tooltip: 'Báo cáo đối tượng',
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
                hintText: 'Tìm kiếm theo tên, địa điểm...',
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
          _buildFilterChip('financial', 'Lừa đảo tài chính'),
          const SizedBox(width: 8),
          _buildFilterChip('cyber', 'Tội phạm mạng'),
          const SizedBox(width: 8),
          _buildFilterChip('identity', 'Giả danh'),
          const SizedBox(width: 8),
          _buildFilterChip('other', 'Khác'),
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
          _filterList(_searchController.text);
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
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredList.length,
      itemBuilder: (context, index) {
        final person = _filteredList[index];
        return _buildWantedCard(person);
      },
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
                  _getCategoryName(person.category),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  'Đã báo cáo: ${person.reportCount}',
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
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 100,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 60,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
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
                      const SizedBox(height: 8),
                      _buildInfoRow(Icons.calendar_today, 'Tuổi: ${person.age}'),
                      const SizedBox(height: 4),
                      _buildInfoRow(Icons.location_on, person.lastLocation),
                      const SizedBox(height: 4),
                      _buildInfoRow(Icons.phone, person.contactPhone),
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
                          'Cần cảnh giác',
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
                  'Mô tả hành vi:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 8),
                Text(person.description),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildActionButton(
                      Icons.share,
                      'Chia sẻ',
                      Colors.blue,
                    ),
                    _buildActionButton(
                      Icons.report,
                      'Báo cáo thêm',
                      Colors.orange,
                    ),
                    _buildActionButton(
                      Icons.phone,
                      'Gọi',
                      Colors.green,
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

  Widget _buildActionButton(IconData icon, String label, Color color) {
    return TextButton.icon(
      onPressed: () {},
      icon: Icon(icon, color: color, size: 20),
      label: Text(
        label,
        style: TextStyle(color: color),
      ),
    );
  }

  String _getCategoryName(String category) {
    switch (category) {
      case 'financial':
        return 'Lừa đảo tài chính';
      case 'cyber':
        return 'Tội phạm mạng';
      case 'identity':
        return 'Giả danh';
      case 'other':
        return 'Khác';
      default:
        return 'Không xác định';
    }
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
              'Đây là danh sách các đối tượng lừa đảo đã được xác nhận và cảnh báo.',
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
              '• Thông tin được cập nhật từ cộng đồng và cơ quan chức năng',
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

  void _showReportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Báo Cáo Đối Tượng'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const TextField(
                decoration: InputDecoration(
                  labelText: 'Tên đối tượng',
                  hintText: 'Nhập tên đối tượng cần báo cáo',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              const TextField(
                decoration: InputDecoration(
                  labelText: 'Số điện thoại/Tài khoản',
                  hintText: 'Nhập số điện thoại hoặc tài khoản của đối tượng',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              const TextField(
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Mô tả hành vi',
                  hintText: 'Mô tả chi tiết hành vi lừa đảo',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Loại lừa đảo',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'financial',
                    child: Text('Lừa đảo tài chính'),
                  ),
                  DropdownMenuItem(
                    value: 'cyber',
                    child: Text('Tội phạm mạng'),
                  ),
                  DropdownMenuItem(
                    value: 'identity',
                    child: Text('Giả danh'),
                  ),
                  DropdownMenuItem(
                    value: 'other',
                    child: Text('Khác'),
                  ),
                ],
                onChanged: (value) {},
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple.shade700,
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Gửi Báo Cáo',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class WantedPerson {
  final String name;
  final int age;
  final String lastLocation;
  final String contactPhone;
  final String description;
  final String category;
  final int reportCount;

  WantedPerson({
    required this.name,
    required this.age,
    required this.lastLocation,
    required this.contactPhone,
    required this.description,
    required this.category,
    required this.reportCount,
  });
}

final List<WantedPerson> _wantedList = [
  WantedPerson(
    name: 'Nguyễn Văn A',
    age: 35,
    lastLocation: 'TP. Hồ Chí Minh',
    contactPhone: '0912345678',
    description: 'Đối tượng thường tự giới thiệu là nhân viên ngân hàng, liên hệ khách hàng và yêu cầu cung cấp thông tin thẻ tín dụng để xác minh.',
    category: 'financial',
    reportCount: 23,
  ),
  WantedPerson(
    name: 'Trần Thị B',
    age: 28,
    lastLocation: 'Hà Nội',
    contactPhone: '0987654321',
    description: 'Đối tượng giả danh cán bộ thuế, liên hệ với các doanh nghiệp và yêu cầu chuyển tiền để giải quyết các vấn đề về thuế.',
    category: 'identity',
    reportCount: 17,
  ),
  WantedPerson(
    name: 'Lê Văn C',
    age: 40,
    lastLocation: 'Đà Nẵng',
    contactPhone: '0909123456',
    description: 'Đối tượng tạo các website giả mạo các sàn thương mại điện tử lớn để thu thập thông tin thẻ tín dụng và đánh cắp tiền.',
    category: 'cyber',
    reportCount: 31,
  ),
  WantedPerson(
    name: 'Phạm Thị D',
    age: 32,
    lastLocation: 'Cần Thơ',
    contactPhone: '0978123456',
    description: 'Đối tượng lừa đảo bằng hình thức huy động vốn đầu tư với lãi suất cao, sau đó chiếm đoạt tiền và bỏ trốn.',
    category: 'financial',
    reportCount: 42,
  ),
  WantedPerson(
    name: 'Hoàng Văn E',
    age: 45,
    lastLocation: 'Hải Phòng',
    contactPhone: '0912987654',
    description: 'Đối tượng giả danh công an, gọi điện thông báo người dân liên quan đến vụ án ma túy và yêu cầu chuyển tiền để được miễn truy cứu.',
    category: 'identity',
    reportCount: 28,
  ),
]; 