import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:photo_view/photo_view.dart';
import '../../backend/services/webview_bot_service.dart';

class BotScreen extends StatefulWidget {
  const BotScreen({Key? key}) : super(key: key);

  @override
  State<BotScreen> createState() => _BotScreenState();
}

class _BotScreenState extends State<BotScreen> {
  final WebViewBotService _botService = WebViewBotService();
  bool _isCreatingBot = false;
  bool _isSearching = false;
  String? _currentBotId;
  String _statusMessage = 'Bot not started';
  List<String> _searchResults = [];
  List<String> _logMessages = [];
  final TextEditingController _keywordsController = TextEditingController();
  final GlobalKey _webViewKey = GlobalKey();
  
  InAppWebViewController? _webViewController;
  final InAppWebViewGroupOptions _options = InAppWebViewGroupOptions(
    crossPlatform: InAppWebViewOptions(
      useShouldOverrideUrlLoading: true,
      mediaPlaybackRequiresUserGesture: false,
      javaScriptEnabled: true,
      javaScriptCanOpenWindowsAutomatically: true,
    ),
    android: AndroidInAppWebViewOptions(
      useHybridComposition: true,
      domStorageEnabled: true,
    ),
    ios: IOSInAppWebViewOptions(
      allowsInlineMediaPlayback: true,
    ),
  );
  
  String _selectedPlatform = 'youtube'; // Default to YouTube
  final List<String> _platforms = ['facebook', 'youtube'];
  
  // Scroll settings
  int _scrollCount = 0;
  final List<int> _scrollOptions = [0, 1, 2, 3, 5, 10];
  
  late StreamSubscription<String> _logSubscription;
  
  @override
  void initState() {
    super.initState();
    _logSubscription = _botService.logStream.listen((message) {
      setState(() {
        _logMessages.add(message);
        if (_logMessages.length > 50) {
          _logMessages.removeAt(0);
        }
      });
    });
  }
  
  @override
  void dispose() {
    _keywordsController.dispose();
    _closeBot();
    _logSubscription.cancel();
    _botService.dispose();
    super.dispose();
  }
  
  Future<void> _createBot() async {
    setState(() {
      _isCreatingBot = true;
      _statusMessage = 'Creating bot...';
      _searchResults.clear();
    });
    
    final result = await _botService.createBot(
      platform: _selectedPlatform,
    );
    
    if (result.success) {
      _currentBotId = result.data['bot_id'];
      setState(() {
        _isCreatingBot = false;
        _statusMessage = 'Bot created: $_currentBotId';
      });
    } else {
      setState(() {
        _isCreatingBot = false;
        _statusMessage = 'Failed to create bot: ${result.message}';
      });
    }
  }
  
