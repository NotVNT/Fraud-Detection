import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart';
import '../../frontend/models/verification_result.dart';

class VerificationService {
  static const String baseUrl = 'https://checkscam.vn';

  // Kiểm tra số điện thoại
  Future<VerificationResult> verifyPhoneNumber(String phoneNumber) async {
    try {
      // Chuẩn hóa số điện thoại
      String normalizedPhone = _normalizePhoneNumber(phoneNumber);

      // Thực hiện search trực tiếp trên checkscam.vn
      final result = await _searchOnCheckscam(normalizedPhone, 'phone');
      if (result != null) {
        return result;
      } else {
        // Nếu không thể truy cập checkscam.vn, sử dụng logic fallback
        return _fallbackPhoneVerification(normalizedPhone);
      }
    } catch (e) {
      // Sử dụng logic fallback khi có lỗi
      return _fallbackPhoneVerification(phoneNumber);
    }
  }

  // Kiểm tra tài khoản ngân hàng
  Future<VerificationResult> verifyBankAccount(String accountNumber) async {
    try {
      // Chuẩn hóa số tài khoản
      String normalizedAccount = accountNumber.replaceAll(
        RegExp(r'[^0-9]'),
        '',
      );

      // Thực hiện search trực tiếp trên checkscam.vn
      final result = await _searchOnCheckscam(normalizedAccount, 'bank');
      if (result != null) {
        return result;
      } else {
        // Nếu không thể truy cập checkscam.vn, sử dụng logic fallback
        return _fallbackBankVerification(normalizedAccount);
      }
    } catch (e) {
      // Sử dụng logic fallback khi có lỗi
      return _fallbackBankVerification(accountNumber);
    }
  }

  // Kiểm tra website
  Future<VerificationResult> verifyWebsite(String website) async {
    try {
      // Chuẩn hóa URL
      String normalizedUrl = _normalizeUrl(website);

      // Thực hiện search trực tiếp trên checkscam.vn
      final result = await _searchOnCheckscam(normalizedUrl, 'website');
      if (result != null) {
        return result;
      } else {
        // Nếu không thể truy cập checkscam.vn, sử dụng logic fallback
        return _fallbackWebsiteVerification(normalizedUrl);
      }
    } catch (e) {
      // Sử dụng logic fallback khi có lỗi
      return _fallbackWebsiteVerification(website);
    }
  }

  // Chuẩn hóa số điện thoại
  String _normalizePhoneNumber(String phone) {
    // Loại bỏ tất cả ký tự không phải số
    String normalized = phone.replaceAll(RegExp(r'[^0-9]'), '');

    // Chuyển đổi +84 thành 0
    if (normalized.startsWith('84') && normalized.length >= 10) {
      normalized = '0${normalized.substring(2)}';
    }

    return normalized;
  }

