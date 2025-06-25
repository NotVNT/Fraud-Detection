import 'package:flutter/material.dart';
import 'news_screen.dart';
import 'risk_warning_screen.dart';
import 'verification_screen.dart';
import 'wanted_list_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _showNotificationBox = true;

  void _hideNotificationBox() {
    setState(() {
      _showNotificationBox = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade800,
              Colors.blue.shade600,
              Colors.blue.shade400,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildBanner(),
                const SizedBox(height: 20),
                if (_showNotificationBox) _buildNotificationPermissionBox(),
                if (_showNotificationBox) const SizedBox(height: 20),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildFunctionalButtons(context),
                        const SizedBox(height: 30),
                        _buildContactInfo(context),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationPermissionBox() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.notifications_active, color: Colors.blue.shade700),
              const SizedBox(width: 10),
              Expanded(
                child: const Text(
                  'Allow Fraud Detection to send notifications to you',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  _hideNotificationBox();
                },
                child: const Text('Decline'),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  // Request notification permissions here
                  _hideNotificationBox();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Allow'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBanner() {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.security,
              size: 40,
              color: Colors.blue.shade700,
            ),
            const SizedBox(width: 10),
            const Text(
              'PHÒNG CHỐNG LỪA ĐẢO',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFunctionalButtons(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildCircularButton(
              context,
              Icons.newspaper,
              'Tin mới',
              Colors.orange,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const NewsScreen()),
                );
              },
            ),
            _buildCircularButton(
              context,
              Icons.warning_rounded,
              'Cảnh báo tin giả',
              Colors.red,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RiskWarningScreen()),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 30),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildCircularButton(
              context,
              Icons.verified_user,
              'Xác thực thông tin',
              Colors.green,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const VerificationScreen()),
                );
              },
            ),
            _buildCircularButton(
              context,
              Icons.person_search,
              'Danh sách truy nã',
              Colors.purple,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const WantedListScreen()),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCircularButton(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      color.withOpacity(0.7),
                      color,
                    ],
                    radius: 0.8,
                  ),
                ),
                child: Icon(
                  icon,
                  size: 40,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: 100,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContactInfo(BuildContext context) {
    return GestureDetector(
      onTap: () => _launchZalo(),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.white30, width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(
              'https://cdn1.iconfinder.com/data/icons/social-messaging-ui-color-shapes-2-free/128/social-zalo-square-512.png',
              width: 32,
              height: 32,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.message,
                  size: 32,
                  color: Colors.blue.shade500,
                );
              },
            ),
            const SizedBox(width: 10),
            const Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Thông tin liên hệ',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Nhấn để mở Zalo',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchZalo() async {
    // Try to open Zalo app using various possible URI schemes
    final List<String> zaloUris = [
      'zalo://', // Standard URI scheme
      'com.zing.zalo://', // Alternative package URI format
      'com.zing.zalo', // Package name directly
    ];
    
    bool launched = false;
    
    // Try all possible Zalo app URIs
    for (final uri in zaloUris) {
      try {
        final Uri launchUri = Uri.parse(uri);
        launched = await launchUrl(
          launchUri, 
          mode: LaunchMode.externalNonBrowserApplication
        );
        if (launched) break;
      } catch (e) {
        // Continue trying the next URI
        continue;
      }
    }
    
    // If we couldn't launch the app, offer Play Store link
    if (!launched && context.mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Không tìm thấy Zalo'),
          content: const Text('Bạn có thể cài đặt Zalo hoặc truy cập trang web'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Huỷ bỏ'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                final Uri webUri = Uri.parse('https://zalo.me');
                try {
                  await launchUrl(
                    webUri,
                    mode: LaunchMode.externalApplication
                  );
                } catch (_) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Không thể mở trình duyệt')),
                    );
                  }
                }
              },
              child: const Text('Web'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                final Uri playStoreUri = Uri.parse(
                  'https://play.google.com/store/apps/details?id=com.zing.zalo'
                );
                try {
                  await launchUrl(
                    playStoreUri,
                    mode: LaunchMode.externalApplication
                  );
                } catch (_) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Không thể mở Play Store'),
                      ),
                    );
                  }
                }
              },
              child: const Text('Cài đặt'),
            ),
          ],
        ),
      );
    }
  }
} 