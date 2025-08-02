import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../backend/services/verification_service.dart';
import '../models/verification_result.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _accountController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  final VerificationService _verificationService = VerificationService();
  VerificationResult? _verificationResult;
  bool _isLoading = false;
  bool _hasResult = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _accountController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Xác Thực Thông Tin'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.green.shade700,
              Colors.green.shade500,
              Colors.green.shade300,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildInfoCard(),
                  const SizedBox(height: 24),
                  _buildVerificationForm(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.verified_user,
                    color: Colors.green.shade700,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Công Cụ Xác Thực',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Giúp bạn kiểm tra tính xác thực của thông tin',
                        style: TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Nhập thông tin cần xác minh vào mẫu bên dưới. Hệ thống sẽ kiểm tra và cung cấp kết quả dựa trên dữ liệu của chúng tôi.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerificationForm() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Thông Tin Cần Xác Minh',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              // Phone number verification
              _buildVerificationOption(
                'Số điện thoại',
                'Kiểm tra số điện thoại có phải lừa đảo không',
                Icons.phone,
                _phoneController,
                'Nhập số điện thoại cần kiểm tra',
                TextInputType.phone,
              ),
              const SizedBox(height: 16),
              // Bank account verification
              _buildVerificationOption(
                'Tài khoản ngân hàng',
                'Kiểm tra tài khoản ngân hàng có bị báo cáo là lừa đảo',
                Icons.account_balance,
                _accountController,
                'Nhập số tài khoản cần kiểm tra',
                TextInputType.number,
              ),
              const SizedBox(height: 16),
              // Website verification
              _buildVerificationOption(
                'Website',
                'Kiểm tra website có phải là giả mạo không',
                Icons.language,
                _websiteController,
                'Nhập địa chỉ website cần kiểm tra',
                TextInputType.url,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _verifyInformation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.verified, color: Colors.white),
                label: Text(
                  _isLoading ? 'Đang xác thực...' : 'Xác thực ngay',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (_hasResult) _buildResultCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVerificationOption(
    String title,
    String description,
    IconData icon,
    TextEditingController controller,
    String hintText,
    TextInputType keyboardType,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.green.shade700),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hintText,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            filled: true,
            fillColor: Colors.grey.shade100,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultCard() {
    if (_verificationResult == null) return const SizedBox.shrink();

    final result = _verificationResult!;
    final isDanger = result.isDanger;
    final isWarning = result.isWarning;
    final isSafe = result.isSafe;

    Color backgroundColor;
    Color borderColor;
    Color textColor;
    IconData iconData;
    String statusText;

    if (isDanger) {
      backgroundColor = Colors.red.shade50;
      borderColor = Colors.red.shade300;
      textColor = Colors.red.shade700;
      iconData = Icons.dangerous;
      statusText = 'Nguy hiểm - Lừa đảo';
    } else if (isWarning) {
      backgroundColor = Colors.orange.shade50;
      borderColor = Colors.orange.shade300;
      textColor = Colors.orange.shade700;

      // Kiểm tra xem có phải lỗi kết nối không
      if (result.source?.contains('không thể kết nối') == true) {
        iconData = Icons.wifi_off;
        statusText = 'Không thể kết nối';
      } else {
        iconData = Icons.warning_amber;
        statusText = 'Cảnh báo';
      }
    } else {
      backgroundColor = Colors.green.shade50;
      borderColor = Colors.green.shade300;
      textColor = Colors.green.shade700;
      iconData = Icons.verified_user;
      statusText = 'An toàn';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(iconData, color: textColor),
              const SizedBox(width: 8),
              Text(
                statusText,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            result.message,
            style: TextStyle(fontSize: 14, color: textColor),
          ),
          if (result.fraudPercentage != null) ...[
            const SizedBox(height: 8),
            Text(
              'Tỷ lệ lừa đảo: ${result.fraudPercentage!.toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ],
          if (result.warnings.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Cảnh báo:',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            ...result.warnings.map(
              (warning) => Padding(
                padding: const EdgeInsets.only(left: 8, top: 2),
                child: Text(
                  '• $warning',
                  style: TextStyle(fontSize: 12, color: textColor),
                ),
              ),
            ),
          ],
          if (result.source != null) ...[
            const SizedBox(height: 8),
            Text(
              'Nguồn: ${result.source}',
              style: TextStyle(
                fontSize: 10,
                fontStyle: FontStyle.italic,
                color: textColor.withOpacity(0.7),
              ),
            ),
          ],
          // Hiển thị nút kiểm tra thủ công khi không kết nối được
          if (result.source?.contains('không thể kết nối') == true) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _openCheckscamManually(),
                icon: const Icon(Icons.open_in_browser, size: 16),
                label: const Text('Kiểm tra thủ công trên CheckScam.vn'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _verifyInformation() async {
    // Validate that at least one field is filled
    if (_phoneController.text.isEmpty &&
        _accountController.text.isEmpty &&
        _websiteController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập ít nhất một thông tin cần xác thực'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _hasResult = false;
      _verificationResult = null;
    });

    try {
      VerificationResult result;

      if (_phoneController.text.isNotEmpty) {
        result = await _verificationService.verifyPhoneNumber(
          _phoneController.text,
        );
      } else if (_accountController.text.isNotEmpty) {
        result = await _verificationService.verifyBankAccount(
          _accountController.text,
        );
      } else if (_websiteController.text.isNotEmpty) {
        result = await _verificationService.verifyWebsite(
          _websiteController.text,
        );
      } else {
        // This shouldn't happen due to validation above, but just in case
        throw Exception('Không có thông tin để xác thực');
      }

      setState(() {
        _isLoading = false;
        _hasResult = true;
        _verificationResult = result;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasResult = true;
        _verificationResult = VerificationResult(
          status: 'warning',
          message:
              'Có lỗi xảy ra khi xác thực thông tin: ${e.toString()}. Vui lòng thử lại sau.',
          source: 'Hệ thống',
        );
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi xác thực: ${e.toString()}'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  void _openCheckscamManually() async {
    String searchTerm = '';

    // Lấy thông tin đã nhập
    if (_phoneController.text.isNotEmpty) {
      searchTerm = _phoneController.text;
    } else if (_accountController.text.isNotEmpty) {
      searchTerm = _accountController.text;
    } else if (_websiteController.text.isNotEmpty) {
      searchTerm = _websiteController.text;
    }

    if (searchTerm.isNotEmpty) {
      final url =
          'https://checkscam.vn/?qh_ss=${Uri.encodeComponent(searchTerm)}';

      try {
        if (await canLaunchUrl(Uri.parse(url))) {
          await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Không thể mở trình duyệt. Vui lòng truy cập checkscam.vn thủ công.',
                ),
                backgroundColor: Colors.orange,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi mở trình duyệt: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