  Future<void> _searchKeywords() async {
    if (_currentBotId == null || _keywordsController.text.isEmpty) {
      setState(() {
        _statusMessage = 'Please create a bot and enter keywords';
      });
      return;
    }
    
    final keywords = _keywordsController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    
    if (keywords.isEmpty) {
      setState(() {
        _statusMessage = 'Please enter valid keywords';
      });
      return;
    }
    
    setState(() {
      _isSearching = true;
      _statusMessage = 'Launching external browser for search...';
      _searchResults.clear();
    });

    // Show screenshot instructions
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Chrome will open. When search results appear, take a screenshot by pressing volume down + power button.',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        duration: Duration(seconds: 5),
      ),
    );
    
    final result = await _botService.searchKeywords(
      botId: _currentBotId!,
      keywords: keywords,
      scrollCount: _scrollCount,
    );
    
    setState(() {
      _isSearching = false;
      if (result.success) {
        _statusMessage = 'Search completed for ${keywords.length} keywords';
        if (result.data != null && result.data['results'] != null) {
          _searchResults = List<String>.from(result.data['results']);
        }
        
        // If no screenshots were captured automatically, show a message
        if (_searchResults.isEmpty) {
          _statusMessage = 'No screenshots were captured. Return to app and check results.';
        }
      } else {
        _statusMessage = 'Failed to search: ${result.message}';
      }
    });
  }
  
  Future<void> _closeBot() async {
    if (_currentBotId != null) {
      await _botService.closeBot(_currentBotId!);
      setState(() {
        _currentBotId = null;
        _statusMessage = 'Bot closed';
        _isSearching = false;
      });
    }
  }
  
  /// Display a screenshot image in a dialog with zoom capability
  void _showScreenshotViewer(BuildContext context, String imagePath) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(8),
        child: Stack(
          children: [
            // Image viewer with zoom capability
            Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: PhotoView(
                  imageProvider: FileImage(File(imagePath)),
                  loadingBuilder: (context, event) => Center(
                    child: Container(
                      width: 40.0,
                      height: 40.0,
                      child: CircularProgressIndicator(
                        value: event == null
                            ? 0
                            : event.cumulativeBytesLoaded / event.expectedTotalBytes!,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.error_outline, color: Colors.red, size: 48),
                            const SizedBox(height: 16),
                            Text(
                              'Failed to load image: $error',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  backgroundDecoration: const BoxDecoration(color: Colors.transparent),
                  minScale: PhotoViewComputedScale.contained,
                  maxScale: PhotoViewComputedScale.covered * 2,
                  initialScale: PhotoViewComputedScale.contained,
                ),
              ),
            ),
            
            // Close button
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.black87),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
            
            // Image filename
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.image, size: 16),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          '${imagePath.split('/').last}',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // Zoom instructions
            Positioned(
              top: 16,
              left: 16,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: const Row(
                  children: [
                    Icon(Icons.pinch, size: 16, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'Pinch to zoom',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Social Media Monitor'),
        backgroundColor: const Color(0xFF3f51b5),
        foregroundColor: Colors.white,
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
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Hidden WebView for running the bot
                SizedBox(
                  height: 1, // Almost invisible
                  child: InAppWebView(
                    key: _webViewKey,
                    initialOptions: _options,
                    onWebViewCreated: (controller) {
                      _webViewController = controller;
                      _botService.setWebViewController(controller);
                    },
                    onLoadStop: (controller, url) {
                      debugPrint('Page loaded: $url');
                    },
                    onConsoleMessage: (controller, consoleMessage) {
                      debugPrint('Console: ${consoleMessage.message}');
                    },
                  ),
                ),
                
                // Main UI
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Platform selection
                        Card(
                          color: Colors.white.withOpacity(0.15),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Select Platform:',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                DropdownButtonFormField<String>(
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.white.withOpacity(0.9),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  value: _selectedPlatform,
                                  items: _platforms.map((platform) {
                                    return DropdownMenuItem<String>(
                                      value: platform,
                                      child: Text(platform.toUpperCase()),
                                    );
                                  }).toList(),
                                  onChanged: _isCreatingBot || _isSearching
                                      ? null
                                      : (value) {
                                          if (value != null) {
                                            setState(() {
                                              _selectedPlatform = value;
                                            });
                                          }
                                        },
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Keywords input
                        Card(
                          color: Colors.white.withOpacity(0.15),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Keywords (comma-separated):',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: _keywordsController,
                                  enabled: !_isSearching,
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.white.withOpacity(0.9),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    hintText: 'e.g. new products, trending, latest news',
                                  ),
                                  maxLines: 2,
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // External browser instructions card
                        Card(
                          color: Colors.white.withOpacity(0.15),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.info_outline, color: Colors.white),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'How it works:',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  '1. Enter your search keywords above\n'
                                  '2. Click Search to open Chrome with YouTube\n'
                                  '3. When results appear, take a screenshot (Power + Volume Down)\n'
                                  '4. Return to this app to view your captured images',
                                  style: TextStyle(
                                    color: Colors.white,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Status message
                        Card(
                          color: Colors.white.withOpacity(0.15),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Status:',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _statusMessage,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Action buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                icon: Icon(_currentBotId == null ? Icons.play_arrow : Icons.refresh),
                                label: Text(_currentBotId == null ? 'Start Bot' : 'Restart Bot'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green.shade700,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                                onPressed: _isCreatingBot || _isSearching ? null : _createBot,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.search),
                                label: const Text('Search'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue.shade700,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                                onPressed: _currentBotId == null || _isSearching ? null : _searchKeywords,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.stop),
                                label: const Text('Stop Bot'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red.shade700,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                                onPressed: _currentBotId == null ? null : _closeBot,
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Search results
                        if (_searchResults.isNotEmpty)
                          Card(
                            color: Colors.white.withOpacity(0.15),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Screenshots:',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        '${_searchResults.length} items',
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  SizedBox(
                                    height: 220,
                                    child: ListView.builder(
                                      itemCount: _searchResults.length,
                                      itemBuilder: (context, index) {
                                        final result = _searchResults[index];
                                        final filename = result.split('/').last;
                                        
                                        return Card(
                                          margin: const EdgeInsets.symmetric(vertical: 4),
                                          color: Colors.white.withOpacity(0.9),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                            side: BorderSide(
                                              color: Colors.blue.withOpacity(0.3),
                                              width: 1,
                                            ),
                                          ),
                                          elevation: 2,
                                          child: InkWell(
                                            onTap: () => _showScreenshotViewer(context, result),
                                            borderRadius: BorderRadius.circular(8),
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                                              child: Row(
                                                children: [
                                                  Container(
                                                    width: 36,
                                                    height: 36,
                                                    decoration: BoxDecoration(
                                                      color: Colors.blue.shade100,
                                                      borderRadius: BorderRadius.circular(6),
                                                    ),
                                                    child: const Icon(Icons.image, color: Colors.blue, size: 22),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Expanded(
                                                    child: Text(
                                                      filename,
                                                      style: TextStyle(
                                                        color: Colors.blue.shade800,
                                                        decoration: TextDecoration.underline,
                                                      ),
                                                    ),
                                                  ),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                    decoration: BoxDecoration(
                                                      color: Colors.blue.shade100,
                                                      borderRadius: BorderRadius.circular(12),
                                                    ),
                                                    child: const Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        Icon(Icons.visibility, size: 14, color: Colors.blue),
                                                        SizedBox(width: 4),
                                                        Text('View', style: TextStyle(fontSize: 12, color: Colors.blue)),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        
                        const SizedBox(height: 16),
                        
                        // Log messages
                        Card(
                          color: Colors.white.withOpacity(0.15),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Bot Log:',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  height: 100,
                                  child: ListView.builder(
                                    itemCount: _logMessages.length,
                                    itemBuilder: (context, index) {
                                      return Text(
                                        _logMessages[index],
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
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
} 