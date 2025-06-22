import 'package:flutter/material.dart';

class RiskWarningScreen extends StatefulWidget {
  const RiskWarningScreen({super.key});

  @override
  State<RiskWarningScreen> createState() => _RiskWarningScreenState();
}

class _RiskWarningScreenState extends State<RiskWarningScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cảnh Báo Rủi Giá'),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Mới Nhất'),
            Tab(text: 'Xu Hướng'),
            Tab(text: 'Nghiêm Trọng'),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.red.shade700,
              Colors.red.shade500,
              Colors.red.shade300,
            ],
          ),
        ),
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildWarningList(_latestWarnings),
            _buildWarningList(_trendingWarnings),
            _buildWarningList(_severeWarnings),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red.shade700,
        onPressed: () {
          _showReportDialog();
        },
        child: const Icon(Icons.add_alert, color: Colors.white),
        tooltip: 'Báo cáo rủi ro',
      ),
    );
  }

  Widget _buildWarningList(List<WarningItem> warnings) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: warnings.length,
      itemBuilder: (context, index) {
        final warning = warnings[index];
        return _buildWarningCard(warning);
      },
    );
  }

  Widget _buildWarningCard(WarningItem warning) {
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
              color: _getSeverityColor(warning.severity),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _getSeverityIcon(warning.severity),
                  color: Colors.white,
                ),
                const SizedBox(width: 8),
                Text(
                  _getSeverityText(warning.severity),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  warning.date,
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
                Row(
                  children: [
                    const Icon(Icons.attach_money, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Loại giao dịch: ${warning.transactionType}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                Text(
                  warning.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  warning.description,
                  style: const TextStyle(
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Các dấu hiệu nhận biết:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...warning.signs.map((sign) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.check_circle,
                                size: 18,
                                color: Colors.red,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(sign),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
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
                    ),
                    _buildActionButton(
                      Icons.report,
                      'Báo cáo',
                      Colors.orange,
                    ),
                    _buildActionButton(
                      Icons.help_outline,
                      'Trợ giúp',
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

  Color _getSeverityColor(int severity) {
    switch (severity) {
      case 1:
        return Colors.orange;
      case 2:
        return Colors.orange.shade700;
      case 3:
      default:
        return Colors.red.shade700;
    }
  }

  IconData _getSeverityIcon(int severity) {
    switch (severity) {
      case 1:
        return Icons.warning;
      case 2:
        return Icons.warning_amber;
      case 3:
      default:
        return Icons.dangerous;
    }
  }

  String _getSeverityText(int severity) {
    switch (severity) {
      case 1:
        return 'Nguy cơ thấp';
      case 2:
        return 'Nguy cơ cao';
      case 3:
      default:
        return 'Rất nguy hiểm';
    }
  }

  void _showReportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Báo Cáo Rủi Ro Mới'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const TextField(
                decoration: InputDecoration(
                  labelText: 'Tiêu đề cảnh báo',
                  hintText: 'Nhập tiêu đề ngắn gọn',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              const TextField(
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Mô tả chi tiết',
                  hintText: 'Mô tả chi tiết về rủi ro',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Loại giao dịch',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'online',
                    child: Text('Giao dịch trực tuyến'),
                  ),
                  DropdownMenuItem(
                    value: 'transfer',
                    child: Text('Chuyển khoản ngân hàng'),
                  ),
                  DropdownMenuItem(
                    value: 'withdrawal',
                    child: Text('Rút tiền ATM'),
                  ),
                  DropdownMenuItem(
                    value: 'other',
                    child: Text('Khác'),
                  ),
                ],
                onChanged: (value) {},
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(
                  labelText: 'Mức độ nghiêm trọng',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 1,
                    child: Text('Nguy cơ thấp'),
                  ),
                  DropdownMenuItem(
                    value: 2,
                    child: Text('Nguy cơ cao'),
                  ),
                  DropdownMenuItem(
                    value: 3,
                    child: Text('Rất nguy hiểm'),
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
              backgroundColor: Colors.red.shade700,
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Gửi Cảnh Báo',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class WarningItem {
  final String title;
  final String description;
  final String transactionType;
  final List<String> signs;
  final String date;
  final int severity; // 1-3, where 3 is most severe

  WarningItem({
    required this.title,
    required this.description,
    required this.transactionType,
    required this.signs,
    required this.date,
    required this.severity,
  });
}

final List<WarningItem> _latestWarnings = [
  WarningItem(
    title: 'Lừa đảo qua QR Code giả mạo',
    description: 'Các đối tượng tạo mã QR giả mạo để chiếm đoạt thông tin tài khoản ngân hàng hoặc chuyển tiền.',
    transactionType: 'Thanh toán QR',
    signs: [
      'QR code được gửi qua tin nhắn từ người lạ',
      'Yêu cầu quét mã QR để nhận quà, khuyến mãi đặc biệt',
      'Website sau khi quét có giao diện giả mạo ngân hàng',
    ],
    date: '15/11/2023',
    severity: 3,
  ),
  WarningItem(
    title: 'Chiêu trò hoàn tiền giả mạo',
    description: 'Lừa đảo gọi điện thông báo hoàn tiền từ các sàn thương mại điện tử và yêu cầu chuyển phí xác minh.',
    transactionType: 'Chuyển khoản',
    signs: [
      'Cuộc gọi từ người tự xưng là nhân viên sàn TMĐT',
      'Thông báo được hoàn tiền đơn hàng mà bạn không mua',
      'Yêu cầu chuyển một khoản phí nhỏ để xác minh',
    ],
    date: '12/11/2023',
    severity: 2,
  ),
  WarningItem(
    title: 'Lừa đảo đầu tư tiền điện tử',
    description: 'Các đối tượng mời gọi đầu tư vào các dự án tiền điện tử với lãi suất cực cao nhưng thực chất là lừa đảo.',
    transactionType: 'Đầu tư tiền ảo',
    signs: [
      'Hứa hẹn lợi nhuận từ 30-50% mỗi tháng',
      'Giao diện ứng dụng/website không chuyên nghiệp',
      'Không có thông tin xác thực về đội ngũ phát triển',
      'Yêu cầu mời thêm người để nhận thưởng',
    ],
    date: '10/11/2023',
    severity: 3,
  ),
];

final List<WarningItem> _trendingWarnings = [
  WarningItem(
    title: 'Giả mạo ứng dụng ngân hàng',
    description: 'Xuất hiện nhiều ứng dụng giả mạo các ứng dụng ngân hàng lớn trên các kho ứng dụng không chính thức.',
    transactionType: 'Giao dịch trực tuyến',
    signs: [
      'Ứng dụng yêu cầu quá nhiều quyền truy cập',
      'Giao diện có sự khác biệt nhỏ so với ứng dụng thật',
      'Được tải từ nguồn không phải Google Play hay App Store',
    ],
    date: '08/11/2023',
    severity: 3,
  ),
  WarningItem(
    title: 'Gọi điện giả danh công an',
    description: 'Các đối tượng giả danh công an, viện kiểm sát gọi điện thông báo liên quan đến vụ án và yêu cầu chuyển tiền để xác minh.',
    transactionType: 'Chuyển khoản',
    signs: [
      'Gọi từ số điện thoại lạ, có thể giả số cơ quan công an',
      'Thông báo bạn liên quan đến vụ án ma túy, rửa tiền',
      'Yêu cầu chuyển tiền vào tài khoản "an toàn" để xác minh',
    ],
    date: '05/11/2023',
    severity: 3,
  ),
];

final List<WarningItem> _severeWarnings = [
  WarningItem(
    title: 'Deepfake video call lừa đảo',
    description: 'Sử dụng công nghệ AI để giả mạo cuộc gọi video của người thân, yêu cầu chuyển tiền khẩn cấp trong trường hợp "nguy hiểm".',
    transactionType: 'Chuyển khoản',
    signs: [
      'Cuộc gọi video có chất lượng hình ảnh không đồng đều',
      'Giọng nói hoặc cử chỉ của người gọi có điểm bất thường',
      'Tạo ra tình huống khẩn cấp đòi hỏi chuyển tiền ngay',
      'Không cho phép gọi lại theo số điện thoại thường dùng',
    ],
    date: '03/11/2023',
    severity: 3,
  ),
  WarningItem(
    title: 'Giả mạo CSGT phạt nguội trực tuyến',
    description: 'Đối tượng gửi tin nhắn thông báo phạt nguội, yêu cầu nộp phạt qua đường link giả mạo để đánh cắp thông tin thẻ.',
    transactionType: 'Thanh toán trực tuyến',
    signs: [
      'Tin nhắn SMS hoặc email có chứa link thanh toán',
      'Thông báo phạt nguội không có số biên bản cụ thể',
      'Trang web thanh toán không có giao diện chính thống',
      'URL khác với trang web chính thức của Cổng dịch vụ công',
    ],
    date: '01/11/2023',
    severity: 3,
  ),
]; 