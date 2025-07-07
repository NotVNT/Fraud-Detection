import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'bot_scripts_manager.dart';
import 'dart:io' show Platform;

class BotServiceResult {
  final bool success;
  final String message;
  final dynamic data;

  BotServiceResult({
    required this.success,
    required this.message,
    this.data,
  });
}

class BotService {
  final String baseUrl;
  final String apiKey;
  Process? _pythonProcess;
  String? _botId;
  bool _useSelenium = true;
  bool _mobileModeEnabled = false;
  List<String> _processOutput = [];
  List<String> _searchResults = [];
  
  BotService({
    this.baseUrl = 'http://localhost:5000/api/bot',
    this.apiKey = 'your-secret-api-key-change-this',
  });

  Future<Map<String, String>> _getHeaders() async {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
    };
  }

  // Get the path to the application documents directory
  Future<String> _getScriptPath(String scriptName) async {
    final directory = await getApplicationDocumentsDirectory();
    return path.join(directory.path, 'python_scripts', scriptName);
  }

  // Get the path to the screenshots directory
  Future<String> _getScreenshotsDirPath() async {
    final directory = await getApplicationDocumentsDirectory();
    final screenshotsDir = path.join(directory.path, 'search_results');
    
    // Create the directory if it doesn't exist
    final dir = Directory(screenshotsDir);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    
    return screenshotsDir;
  }

  // Check if Python scripts are available, if not copy them from assets
  Future<bool> _ensureScriptsAvailable() async {
    return BotScriptsManager.ensureScriptsAvailable();
  }
  
  // Check if Python can run on this platform
  bool _canRunPython() {
    // Currently, only desktop platforms can run Python directly
    return Platform.isWindows || Platform.isMacOS || Platform.isLinux;
  }

  Future<BotServiceResult> getStatus() async {
    try {
      // Check if we're using direct Python process or API
      if (_pythonProcess != null) {
        return BotServiceResult(
          success: true,
          message: 'Bot is running',
          data: {
            'bot_id': _botId, 
            'running': true,
            'output': _processOutput
          },
        );
      }
      
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/status'),
        headers: headers,
      );

      final responseData = jsonDecode(response.body);
      return BotServiceResult(
        success: response.statusCode == 200,
        message: responseData['message'] ?? 'Got bot status',
        data: responseData,
      );
    } catch (e) {
      return BotServiceResult(
        success: false,
        message: 'Failed to get bot status: $e',
      );
    }
  }

  Future<BotServiceResult> createBot({
    String platform = 'facebook',
    bool headless = true,
    bool mobileMode = false,
    int searchDelay = 2,
    int screenshotDelay = 3,
  }) async {
    // First check if Python scripts are available
    bool scriptsAvailable = await _ensureScriptsAvailable();
    
    if (!scriptsAvailable) {
      return BotServiceResult(
        success: false,
        message: 'Python scripts not available. Please check installation.',
      );
    }
    
    try {
      // Generate a unique bot ID
      _botId = DateTime.now().millisecondsSinceEpoch.toString();
      _mobileModeEnabled = mobileMode;
      _processOutput.clear();
      _searchResults.clear();
      
      // No need to start any process yet until search is requested
      return BotServiceResult(
        success: true,
        message: 'Bot created successfully',
        data: {
          'bot_id': _botId, 
          'platform': platform, 
          'headless': headless,
          'mobile_mode': mobileMode,
        },
      );
    } catch (e) {
      return BotServiceResult(
        success: false,
        message: 'Failed to create bot: $e',
      );
    }
  }

  Future<BotServiceResult> searchKeywords({
    required String botId,
    required List<String> keywords,
    int? scrollCount,
  }) async {
    if (_botId != botId) {
      return BotServiceResult(
        success: false,
        message: 'Invalid bot ID',
      );
    }
    
    try {
      // Check if we can run Python on this platform
      if (!_canRunPython()) {
        // Return a simulated result for mobile platforms
        debugPrint('Python execution is not supported on this platform. Simulating search.');
        
        // Simulate bot searching
        await Future.delayed(const Duration(seconds: 2));
        
        return BotServiceResult(
          success: true,
          message: 'Search simulated for ${keywords.length} keywords',
          data: {
            'bot_id': botId, 
            'keywords': keywords,
            'note': 'This is a simulation. Python scripts cannot run directly on this device.'
          },
        );
      }
      
      // Prepare for the search
      _processOutput.clear();
      _searchResults.clear();
      
      String scriptToRun = _useSelenium 
          ? 'bot_search_automation_selenium.py' 
          : 'bot_search_automation.py';
      
      String scriptPath = await _getScriptPath(scriptToRun);
      
      // Prepare command arguments
      List<String> args = [
        scriptPath,
        '--platform', 'facebook', // Default to facebook
        '--keywords', keywords.join(' '),
        '--search-delay', '3',
        '--screenshot-delay', '2',
      ];
      
      if (_useSelenium) {
        args.add('--headless');
        if (_mobileModeEnabled) {
          args.add('--mobile');
        }
      } else {
        if (_mobileModeEnabled) {
          args.add('--debug'); // Add debug mode for pyautogui
        }
      }
      
      if (scrollCount != null && scrollCount > 0) {
        args.addAll(['--scroll', scrollCount.toString()]);
      }
      
      debugPrint('Running command: python ${args.join(' ')}');
      
      // Start Python process
      _pythonProcess = await Process.start('python', args);
      
      // Set up streams to capture output
      _pythonProcess!.stdout.transform(utf8.decoder).listen((data) {
        debugPrint('Python stdout: $data');
        _processOutput.add(data);
        _checkOutputForScreenshotPaths(data);
      });
      
      _pythonProcess!.stderr.transform(utf8.decoder).listen((data) {
        debugPrint('Python stderr: $data');
        _processOutput.add('[ERROR] $data');
      });
      
      // Wait a moment for the process to start
      await Future.delayed(const Duration(seconds: 1));
      
      return BotServiceResult(
        success: true,
        message: 'Search started with ${keywords.length} keywords',
        data: {'bot_id': botId, 'keywords': keywords},
      );
    } catch (e) {
      return BotServiceResult(
        success: false,
        message: 'Failed to start search: $e',
      );
    }
  }
  
  // Check output from Python script for screenshot file paths
  void _checkOutputForScreenshotPaths(String output) {
    // Look for lines indicating screenshot saved
    final lines = output.split('\n');
    for (var line in lines) {
      if (line.contains('Screenshot saved:')) {
        final pathStart = line.indexOf(':') + 1;
        if (pathStart > 0 && pathStart < line.length) {
          final screenshotPath = line.substring(pathStart).trim();
          if (screenshotPath.isNotEmpty) {
            _searchResults.add(screenshotPath);
          }
        }
      }
    }
  }

  Future<BotServiceResult> getResults(String botId) async {
    if (_botId != botId) {
      return BotServiceResult(
        success: false,
        message: 'Bot not running or invalid bot ID',
      );
    }
    
    try {
      // For mobile platforms, return simulated results
      if (!_canRunPython()) {
        // Simulate finding results
        await Future.delayed(const Duration(seconds: 2));
        
        return BotServiceResult(
          success: true,
          message: 'Search completed (simulated)',
          data: {
            'results': [
              'Simulated search result 1',
              'Simulated search result 2',
              'Simulated search result 3',
            ],
            'status': 'completed',
            'note': 'These are simulated results for demonstration purposes.'
          },
        );
      }
      
      // For desktop platforms with Python
      if (_pythonProcess != null) {
        // Check if the process is still running
        final isRunning = _isProcessRunning();
        
        if (!isRunning) {
          // Process has already finished
          final screenshotsDir = await _getScreenshotsDirPath();
          
          // Collect screenshots from the directory
          if (_searchResults.isEmpty) {
            final dir = Directory(screenshotsDir);
            if (await dir.exists()) {
              final files = await dir.list().toList();
              _searchResults = files
                  .where((file) => file.path.endsWith('.png'))
                  .map((file) => file.path)
                  .toList();
            }
          }
          
          return BotServiceResult(
            success: true,
            message: 'Search completed',
            data: {
              'results': _searchResults,
              'status': 'completed',
              'output': _processOutput,
            },
          );
        }
        
        // Process is still running
        return BotServiceResult(
          success: true,
          message: 'Search in progress',
          data: {
            'results': _searchResults,
            'status': 'in_progress',
            'output': _processOutput,
          },
        );
      }
      
      return BotServiceResult(
        success: false,
        message: 'No active search process',
        data: {
          'results': [],
          'status': 'inactive',
        },
      );
    } catch (e) {
      return BotServiceResult(
        success: false,
        message: 'Failed to get search results: $e',
      );
    }
  }
  
  // Check if the Python process is still running
  bool _isProcessRunning() {
    if (_pythonProcess == null) return false;
    
    try {
      // This will throw if the process is not running
      return _pythonProcess!.pid > 0;
    } catch (e) {
      return false;
    }
  }

  Future<BotServiceResult> closeBot(String botId) async {
    if (_botId != botId) {
      return BotServiceResult(
        success: false,
        message: 'Invalid bot ID',
      );
    }
    
    try {
      if (_pythonProcess != null) {
        try {
          _pythonProcess!.kill(ProcessSignal.sigterm);
        } catch (e) {
          debugPrint('Error killing Python process: $e');
        }
        _pythonProcess = null;
      }
      
      _botId = null;
      _processOutput.clear();
      
      return BotServiceResult(
        success: true,
        message: 'Bot closed',
      );
    } catch (e) {
      return BotServiceResult(
        success: false,
        message: 'Failed to close bot: $e',
      );
    }
  }
  
  // Toggle between Selenium and PyAutoGUI implementations
  void setUseSelenium(bool useSelenium) {
    _useSelenium = useSelenium;
  }
  
  // Set mobile mode
  void setMobileMode(bool mobileMode) {
    _mobileModeEnabled = mobileMode;
  }
} 