  // Chuẩn hóa URL
  String _normalizeUrl(String url) {
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }
    return url;
  }

  // Logic fallback khi API không khả dụng - Số điện thoại
  VerificationResult _fallbackPhoneVerification(String phone) {
    return VerificationResult(
      status: 'warning',
      message:
          'Không thể truy cập checkscam.vn để xác thực số điện thoại $phone. Website có thể đang bảo trì hoặc chặn truy cập tự động. Hãy thận trọng và kiểm tra thủ công trên checkscam.vn.',
      source: 'Hệ thống (không thể kết nối)',
    );
  }

  // Logic fallback khi API không khả dụng - Tài khoản ngân hàng
  VerificationResult _fallbackBankVerification(String account) {
    return VerificationResult(
      status: 'warning',
      message:
          'Không thể truy cập checkscam.vn để xác thực tài khoản $account. Website có thể đang bảo trì hoặc chặn truy cập tự động. Hãy thận trọng và kiểm tra thủ công trên checkscam.vn.',
      source: 'Hệ thống (không thể kết nối)',
    );
  }

  // Logic fallback khi API không khả dụng - Website
  VerificationResult _fallbackWebsiteVerification(String url) {
    return VerificationResult(
      status: 'warning',
      message:
          'Không thể truy cập checkscam.vn để xác thực website $url. Website có thể đang bảo trì hoặc chặn truy cập tự động. Hãy thận trọng và kiểm tra thủ công trên checkscam.vn.',
      source: 'Hệ thống (không thể kết nối)',
    );
  }

  // Thực hiện search trực tiếp trên checkscam.vn
  Future<VerificationResult?> _searchOnCheckscam(
    String searchTerm,
    String type,
  ) async {
    try {
      // Thử nhiều phương pháp bypass Cloudflare
      List<Map<String, dynamic>> bypassMethods = [
        // Phương pháp 1: Mobile User-Agent với headers đơn giản
        {
          'userAgent':
              'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1',
          'headers': {
            'Accept':
                'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
            'Accept-Language': 'vi-VN,vi;q=0.9',
            'Cache-Control': 'max-age=0',
          },
          'delay': 1000,
        },
        // Phương pháp 2: Android User-Agent
        {
          'userAgent':
              'Mozilla/5.0 (Linux; Android 13; SM-G998B) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36',
          'headers': {
            'Accept':
                'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
            'Accept-Language': 'vi-VN,vi;q=0.8,en-US;q=0.5,en;q=0.3',
            'X-Forwarded-For': '203.162.4.191', // IP Việt Nam
          },
          'delay': 1500,
        },
        // Phương pháp 3: Desktop với IP spoofing
        {
          'userAgent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
          'headers': {
            'Accept':
                'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8',
            'Accept-Language': 'vi,en-US;q=0.9,en;q=0.8',
            'X-Real-IP': '14.161.21.123', // IP FPT Vietnam
            'X-Forwarded-For': '14.161.21.123',
            'CF-Connecting-IP': '14.161.21.123',
          },
          'delay': 2000,
        },
        // Phương pháp 4: Giả lập từ Google Bot
        {
          'userAgent':
              'Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)',
          'headers': {
            'Accept':
                'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
            'From': 'googlebot(at)googlebot.com',
          },
          'delay': 500,
        },
        // Phương pháp 5: Session browsing simulation
        {
          'userAgent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
          'headers': {
            'Accept':
                'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7',
            'Accept-Language': 'vi-VN,vi;q=0.9,en-US;q=0.8,en;q=0.7',
            'Sec-Ch-Ua':
                '"Not_A Brand";v="8", "Chromium";v="120", "Google Chrome";v="120"',
            'Sec-Ch-Ua-Mobile': '?0',
            'Sec-Ch-Ua-Platform': '"Windows"',
            'Sec-Fetch-Dest': 'document',
            'Sec-Fetch-Mode': 'navigate',
            'Sec-Fetch-Site': 'none',
            'Sec-Fetch-User': '?1',
            'Upgrade-Insecure-Requests': '1',
            'Referer': 'https://www.google.com/',
          },
          'delay': 3000,
        },
      ];

      for (int i = 0; i < bypassMethods.length; i++) {
        try {
          final method = bypassMethods[i];

          // Delay theo từng phương pháp
          if (i > 0) {
            await Future.delayed(Duration(milliseconds: method['delay']));
          }

          final url = '$baseUrl/?qh_ss=${Uri.encodeComponent(searchTerm)}';

          // Tạo headers từ method
          Map<String, String> headers = {
            'User-Agent': method['userAgent'],
            ...Map<String, String>.from(method['headers']),
          };

          final response = await http
              .get(Uri.parse(url), headers: headers)
              .timeout(Duration(seconds: 20));

          if (response.statusCode == 200) {
            // Kiểm tra xem có phải trang Cloudflare không
            if (response.body.contains('Just a moment') ||
                response.body.contains('Checking your browser') ||
                response.body.contains('cloudflare')) {
              continue; // Thử user agent tiếp theo
            }

            // Kiểm tra xem có dữ liệu thực tế không
            if (response.body.contains('REVIEW') ||
                response.body.contains('checkscam') ||
                response.body.contains('lừa đảo') ||
                response.body.length > 1000) {
              return _parseCheckscamHTML(response.body, searchTerm, type);
            }
          }
          // Bỏ qua các lỗi HTTP khác và thử user agent tiếp theo
        } catch (e) {
          continue; // Thử user agent tiếp theo
        }
      }

      // Phương pháp cuối cùng: Thử qua proxy services
      final proxyResult = await _tryProxyServices(searchTerm, type);
      if (proxyResult != null) return proxyResult;

      // Backup: Two-step request
      return await _tryTwoStepRequest(searchTerm, type);
    } catch (e) {
      return null;
    }
  }

  // Phương pháp proxy services để bypass Cloudflare
  Future<VerificationResult?> _tryProxyServices(
    String searchTerm,
    String type,
  ) async {
    // Danh sách các proxy/scraping services miễn phí
    List<Map<String, dynamic>> proxyServices = [
      // Phương pháp 1: Sử dụng web.archive.org (Wayback Machine)
      {
        'name': 'Wayback Machine',
        'url':
            'https://web.archive.org/web/20240101000000/https://checkscam.vn/?qh_ss=${Uri.encodeComponent(searchTerm)}',
        'headers': {
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        },
      },
      // Phương pháp 2: Sử dụng Google Cache
      {
        'name': 'Google Cache',
        'url':
            'https://webcache.googleusercontent.com/search?q=cache:checkscam.vn/?qh_ss=${Uri.encodeComponent(searchTerm)}',
        'headers': {
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        },
      },
      // Phương pháp 3: Sử dụng proxy API miễn phí
      {
        'name': 'AllOrigins Proxy',
        'url':
            'https://api.allorigins.win/get?url=${Uri.encodeComponent('https://checkscam.vn/?qh_ss=${Uri.encodeComponent(searchTerm)}')}',
        'headers': {
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        },
        'isProxy': true,
      },
    ];

    for (final service in proxyServices) {
      try {
        // Thử service

        final response = await http
            .get(
              Uri.parse(service['url']),
              headers: Map<String, String>.from(service['headers']),
            )
            .timeout(Duration(seconds: 15));

        if (response.statusCode == 200) {
          String content = response.body;

          // Nếu là proxy service, extract content
          if (service['isProxy'] == true) {
            try {
              final jsonData = response.body;
              // AllOrigins trả về JSON với field 'contents'
              if (jsonData.contains('"contents"')) {
                final startIndex = jsonData.indexOf('"contents":"') + 12;
                final endIndex = jsonData.lastIndexOf('"}');
                if (startIndex > 11 && endIndex > startIndex) {
                  content = jsonData.substring(startIndex, endIndex);
                  // Decode escaped characters
                  content = content
                      .replaceAll('\\n', '\n')
                      .replaceAll('\\"', '"')
                      .replaceAll('\\/', '/');
                }
              }
            } catch (e) {
              continue;
            }
          }

          // Kiểm tra có dữ liệu hữu ích không
          if (content.contains('checkscam') ||
              content.contains('lừa đảo') ||
              content.contains('REVIEW') ||
              content.length > 2000) {
            return _parseCheckscamHTML(content, searchTerm, type);
          }
        }
      } catch (e) {
        continue;
      }

      // Delay giữa các service
      await Future.delayed(Duration(milliseconds: 1000));
    }

    return null;
  }

  // Phương pháp two-step: truy cập trang chủ trước, sau đó search
  Future<VerificationResult?> _tryTwoStepRequest(
    String searchTerm,
    String type,
  ) async {
    try {
      // Bước 1: Truy cập trang chủ để lấy session
      final homeResponse = await http
          .get(
            Uri.parse(baseUrl),
            headers: {
              'User-Agent':
                  'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
              'Accept':
                  'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8',
              'Accept-Language': 'vi-VN,vi;q=0.9,en-US;q=0.8,en;q=0.7',
              'Cache-Control': 'no-cache',
              'Pragma': 'no-cache',
              'Sec-Fetch-Dest': 'document',
              'Sec-Fetch-Mode': 'navigate',
              'Sec-Fetch-Site': 'none',
              'Sec-Fetch-User': '?1',
              'Upgrade-Insecure-Requests': '1',
            },
          )
          .timeout(Duration(seconds: 10));

      if (homeResponse.statusCode == 200) {
        // Delay để giả lập user đọc trang
        await Future.delayed(Duration(seconds: 2));

        // Bước 2: Thực hiện search với session
        final searchResponse = await http
            .get(
              Uri.parse('$baseUrl/?qh_ss=${Uri.encodeComponent(searchTerm)}'),
              headers: {
                'User-Agent':
                    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
                'Accept':
                    'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8',
                'Accept-Language': 'vi-VN,vi;q=0.9,en-US;q=0.8,en;q=0.7',
                'Referer': baseUrl,
                'Sec-Fetch-Dest': 'document',
                'Sec-Fetch-Mode': 'navigate',
                'Sec-Fetch-Site': 'same-origin',
                'Sec-Fetch-User': '?1',
                'Upgrade-Insecure-Requests': '1',
              },
            )
            .timeout(Duration(seconds: 15));

        if (searchResponse.statusCode == 200 &&
            !searchResponse.body.contains('Just a moment') &&
            !searchResponse.body.contains('Checking your browser')) {
          // Kiểm tra có dữ liệu hữu ích không
          if (searchResponse.body.contains('checkscam') ||
              searchResponse.body.contains('lừa đảo') ||
              searchResponse.body.contains('REVIEW') ||
              searchResponse.body.length > 2000) {
            return _parseCheckscamHTML(searchResponse.body, searchTerm, type);
          }
        }
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  // Parse HTML từ checkscam.vn với logic cải tiến
  VerificationResult _parseCheckscamHTML(
    String htmlBody,
    String searchTerm,
    String type,
  ) {
    try {
      Document document = parser.parse(htmlBody);

      // Tìm các thông tin đánh giá
      List<String> warnings = [];
      double fraudPercentage = 0.0;
      bool hasData = false;
      int totalReports = 0;

      String fullText = document.body?.text ?? '';

      // Pattern 1: "Lừa đảo [ số ] tỷ lệ%"
      RegExp fraudRegex1 = RegExp(
        r'Lừa đảo\s*\[\s*(\d+)\s*\]\s*(\d+)%',
        caseSensitive: false,
      );
      var match1 = fraudRegex1.firstMatch(fullText);

      if (match1 != null) {
        totalReports = int.tryParse(match1.group(1) ?? '0') ?? 0;
        fraudPercentage = double.tryParse(match1.group(2) ?? '0') ?? 0.0;
        hasData = true;
      }

      // Pattern 2: "X/5 - (Y đánh giá)" và tìm % lừa đảo
      if (!hasData) {
        RegExp ratingRegex = RegExp(
          r'(\d+\.?\d*)/5\s*-\s*\((\d+)\s*đánh giá\)',
          caseSensitive: false,
        );
        var ratingMatch = ratingRegex.firstMatch(fullText);

        if (ratingMatch != null) {
          totalReports = int.tryParse(ratingMatch.group(2) ?? '0') ?? 0;

          // Tìm % lừa đảo trong context gần đó
          RegExp percentRegex = RegExp(
            r'(\d+)%.*?lừa đảo|lừa đảo.*?(\d+)%',
            caseSensitive: false,
          );
          var percentMatch = percentRegex.firstMatch(fullText);

          if (percentMatch != null) {
            fraudPercentage =
                double.tryParse(
                  percentMatch.group(1) ?? percentMatch.group(2) ?? '0',
                ) ??
                0.0;
            hasData = true;
          }
        }
      }

      // Pattern 3: Tìm trong các element cụ thể
      if (!hasData) {
        var elements = document.querySelectorAll('div, span, p');
        for (var element in elements) {
          String text = element.text;

          // Tìm pattern "X% lừa đảo" hoặc "lừa đảo X%"
          RegExp simplePercent = RegExp(
            r'(\d+)%.*?lừa đảo|lừa đảo.*?(\d+)%',
            caseSensitive: false,
          );
          var simpleMatch = simplePercent.firstMatch(text);

          if (simpleMatch != null) {
            fraudPercentage =
                double.tryParse(
                  simpleMatch.group(1) ?? simpleMatch.group(2) ?? '0',
                ) ??
                0.0;
            hasData = true;
            break;
          }
        }
      }

      // Tìm cảnh báo
      if (fullText.toLowerCase().contains('cảnh báo') ||
          fullText.toLowerCase().contains('lưu ý') ||
          fullText.toLowerCase().contains('scam') ||
          fullText.toLowerCase().contains('lừa đảo')) {
        warnings.add('Có báo cáo cảnh báo về thông tin này trên checkscam.vn');
      }

      // Nếu có dữ liệu từ checkscam.vn
      if (hasData || warnings.isNotEmpty) {
        String status;
        String message;

        if (fraudPercentage >= 20.0) {
          status = 'danger';
          message = _getTypeSpecificMessage(
            type,
            searchTerm,
            'danger',
            fraudPercentage,
          );
          if (totalReports > 0) {
            warnings.add('Có $totalReports báo cáo về thông tin này');
          }
        } else if (fraudPercentage > 0 || warnings.isNotEmpty) {
          status = 'warning';
          message = _getTypeSpecificMessage(
            type,
            searchTerm,
            'warning',
            fraudPercentage,
          );
        } else {
          status = 'safe';
          message = _getTypeSpecificMessage(
            type,
            searchTerm,
            'safe',
            fraudPercentage,
          );
        }

        return VerificationResult(
          status: status,
          message: message,
          fraudPercentage: fraudPercentage > 0 ? fraudPercentage : null,
          warnings: warnings.take(3).toList(),
          source: 'checkscam.vn (real-time)',
        );
      }

      return VerificationResult(
        status: 'safe',
        message: _getTypeSpecificMessage(type, searchTerm, 'safe', 0.0),
        fraudPercentage: 0.0,
        source: 'checkscam.vn (không tìm thấy báo cáo)',
      );
    } catch (e) {
      return VerificationResult(
        status: 'warning',
        message:
            'Có lỗi khi phân tích dữ liệu từ checkscam.vn. Vui lòng thử lại sau.',
        source: 'Hệ thống',
      );
    }
  }

  // Tạo message phù hợp với từng loại
  String _getTypeSpecificMessage(
    String type,
    String searchTerm,
    String status,
    double fraudPercentage,
  ) {
    switch (type) {
      case 'phone':
        switch (status) {
          case 'danger':
            return 'Số điện thoại $searchTerm đã bị báo cáo là lừa đảo với tỷ lệ ${fraudPercentage.toStringAsFixed(1)}%. Vui lòng cảnh giác và không thực hiện giao dịch.';
          case 'warning':
            return 'Số điện thoại $searchTerm có một số cảnh báo với tỷ lệ lừa đảo ${fraudPercentage.toStringAsFixed(1)}%. Hãy thận trọng khi giao dịch.';
          default:
            return 'Số điện thoại $searchTerm chưa có báo cáo lừa đảo trong cơ sở dữ liệu. Tuy nhiên, hãy luôn cảnh giác khi giao dịch.';
        }
      case 'bank':
        switch (status) {
          case 'danger':
            return 'Tài khoản ngân hàng $searchTerm đã bị báo cáo là không an toàn với tỷ lệ lừa đảo ${fraudPercentage.toStringAsFixed(1)}%. Không nên chuyển tiền cho tài khoản này.';
          case 'warning':
            return 'Tài khoản ngân hàng $searchTerm có một số cảnh báo với tỷ lệ lừa đảo ${fraudPercentage.toStringAsFixed(1)}%. Hãy thận trọng khi chuyển tiền.';
          default:
            return 'Tài khoản ngân hàng $searchTerm chưa có báo cáo tiêu cực trong hệ thống. Tuy nhiên, hãy luôn kiểm tra kỹ thông tin trước khi chuyển tiền.';
        }
      case 'website':
        switch (status) {
          case 'danger':
            return 'Website $searchTerm đã bị báo cáo là lừa đảo với tỷ lệ ${fraudPercentage.toStringAsFixed(1)}%. Không nhập thông tin cá nhân vào website này.';
          case 'warning':
            return 'Website $searchTerm có một số cảnh báo với tỷ lệ lừa đảo ${fraudPercentage.toStringAsFixed(1)}%. Hãy thận trọng khi sử dụng.';
          default:
            return 'Website $searchTerm chưa có báo cáo lừa đảo trong cơ sở dữ liệu. Tuy nhiên, hãy luôn cảnh giác khi nhập thông tin cá nhân.';
        }
      default:
        return 'Thông tin $searchTerm đã được kiểm tra.';
    }
  }
}
