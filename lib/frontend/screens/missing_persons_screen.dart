import 'package:flutter/material.dart';
import '../models/missing_person.dart';
import '../../backend/services/missing_person_service.dart';

class MissingPersonsScreen extends StatefulWidget {
  @override
  _MissingPersonsScreenState createState() => _MissingPersonsScreenState();
}

class _MissingPersonsScreenState extends State<MissingPersonsScreen> {
  final MissingPersonService _service = MissingPersonService();
  final TextEditingController _searchController = TextEditingController();

  List<MissingPerson> _missingPersons = [];
  List<MissingPerson> _filteredPersons = [];
  bool _isLoading = true;
  String _errorMessage = '';
  String _searchType = 'name'; // 'name', 'location', 'year'
  int _currentPage = 1;
  bool _hasMoreData = true;

  @override
  void initState() {
    super.initState();
    _loadMissingPersons();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadMissingPersons({bool loadMore = false}) async {
    try {
      if (!loadMore) {
        setState(() {
          _isLoading = true;
          _errorMessage = '';
          _currentPage = 1;
        });
      }

      final persons = await _service.fetchFromAllSources(
        maxPages: _currentPage + 1,
      );

      setState(() {
        if (loadMore) {
          _missingPersons.addAll(persons.skip(_missingPersons.length));
        } else {
          _missingPersons = persons;
        }
        _filteredPersons = _missingPersons;
        _isLoading = false;
        _hasMoreData = persons.length > _missingPersons.length;
        if (loadMore) _currentPage++;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Không thể tải danh sách người mất tích: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _performSearch() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() {
        _filteredPersons = _missingPersons;
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      List<MissingPerson> results = [];

      switch (_searchType) {
        case 'name':
          results = await _service.searchByName(query, maxPages: 3);
          break;
        case 'location':
          results = await _service.searchByLocation(query, maxPages: 3);
          break;
        case 'year':
          results = await _service.searchByBirthYear(query, maxPages: 3);
          break;
      }

      setState(() {
        _filteredPersons = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Lỗi tìm kiếm: $e';
        _isLoading = false;
      });
    }
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _filteredPersons = _missingPersons;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Danh Sách Người Mất Tích'),
        backgroundColor: Colors.orange,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () => _loadMissingPersons(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Section
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Tìm kiếm...',
                          prefixIcon: Icon(Icons.search),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: Icon(Icons.clear),
                                  onPressed: _clearSearch,
                                )
                              : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onSubmitted: (_) => _performSearch(),
                      ),
                    ),
                    SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _performSearch,
                      child: Text('Tìm'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Text('Tìm theo: '),
                    Expanded(
                      child: DropdownButton<String>(
                        value: _searchType,
                        isExpanded: true,
                        items: [
                          DropdownMenuItem(value: 'name', child: Text('Tên')),
                          DropdownMenuItem(
                            value: 'location',
                            child: Text('Địa điểm'),
                          ),
                          DropdownMenuItem(
                            value: 'year',
                            child: Text('Năm sinh'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _searchType = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Results Section
          Expanded(
            child: _isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                      ],
                    ),
                  )
                : _errorMessage.isNotEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error, size: 64, color: Colors.red),
                        SizedBox(height: 16),
                        Text(
                          _errorMessage,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.red),
                        ),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => _loadMissingPersons(),
                          child: Text('Thử lại'),
                        ),
                      ],
                    ),
                  )
                : _filteredPersons.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'Không tìm thấy kết quả nào',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Thử tìm kiếm với từ khóa khác',
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () => _loadMissingPersons(),
                    child: ListView.builder(
                      itemCount:
                          _filteredPersons.length + (_hasMoreData ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == _filteredPersons.length) {
                          // Load more button
                          return Container(
                            padding: EdgeInsets.all(16),
                            child: Center(
                              child: ElevatedButton(
                                onPressed: () =>
                                    _loadMissingPersons(loadMore: true),
                                child: Text('Tải thêm'),
                              ),
                            ),
                          );
                        }

                        final person = _filteredPersons[index];
                        return Card(
                          margin: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          elevation: 2,
                          child: ListTile(
                            leading: CircleAvatar(
                              radius: 30,
                              backgroundImage: person.imageUrl.isNotEmpty
                                  ? NetworkImage(person.imageUrl)
                                  : null,
                              child: person.imageUrl.isEmpty
                                  ? Icon(Icons.person, size: 30)
                                  : null,
                            ),
                            title: Text(
                              person.name,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 4),
                                if (person.age.isNotEmpty)
                                  Text('Năm sinh: ${person.age}'),
                                if (person.lastSeenLocation.isNotEmpty)
                                  Text('Quê quán: ${person.lastSeenLocation}'),
                                if (person.lastSeenDate.isNotEmpty)
                                  Text('Thất lạc từ: ${person.lastSeenDate}'),
                                if (person.description.isNotEmpty)
                                  Text(
                                    person.description.length > 100
                                        ? '${person.description.substring(0, 100)}...'
                                        : person.description,
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                              ],
                            ),
                            trailing: Icon(Icons.arrow_forward_ios),
                            onTap: () {
                              _showPersonDetails(person);
                            },
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  void _showPersonDetails(MissingPerson person) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(person.name),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (person.imageUrl.isNotEmpty)
                Center(
                  child: Image.network(
                    person.imageUrl,
                    height: 200,
                    errorBuilder: (context, error, stackTrace) =>
                        Icon(Icons.person, size: 100),
                  ),
                ),
              SizedBox(height: 16),
              _buildDetailRow('ID', person.id),
              _buildDetailRow('Tên', person.name),
              _buildDetailRow('Năm sinh', person.age),
              _buildDetailRow('Quê quán', person.lastSeenLocation),
              _buildDetailRow('Thất lạc từ', person.lastSeenDate),
              _buildDetailRow('Thông tin liên hệ', person.contactInfo),
              if (person.description.isNotEmpty) ...[
                SizedBox(height: 8),
                Text('Mô tả:', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text(person.description),
              ],
            ],
          ),
        ),
        actions: [
          if (person.detailUrl.isNotEmpty)
            TextButton(
              onPressed: () {
                // TODO: Open detail URL in browser
                Navigator.of(context).pop();
              },
              child: Text('Xem chi tiết'),
            ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Đóng'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    if (value.isEmpty) return SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
