import 'package:flutter/material.dart';

class NewsScreen extends StatelessWidget {
  const NewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tin Mới'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade700,
              Colors.blue.shade500,
              Colors.blue.shade300,
            ],
          ),
        ),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _sampleNews.length,
          itemBuilder: (context, index) {
            final news = _sampleNews[index];
            return _buildNewsCard(news);
          },
        ),
      ),
    );
  }

  Widget _buildNewsCard(NewsItem news) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.network(
              news.imageUrl,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 180,
                  color: Colors.grey.shade300,
                  child: const Icon(
                    Icons.image_not_supported,
                    size: 50,
                    color: Colors.grey,
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: const Text(
                        'MỚI',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      news.date,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.visibility,
                      size: 16,
                      color: Colors.grey.shade700,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${news.views}',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  news.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  news.summary,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildActionButton(Icons.share, 'Chia sẻ', Colors.blue),
                    const SizedBox(width: 16),
                    _buildActionButton(
                      Icons.bookmark_border,
                      'Lưu',
                      Colors.orange,
                    ),
                    const SizedBox(width: 16),
                    _buildActionButton(
                      Icons.warning_amber,
                      'Báo cáo',
                      Colors.red,
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
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class NewsItem {
  final String title;
  final String summary;
  final String imageUrl;
  final String date;
  final int views;

  NewsItem({
    required this.title,
    required this.summary,
    required this.imageUrl,
    required this.date,
    required this.views,
  });
}

final List<NewsItem> _sampleNews = [
  NewsItem(
    title: 'Cảnh báo lừa đảo qua tin nhắn SMS',
    summary: 'Người dân cần cẩn trọng với các tin nhắn yêu cầu chuyển tiền từ các tổ chức tài chính không rõ nguồn gốc.',
    imageUrl: 'https://via.placeholder.com/400x200?text=Fraud+Warning',
    date: '10/11/2023',
    views: 1254,
  ),
  NewsItem(
    title: 'Phát hiện app giả mạo ngân hàng trên CH Play',
    summary: 'Cơ quan chức năng phát hiện và xóa bỏ nhiều ứng dụng giả mạo các ứng dụng ngân hàng nhằm lừa đảo người dùng.',
    imageUrl: 'https://via.placeholder.com/400x200?text=Fake+Apps',
    date: '08/11/2023',
    views: 982,
  ),
  NewsItem(
    title: 'Lừa đảo qua cuộc gọi video',
    summary: 'Xuất hiện hình thức lừa đảo mới thông qua các cuộc gọi video deepfake giả mạo người thân.',
    imageUrl: 'https://via.placeholder.com/400x200?text=Video+Call+Fraud',
    date: '05/11/2023',
    views: 1589,
  ),
  NewsItem(
    title: 'Làm gì khi bị lừa qua mạng xã hội?',
    summary: 'Hướng dẫn các bước cần thực hiện ngay khi phát hiện bị lừa đảo qua các nền tảng mạng xã hội.',
    imageUrl: 'https://via.placeholder.com/400x200?text=Social+Media+Scam',
    date: '01/11/2023',
    views: 2145,
  ),
]; 