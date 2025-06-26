import 'package:flutter/material.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _accountController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  String _verificationResult = '';
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
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
                        style: TextStyle(
                          color: Colors.black54,
                        ),
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Thông Tin Cần Xác Minh',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
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
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hintText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
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
    final isWarning = _verificationResult.contains('không an toàn') ||
        _verificationResult.contains('lừa đảo');
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isWarning ? Colors.red.shade50 : Colors.green.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isWarning ? Colors.red.shade300 : Colors.green.shade300,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                isWarning ? Icons.warning_amber : Icons.verified_user,
                color: isWarning ? Colors.red : Colors.green,
              ),
              const SizedBox(width: 8),
              Text(
                isWarning ? 'Cảnh báo' : 'An toàn',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isWarning ? Colors.red : Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _verificationResult,
            style: TextStyle(
              fontSize: 14,
              color: isWarning ? Colors.red.shade700 : Colors.green.shade700,
            ),
          ),
        ],
      ),
    );
  }

  void _verifyInformation() {
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
    });

    // Simulate verification process
    Future.delayed(const Duration(seconds: 2), () {
      // This is just sample logic. In a real app, you would check against a database
      setState(() {
        _isLoading = false;
        _hasResult = true;

        if (_phoneController.text.isNotEmpty) {
          if (_phoneController.text.startsWith('0900') ||
              _phoneController.text.startsWith('0904')) {
            _verificationResult =
                'Số điện thoại ${_phoneController.text} đã bị báo cáo là số lừa đảo. Vui lòng cảnh giác và không thực hiện giao dịch.';
          } else {
            _verificationResult =
                'Số điện thoại ${_phoneController.text} chưa có báo cáo là lừa đảo trong cơ sở dữ liệu của chúng tôi.';
          }
        } else if (_accountController.text.isNotEmpty) {
          if (_accountController.text.contains('1234')) {
            _verificationResult =
                'Tài khoản ${_accountController.text} đã bị báo cáo là không an toàn. Không nên chuyển tiền cho tài khoản này.';
          } else {
            _verificationResult =
                'Tài khoản ${_accountController.text} hiện chưa có báo cáo tiêu cực trong hệ thống.';
          }
        } else if (_websiteController.text.isNotEmpty) {
          if (_websiteController.text.contains('fake') ||
              _websiteController.text.contains('scam')) {
            _verificationResult =
                'Website ${_websiteController.text} là website lừa đảo đã được xác nhận. Không nhập thông tin cá nhân vào website này.';
          } else {
            _verificationResult =
                'Website ${_websiteController.text} chưa có báo cáo là trang lừa đảo trong cơ sở dữ liệu.';
          }
        }
      });
    });
  }
} 