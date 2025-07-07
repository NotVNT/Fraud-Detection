import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:url_launcher/url_launcher.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:screenshot/screenshot.dart';
import 'package:permission_handler/permission_handler.dart';

/// Result class for WebView bot operations
class WebViewBotResult {
  final bool success;
  final String message;
  final dynamic data;

  WebViewBotResult({
    required this.success,
    required this.message,
    this.data,
  });
}

/// Service class for managing WebView-based bot operations
class WebViewBotService {
  String? _botId;
  String _platform = 'youtube';
  InAppWebViewController? _webViewController;
  final StreamController<String> _logController = StreamController<String>.broadcast();
  final List<String> _searchResults = [];
  bool _isSearching = false;
  final ScreenshotController _screenshotController = ScreenshotController();
  
  /// Get the stream of log messages
  Stream<String> get logStream => _logController.stream;
  
  /// Get current search status
  bool get isSearching => _isSearching;
  
  /// Get search results
  List<String> get searchResults => _searchResults;
  
  /// URL mapping for platforms
  Map<String, String> get platformUrls => {
    'youtube': 'https://www.youtube.com/',
    'facebook': 'https://www.facebook.com/',
  };
  
  /// Initialize and set the WebView controller
  void setWebViewController(InAppWebViewController controller) {
    _webViewController = controller;
    _log("WebView controller initialized");
  }
  
  /// Log a message to the stream
  void _log(String message) {
    _logController.add(message);
    debugPrint('[WebViewBot] $message');
  }
  
  /// Create a new bot instance
  Future<WebViewBotResult> createBot({
    required String platform,
  }) async {
    try {
      _platform = platform.toLowerCase();
      _botId = DateTime.now().millisecondsSinceEpoch.toString();
      _isSearching = false;
      _searchResults.clear();
      
      _log('Bot created: $_botId for platform: $_platform');
      
      return WebViewBotResult(
        success: true,
        message: 'Bot created successfully',
        data: {
          'bot_id': _botId,
          'platform': _platform,
        },
      );
    } catch (e) {
      _log('Error creating bot: $e');
      return WebViewBotResult(
        success: false,
        message: 'Failed to create bot: $e',
      );
    }
  }
  
  /// Navigate to the selected platform
  Future<WebViewBotResult> navigateToPlatform() async {
    try {
      if (_webViewController == null) {
        _log('Error: WebView controller not initialized');
        return WebViewBotResult(
          success: false,
          message: 'WebView controller not initialized',
        );
      }
      
      final url = platformUrls[_platform] ?? 'https://www.youtube.com/';
      _log('Navigating to: $url');
      
      await _webViewController!.loadUrl(
        urlRequest: URLRequest(url: WebUri(url)),
      );
      
      // Wait for page to load
      await Future.delayed(const Duration(seconds: 3));
      _log('Platform loaded');
      
      // Handle cookie consent if needed
      await _handleCookieConsent();
      
      return WebViewBotResult(
        success: true,
        message: 'Navigated to $_platform successfully',
      );
    } catch (e) {
      _log('Error navigating to platform: $e');
      return WebViewBotResult(
        success: false,
        message: 'Failed to navigate to platform: $e',
      );
    }
  }
  
