import 'dart:ui';
import 'dart:io' show Platform;
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

// Importing other screens
import 'news_screen.dart';
import 'risk_warning_screen.dart';
import 'verification_screen.dart';
import 'wanted_list_screen.dart';
import 'bot_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _showNotificationBox = true;
  final List<Widget> _securityIcons = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    _animationController.forward();
    
    // Add decorative floating security icons
    _addFloatingSecurityIcons();
  }
  
  void _addFloatingSecurityIcons() {
    final random = math.Random();
    final screenWidth = 400.0; // Approximate screen width
    final screenHeight = 800.0; // Approximate screen height
    
    // Security-related icons
    final securityIcons = [
      Icons.security,
      Icons.shield,
      Icons.verified_user,
      Icons.lock,
      Icons.gpp_good,
      Icons.fingerprint,
      Icons.health_and_safety,
      Icons.shield_moon,
    ];
    
    // Security-related colors
    final colors = [
      Colors.blue.shade300,
      Colors.green.shade300,
      Colors.purple.shade300,
      Colors.cyan.shade300,
      Colors.teal.shade300,
      Colors.indigo.shade300,
    ];
    
    // Create 8 floating icons
    for (int i = 0; i < 8; i++) {
      final icon = securityIcons[random.nextInt(securityIcons.length)];
      final color = colors[random.nextInt(colors.length)];
      final size = 16.0 + random.nextDouble() * 14.0;
      final startX = random.nextDouble() * screenWidth;
      final startY = random.nextDouble() * screenHeight;
      
      _securityIcons.add(
        FloatingSecurityIcon(
          icon: icon,
          color: color,
          size: size,
          startX: startX,
          startY: startY,
        ),
      );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _hideNotificationBox() {
    setState(() {
      _showNotificationBox = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        child: Stack(
          children: [
            // Background shapes for decoration
            Positioned(
              top: -100,
              left: -100,
              child: _buildDecorativeShape(Colors.white.withOpacity(0.05), 250),
            ),
            Positioned(
              bottom: -120,
              right: -150,
              child: _buildDecorativeShape(Colors.white.withOpacity(0.08), 400),
            ),
            // Add floating security icons for decoration
            ..._securityIcons,
            // Add a subtle shimmer effect
            _buildShimmerEffect(),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: _buildBanner(),
                    ),
                    const SizedBox(height: 24),
                    Expanded(
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: _buildFunctionalButtonsGrid(context),
                      ),
                    ),
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: _buildContactInfo(context),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            // Notification box as overlay
            if (_showNotificationBox)
              Positioned(
                bottom: 80,
                left: 20,
                right: 20,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: _buildNotificationPermissionBox(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDecorativeShape(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildGlassmorphicContainer({required Widget child, double padding = 16.0}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20.0),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: Container(
          padding: EdgeInsets.all(padding),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20.0),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildBanner() {
    return _buildGlassmorphicContainer(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.security_update_good_rounded,
            size: 40,
            color: Colors.cyanAccent,
          ),
          const SizedBox(width: 15),
          Flexible(
            child: Text(
              'PHÒNG CHỐNG LỪA ĐẢO',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationPermissionBox() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20.0),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: Container(
          padding: EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20.0),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.notifications_active_rounded, color: Colors.yellowAccent),
                  const SizedBox(width: 10),
                  const Flexible(
                    child: Text(
                      'Bật thông báo để nhận cảnh báo mới nhất',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _hideNotificationBox,
                    child: const Text('Để sau', style: TextStyle(color: Colors.white70)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      // Handle permission request
                      _hideNotificationBox();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.cyanAccent,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Cho phép'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFunctionalButtonsGrid(BuildContext context) {
    final buttons = [
      _buildCircularButton(context, Icons.newspaper_rounded, 'Tin mới', Colors.orangeAccent, () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NewsScreen()))),
      _buildCircularButton(context, Icons.warning_amber_rounded, 'Cảnh báo', Colors.redAccent, () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RiskWarningScreen()))),
      _buildCircularButton(context, Icons.verified_user_rounded, 'Xác thực', Colors.greenAccent, () => Navigator.push(context, MaterialPageRoute(builder: (context) => const VerificationScreen()))),
      _buildCircularButton(context, Icons.person_search_rounded, 'Truy nã', Colors.purpleAccent, () => Navigator.push(context, MaterialPageRoute(builder: (context) => const WantedListScreen()))),
      _buildCircularButton(context, Icons.search_rounded, 'Giám Sát MXH', Colors.tealAccent, () => Navigator.push(context, MaterialPageRoute(builder: (context) => const BotScreen()))),
    ];

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        childAspectRatio: 1.0,
      ),
      itemCount: buttons.length,
      itemBuilder: (context, index) {
        return buttons[index];
      },
      physics: const NeverScrollableScrollPhysics(),
    );
  }

  Widget _buildCircularButton(BuildContext context, IconData icon, String label, Color color, VoidCallback onTap) {
    return AnimatedButton(
      onTap: onTap,
      child: _buildGlassmorphicContainer(
        padding: 0,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 45, color: color),
            const SizedBox(height: 12),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildContactInfo(BuildContext context) {
    return GestureDetector(
      onTap: () => _launchFacebook(context),
      child: _buildGlassmorphicContainer(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.facebook_rounded,
              size: 32,
              color: Colors.lightBlueAccent,
            ),
            const SizedBox(width: 15),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Liên hệ hỗ trợ',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                SizedBox(height: 4),
                Text(
                  'Nhấn để mở Facebook',
                  style: TextStyle(fontSize: 13, color: Colors.white70),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchFacebook(BuildContext context) async {
    const facebookUrl = 'https://www.facebook.com/profile.php?id=61577787821766';
    try {
      await launchUrl(Uri.parse(facebookUrl), mode: LaunchMode.externalApplication);
    } catch (e) {
      if (context.mounted) {
        _showErrorDialog(context);
      }
    }
  }

  void _showErrorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: AlertDialog(
          backgroundColor: const Color(0xFF2c3e50).withOpacity(0.85),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Không thể mở liên kết', style: TextStyle(color: Colors.white)),
          content: const Text('Không thể mở trang Facebook. Vui lòng thử lại sau.', style: TextStyle(color: Colors.white70)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Đóng', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerEffect() {
    return Positioned.fill(
      child: Opacity(
        opacity: 0.03,
        child: ShaderMask(
          shaderCallback: (rect) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.1),
                Colors.white.withOpacity(0.2),
                Colors.white.withOpacity(0.1),
              ],
              stops: const [0.0, 0.5, 1.0],
            ).createShader(rect);
          },
          blendMode: BlendMode.srcOver,
          child: Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.0,
                colors: [
                  Colors.white.withOpacity(0.1),
                  Colors.white.withOpacity(0.05),
                ],
                stops: const [0.0, 1.0],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


// Custom Animated Button for a bit of flair
class AnimatedButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const AnimatedButton({required this.child, required this.onTap, super.key});

  @override
  _AnimatedButtonState createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      reverseDuration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: () => _controller.reverse(),
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}

// Floating security icon for decoration
class FloatingSecurityIcon extends StatefulWidget {
  final IconData icon;
  final Color color;
  final double size;
  final double startX;
  final double startY;

  const FloatingSecurityIcon({
    required this.icon,
    required this.color,
    required this.size,
    required this.startX,
    required this.startY,
    super.key,
  });

  @override
  _FloatingSecurityIconState createState() => _FloatingSecurityIconState();
}

class _FloatingSecurityIconState extends State<FloatingSecurityIcon> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _xAnimation;
  late Animation<double> _yAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 5000 + math.Random().nextInt(5000)),
    );

    // Random movement path
    final endX = widget.startX + (math.Random().nextDouble() - 0.5) * 200;
    final endY = widget.startY + (math.Random().nextDouble() - 0.5) * 200;
    
    _xAnimation = Tween<double>(
      begin: widget.startX,
      end: endX,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    
    _yAnimation = Tween<double>(
      begin: widget.startY,
      end: endY,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    
    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 0.7,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
    
    _controller.forward();
    
    // Loop the animation
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reset();
        
        // Change destination for next animation
        final newEndX = widget.startX + (math.Random().nextDouble() - 0.5) * 200;
        final newEndY = widget.startY + (math.Random().nextDouble() - 0.5) * 200;
        
        _xAnimation = Tween<double>(
          begin: _xAnimation.value,
          end: newEndX,
        ).animate(CurvedAnimation(
          parent: _controller,
          curve: Curves.easeInOut,
        ));
        
        _yAnimation = Tween<double>(
          begin: _yAnimation.value,
          end: newEndY,
        ).animate(CurvedAnimation(
          parent: _controller,
          curve: Curves.easeInOut,
        ));
        
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          left: _xAnimation.value,
          top: _yAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: widget.color.withOpacity(0.3),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(
                  widget.icon,
                  color: widget.color,
                  size: widget.size,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}