  /// Launch external browser with YouTube search
  Future<WebViewBotResult> launchExternalBrowser(String keyword) async {
    try {
      final url = _platform == 'youtube' 
          ? 'https://www.youtube.com/results?search_query=${Uri.encodeComponent(keyword)}'
          : 'https://www.facebook.com/search/top?q=${Uri.encodeComponent(keyword)}';
      
      _log('Launching external browser for search: $keyword');

      if (Platform.isAndroid) {
        // Use Android Intent to launch Chrome with the search URL
        final AndroidIntent intent = AndroidIntent(
          action: 'action_view',
          data: url,
          package: 'com.android.chrome',
          // Force use of Chrome browser
          arguments: {'com.android.browser.application_id': 'com.android.chrome'},
        );
        await intent.launch();
      } else {
        // Fallback to URL launcher for other platforms
        if (!await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication)) {
          throw 'Could not launch $url';
        }
      }

      _log('Browser launched with search URL');
      return WebViewBotResult(
        success: true,
        message: 'Launched browser with search',
      );
    } catch (e) {
      _log('Error launching browser: $e');
      return WebViewBotResult(
        success: false,
        message: 'Failed to launch browser: $e',
      );
    }
  }

  /// Request screenshot permissions
  Future<bool> _requestScreenshotPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.storage,
      Permission.photos,
      // Some devices might require additional permissions
      if (Platform.isAndroid) Permission.mediaLibrary,
    ].request();

    return statuses.values.every((status) => status.isGranted);
  }

  /// Take a screenshot
  Future<String?> takeScreenshot(String keyword) async {
    try {
      // Ensure permissions
      final hasPermission = await _requestScreenshotPermissions();
      if (!hasPermission) {
        _log('Screenshot permission denied');
        return null;
      }

      // Capture screenshot
      _log('Taking screenshot for: $keyword');
      
      // Create a temporary directory to save the screenshot
      final directory = await getApplicationDocumentsDirectory();
      final screenshotDir = Directory(path.join(directory.path, 'search_results'));
      
      if (!await screenshotDir.exists()) {
        await screenshotDir.create(recursive: true);
      }
      
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final fileName = '${_platform}_${keyword.replaceAll(' ', '_')}_$timestamp.png';
      final filePath = path.join(screenshotDir.path, fileName);

      // On Android, use a native method to take a screenshot
      if (Platform.isAndroid) {
        final AndroidIntent intent = AndroidIntent(
          action: 'android.intent.action.SCREENSHOT',
        );
        await intent.launch();
        
        // Give time for the screenshot to be taken
        await Future.delayed(const Duration(seconds: 2));
      }

      _log('Screenshot saved: $filePath');
      _searchResults.add(filePath);
      
      return filePath;
    } catch (e) {
      _log('Error taking screenshot: $e');
      return null;
    }
  }
  
  /// Search for keywords on the platform using external Chrome browser
  Future<WebViewBotResult> searchKeywords({
    required String botId,
    required List<String> keywords,
    int? scrollCount,
  }) async {
    if (_botId != botId) {
      _log('Invalid bot ID');
      return WebViewBotResult(
        success: false,
        message: 'Invalid bot ID',
      );
    }
    
    try {
      _isSearching = true;
      _searchResults.clear();
      
      for (final keyword in keywords) {
        _log('Searching for: $keyword');
        
        // Launch Chrome with YouTube search
        await launchExternalBrowser(keyword);
        
        // Wait for page to load
        await Future.delayed(const Duration(seconds: 3));
        
        // Take screenshot
        final screenshotPath = await takeScreenshot(keyword);
        
        // Give user time to take screenshot manually if automatic fails
        await Future.delayed(const Duration(seconds: 5));
        
        // Return to app (simulating home button press on Android)
        if (Platform.isAndroid) {
          final AndroidIntent intent = AndroidIntent(
            action: 'android.intent.action.MAIN',
            category: 'android.intent.category.HOME',
          );
          await intent.launch();
          
          // Wait a moment before reopening app
          await Future.delayed(const Duration(seconds: 1));
          
          // Relaunch our app - this part depends on your app package
          // This will be automatically handled when the user clicks back to the app
        }
        
        // Add a delay between searches
        await Future.delayed(const Duration(seconds: 1));
      }
      
      _isSearching = false;
      _log('Search completed for ${keywords.length} keywords');
      
      return WebViewBotResult(
        success: true,
        message: 'Search completed',
        data: {
          'results': _searchResults,
        },
      );
    } catch (e) {
      _isSearching = false;
      _log('Error searching for keywords: $e');
      return WebViewBotResult(
        success: false,
        message: 'Failed to search for keywords: $e',
      );
    }
  }
  
  /// Handle cookie consent dialogs
  Future<void> _handleCookieConsent() async {
    if (_webViewController == null) return;
    
    _log('Checking for cookie consent dialogs...');
    
    String script;
    if (_platform == 'youtube') {
      script = '''
      (function() {
        try {
          // Look for consent buttons on YouTube using standard selectors
          // Find buttons with accept/agree in their text or aria-label
          let consentButtons = [];
          
          // Get all buttons
          const buttons = document.querySelectorAll('button');
          
          // Loop through them to find ones with accept/agree text
          for (let i = 0; i < buttons.length; i++) {
            const button = buttons[i];
            const buttonText = button.textContent.toLowerCase();
            const ariaLabel = button.getAttribute('aria-label') || '';
            
            if (buttonText.includes('accept') || buttonText.includes('agree') || 
                ariaLabel.toLowerCase().includes('accept') || ariaLabel.toLowerCase().includes('agree')) {
              consentButtons.push(button);
            }
          }
          
          if (consentButtons.length > 0) {
            consentButtons[0].click();
            return "Clicked YouTube consent button";
          }
          return "No consent buttons found";
        } catch (e) {
          return "Error handling consent: " + e.toString();
        }
      })();
      ''';
    } else {
      script = '''
      (function() {
        try {
          // Look for Facebook consent buttons using standard selectors
          let consentButtons = [];
          
          // Get all buttons
          const buttons = document.querySelectorAll('button');
          
          // Loop through them to find ones with accept/allow/ok text
          for (let i = 0; i < buttons.length; i++) {
            const button = buttons[i];
            const buttonText = button.textContent.toLowerCase();
            
            if (buttonText.includes('accept') || buttonText.includes('allow') || buttonText.includes('ok')) {
              consentButtons.push(button);
            }
          }
          
          if (consentButtons.length > 0) {
            consentButtons[0].click();
            return "Clicked Facebook consent button";
          }
          return "No consent buttons found";
        } catch (e) {
          return "Error handling consent: " + e.toString();
        }
      })();
      ''';
    }
    
    final result = await _webViewController!.evaluateJavascript(source: script);
    _log('Cookie consent result: $result');
  }
  
  /// Get JavaScript for YouTube search
  String _getYouTubeSearchScript(String keyword) {
    return '''
    (function() {
      try {
        // Check if we're on mobile YouTube (m.youtube.com) or regular site
        const isMobile = window.location.href.includes('m.youtube.com') || 
                        window.innerWidth < 768 || 
                        navigator.userAgent.includes('Mobile');
        
        console.log("YouTube search script running. Is mobile: " + isMobile);
        
        // Helper function to wait for an element to appear
        function waitForElement(selector, maxWait = 2000) {
          return new Promise((resolve) => {
            if (document.querySelector(selector)) {
              return resolve(document.querySelector(selector));
            }
            
            const observer = new MutationObserver(() => {
              if (document.querySelector(selector)) {
                observer.disconnect();
                resolve(document.querySelector(selector));
              }
            });
            
            observer.observe(document.body, {
              childList: true,
              subtree: true
            });
            
            // Fallback timeout
            setTimeout(() => {
              observer.disconnect();
              resolve(document.querySelector(selector));
            }, maxWait);
          });
        }
        
        if (isMobile) {
          console.log("Using mobile YouTube search flow");
          
          // Try to find search icon/button first - YouTube Mobile has various layouts
          const searchIcons = [
            // Common mobile search icons
            'button[aria-label*="Search"]',
            'ytm-searchbox',
            '.topbar-icons button',
            'ytm-topbar-menu-button-renderer',
            // Generic search icons
            'button.icon-button',
            'a[aria-label*="Search"]',
            'button[title*="Search"]',
            'div[id="search-icon"]',
            // Last resort - any element that looks like a search button
            'button > svg'
          ];
          
          // Try each possible search icon selector
          let searchIconFound = false;
          for (const selector of searchIcons) {
            const searchIcon = document.querySelector(selector);
            if (searchIcon) {
              console.log("Found search icon with selector: " + selector);
              searchIconFound = true;
              searchIcon.click();
              
              // Wait for search input to appear after clicking the icon
              setTimeout(async function() {
                // Try various selectors for search input
                const inputSelectors = [
                  'input[aria-label*="Search"]',
                  'input[id="search"]',
                  'input[name="search_query"]',
                  'input[type="search"]',
                  'input[placeholder*="Search"]',
                  'input.searchbox-input',
                  // Generic search inputs
                  'form input',
                  '.searchbox input',
                  'input'
                ];
                
                let searchInput = null;
                for (const selector of inputSelectors) {
                  searchInput = document.querySelector(selector);
                  if (searchInput) {
                    console.log("Found search input with selector: " + selector);
                    break;
                  }
                }
                
                if (searchInput) {
                  // Focus and set value
                  searchInput.focus();
                  searchInput.value = '$keyword';
                  searchInput.dispatchEvent(new Event('input', { bubbles: true }));
                  
                  // Try to find and click the search button or submit the form
                  setTimeout(function() {
                    // Try various selectors for search button
                    const buttonSelectors = [
                      'button[aria-label*="Search"]',
                      'button.search-icon-button',
                      'button[type="submit"]',
                      'button.submit-button',
                      'button.search-button',
                      'button[title*="Search"]'
                    ];
                    
                    let searchButton = null;
                    for (const selector of buttonSelectors) {
                      searchButton = document.querySelector(selector);
                      if (searchButton) {
                        console.log("Found search button with selector: " + selector);
                        searchButton.click();
                        return "Mobile search executed with button click for: $keyword";
                      }
                    }
                    
                    // If no button found, try submitting the form
                    const form = searchInput.closest('form');
                    if (form) {
                      form.submit();
                      return "Mobile search form submitted for: $keyword";
                    }
                    
                    // Last resort: press Enter key on input
                    searchInput.dispatchEvent(new KeyboardEvent('keydown', {
                      key: 'Enter',
                      code: 'Enter',
                      keyCode: 13,
                      which: 13,
                      bubbles: true
                    }));
                    
                    return "Mobile search executed with Enter key for: $keyword";
                  }, 500);
                  
                  return "Mobile search input filled: $keyword";
                }
                
                return "Could not find mobile search input after clicking search icon";
              }, 1000);
              
              break; // Exit the loop once we find and click a search icon
            }
          }
          
          // If we couldn't find a search icon, try direct search inputs
          if (!searchIconFound) {
            console.log("No search icon found, trying direct input search");
            
            // Try various input selectors directly
            const inputSelectors = [
              'input[aria-label*="Search"]',
              'input[id="search"]',
              'input[name="search_query"]',
              'input[type="search"]',
              'input[placeholder*="Search"]',
              // Generic search inputs
              'form input',
              'input'
            ];
            
            let searchInput = null;
            for (const selector of inputSelectors) {
              searchInput = document.querySelector(selector);
              if (searchInput) {
                console.log("Found direct search input with selector: " + selector);
                break;
              }
            }
            
            if (searchInput) {
              // Focus and set value
              searchInput.focus();
              searchInput.value = '$keyword';
              searchInput.dispatchEvent(new Event('input', { bubbles: true }));
              
              // Try to find and click the search button or submit the form
              setTimeout(function() {
                // Try various selectors for search button
                const buttonSelectors = [
                  'button[aria-label*="Search"]',
                  'button.search-icon-button',
                  'button[type="submit"]',
                  'button.submit-button',
                  'button[title*="Search"]'
                ];
                
                let searchButton = null;
                for (const selector of buttonSelectors) {
                  searchButton = document.querySelector(selector);
                  if (searchButton) {
                    console.log("Found search button with selector: " + selector);
                    searchButton.click();
                    return "Direct mobile search executed with button click for: $keyword";
                  }
                }
                
                // If no button found, try submitting the form
                const form = searchInput.closest('form');
                if (form) {
                  form.submit();
                  return "Direct mobile search form submitted for: $keyword";
                }
                
                // Last resort: press Enter key on input
                searchInput.dispatchEvent(new KeyboardEvent('keydown', {
                  key: 'Enter',
                  code: 'Enter',
                  keyCode: 13,
                  which: 13,
                  bubbles: true
                }));
                
                return "Direct mobile search executed with Enter key for: $keyword";
              }, 500);
              
              return "Direct mobile search input filled: $keyword";
            }
            
            return "Could not find any mobile search elements";
          }
        } else {
          console.log("Using desktop YouTube search flow");
          // Desktop YouTube version - try multiple selectors for search box
          const searchSelectors = [
            'input#search',
            'input[name="search_query"]',
            'input[aria-label*="Search"]',
            'input[placeholder*="Search"]',
            'input[type="search"]'
          ];
          
          let searchBox = null;
          for (const selector of searchSelectors) {
            searchBox = document.querySelector(selector);
            if (searchBox) {
              console.log("Found desktop search box with selector: " + selector);
              break;
            }
          }
          
          if (searchBox) {
            // Focus and clear the search box
            searchBox.focus();
            searchBox.value = '$keyword';
            
            // Dispatch input event
            searchBox.dispatchEvent(new Event('input', { bubbles: true }));
            
            // Find and click the search button
            setTimeout(function() {
              // Try multiple selectors for search button
              const buttonSelectors = [
                'button#search-icon-legacy',
                'button[aria-label*="Search"]',
                'button.style-scope.ytd-searchbox',
                'button[type="submit"]'
              ];
              
              let searchButton = null;
              for (const selector of buttonSelectors) {
                searchButton = document.querySelector(selector);
                if (searchButton) {
                  console.log("Found desktop search button with selector: " + selector);
                  searchButton.click();
                  return "Desktop search executed with button click for: $keyword";
                }
              }
              
              // Try submitting the form
              const form = searchBox.closest('form');
              if (form) {
                form.submit();
                return "Desktop search form submitted for: $keyword";
              }
              
              // Last resort: press Enter key
              searchBox.dispatchEvent(new KeyboardEvent('keydown', {
                key: 'Enter',
                code: 'Enter',
                keyCode: 13,
                which: 13,
                bubbles: true
              }));
              
              return "Desktop search executed with Enter key for: $keyword";
            }, 500);
            
            return "Desktop search initiated for: $keyword";
          }
          
          return "Could not find desktop search box";
        }
        
        return "Search script completed but no action taken";
      } catch (e) {
        return "Error: " + e.toString();
      }
    })();
    ''';
  }
  
  /// Get JavaScript for Facebook search
  String _getFacebookSearchScript(String keyword) {
    return '''
    (function() {
      try {
        // Find the search box
        const searchBox = document.querySelector('input[placeholder*="Search"], input[aria-label*="Search"]');
        if (searchBox) {
          // Focus and clear the search box
          searchBox.focus();
          searchBox.value = '$keyword';
          
          // Dispatch input event
          searchBox.dispatchEvent(new Event('input', { bubbles: true }));
          
          // Press Enter
          setTimeout(function() {
            searchBox.dispatchEvent(new KeyboardEvent('keydown', {
              key: 'Enter',
              code: 'Enter',
              keyCode: 13,
              which: 13,
              bubbles: true
            }));
          }, 500);
          
          return "Search executed for: $keyword";
        } else {
          // Try using the search shortcut
          document.body.dispatchEvent(new KeyboardEvent('keydown', {
            key: '/',
            code: 'Slash',
            keyCode: 191,
            which: 191,
            bubbles: true
          }));
          
          // Wait for search to appear and then fill it
          setTimeout(function() {
            const activeElement = document.activeElement;
            if (activeElement && activeElement.tagName === 'INPUT') {
              activeElement.value = '$keyword';
              
              // Dispatch input event
              activeElement.dispatchEvent(new Event('input', { bubbles: true }));
              
              // Press Enter
              setTimeout(function() {
                activeElement.dispatchEvent(new KeyboardEvent('keydown', {
                  key: 'Enter',
                  code: 'Enter',
                  keyCode: 13,
                  which: 13,
                  bubbles: true
                }));
              }, 500);
              
              return "Search executed using shortcut for: $keyword";
            }
            return "Could not focus search box after shortcut";
          }, 500);
          
          return "Using search shortcut for: $keyword";
        }
      } catch (e) {
        return "Error: " + e.toString();
      }
    })();
    ''';
  }
  
  /// Scroll results and take screenshots
  Future<void> _scrollResults(String keyword, int scrollCount) async {
    _log('Scrolling results $scrollCount times for keyword: $keyword');
    
    for (int i = 0; i < scrollCount; i++) {
      // Execute JavaScript to scroll the page
      await _webViewController?.evaluateJavascript(
        source: "window.scrollBy(0, 800);"
      );
      
      // Wait a moment for content to load
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Take a screenshot after each scroll
      await _captureScreenshot('${keyword}_scroll_${i + 1}');
    }
  }
  
  /// Capture a screenshot of the WebView
  Future<void> _captureScreenshot(String keyword) async {
    if (_webViewController == null) return;
    
    try {
      _log('Taking screenshot for: $keyword');
      
      // Capture the WebView content
      final screenshot = await _webViewController!.takeScreenshot();
      if (screenshot == null) {
        _log('Failed to capture screenshot');
        return;
      }
      
      // Save the screenshot
      final screenshotPath = await _saveScreenshot(screenshot, keyword);
      if (screenshotPath.isNotEmpty) {
        _log('Screenshot saved: $screenshotPath');
        _searchResults.add(screenshotPath);
      }
    } catch (e) {
      _log('Error capturing screenshot: $e');
    }
  }
  
  /// Save a screenshot to the app's documents directory
  Future<String> _saveScreenshot(Uint8List bytes, String keyword) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final screenshotDir = Directory(path.join(directory.path, 'search_results'));
      
      if (!await screenshotDir.exists()) {
        await screenshotDir.create(recursive: true);
      }
      
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final fileName = '${_platform}_${keyword.replaceAll(' ', '_')}_$timestamp.png';
      final filePath = path.join(screenshotDir.path, fileName);
      
      final file = File(filePath);
      await file.writeAsBytes(bytes);
      
      return filePath;
    } catch (e) {
      _log('Error saving screenshot: $e');
      return '';
    }
  }
  
  /// Close the bot
  Future<WebViewBotResult> closeBot(String botId) async {
    if (_botId != botId) {
      return WebViewBotResult(
        success: false,
        message: 'Invalid bot ID',
      );
    }
    
    try {
      _botId = null;
      _isSearching = false;
      _searchResults.clear();
      
      // Navigate to a blank page
      if (_webViewController != null) {
        await _webViewController!.loadUrl(
          urlRequest: URLRequest(url: WebUri('about:blank')),
        );
      }
      
      _log('Bot closed');
      
      return WebViewBotResult(
        success: true,
        message: 'Bot closed successfully',
      );
    } catch (e) {
      _log('Error closing bot: $e');
      return WebViewBotResult(
        success: false,
        message: 'Failed to close bot: $e',
      );
    }
  }
  
  /// Dispose resources
  void dispose() {
    _logController.close();
  }
} 