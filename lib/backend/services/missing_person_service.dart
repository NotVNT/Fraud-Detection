import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart';
import '../../frontend/models/missing_person.dart';

class MissingPersonService {
  // Các nguồn có thể lấy dữ liệu người mất tích
  static const String timNguoiThatLacBaseUrl = 'http://timnguoithatlac.vn';
  static const String timNguoiThatLacListUrl =
      '$timNguoiThatLacBaseUrl/vn/Danh-sach-ho-so.html?type=3';
  static const String facebookGroupUrl =
      'https://www.facebook.com/groups/727437184066329';

  /// Lấy danh sách người mất tích từ timnguoithatlac.vn
  Future<List<MissingPerson>> fetchMissingPersons({int page = 1}) async {
    try {
      final String url = page > 1
          ? '$timNguoiThatLacListUrl&page=$page'
          : timNguoiThatLacListUrl;

      print('Fetching missing persons from: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
          'Accept':
              'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
          'Accept-Language': 'vi-VN,vi;q=0.9,en;q=0.8',
        },
      );

      if (response.statusCode == 200) {
        Document document = parser.parse(response.body);

        List<MissingPerson> missingPersons = [];

        // Tìm tất cả các profile cards trong trang
        final profileElements = document.querySelectorAll(
          'a[href*="profile.php?profile_type=3"]',
        );

        for (var profileLink in profileElements) {
          try {
            // Lấy URL chi tiết
            final detailUrl = profileLink.attributes['href'];
            final fullDetailUrl = detailUrl?.startsWith('http') == true
                ? detailUrl!
                : '$timNguoiThatLacBaseUrl$detailUrl';

            // Lấy tiêu đề từ link
            final title = profileLink.text.trim();

            // Tìm container chứa thông tin chi tiết
            Element? container = profileLink.parent;
            while (container != null && !_isProfileContainer(container)) {
              container = container.parent;
            }

            if (container != null) {
              final personData = _extractPersonDataFromContainer(
                container,
                title,
                fullDetailUrl,
              );
              if (personData != null) {
                missingPersons.add(personData);
              }
            }
          } catch (e) {
            print('Error parsing profile: $e');
            continue;
          }
        }

        return missingPersons;
      } else {
        throw Exception('Không thể tải dữ liệu: Mã lỗi ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching missing persons: $e');
      rethrow;
    }
  }

  /// Kiểm tra xem element có phải là container chứa thông tin profile không
  bool _isProfileContainer(Element element) {
    final text = element.text.toLowerCase();
    return text.contains('id :') ||
        text.contains('họ tên :') ||
        text.contains('năm sinh :') ||
        text.contains('giới tính :');
  }

  /// Trích xuất thông tin người mất tích từ container
  MissingPerson? _extractPersonDataFromContainer(
    Element container,
    String title,
    String? detailUrl,
  ) {
    try {
      final text = container.text;

      // Trích xuất ID
      final idMatch = RegExp(r'ID\s*:\s*(\d+)').firstMatch(text);
      final id =
          idMatch?.group(1) ?? DateTime.now().millisecondsSinceEpoch.toString();

      // Trích xuất họ tên
      final nameMatch = RegExp(r'Họ tên\s*:\s*([^\n]+)').firstMatch(text);
      String name = nameMatch?.group(1)?.trim() ?? title;
      if (name.isEmpty || name == 'không biết' || name == 'Chưa rõ Chưa Rõ') {
        name = title.isNotEmpty ? title : 'Không rõ';
      }

      // Trích xuất năm sinh
      final birthYearMatch = RegExp(r'Năm sinh\s*:\s*(\d{4})').firstMatch(text);
      final birthYear = birthYearMatch?.group(1) ?? '';

      // Trích xuất giới tính
      final genderMatch = RegExp(r'Giới tính\s*:\s*(Nam|Nữ)').firstMatch(text);
      final gender = genderMatch?.group(1) ?? '';

      // Trích xuất quê quán
      final hometownMatch = RegExp(r'Quê quán\s*:\s*([^\n]+)').firstMatch(text);
      final hometown = hometownMatch?.group(1)?.trim() ?? '';

      // Trích xuất thời gian thất lạc
      final missingTimeMatch = RegExp(
        r'Thời gian thất lạc\s*:\s*(\d{4})',
      ).firstMatch(text);
      final missingTime = missingTimeMatch?.group(1) ?? '';

      // Trích xuất thông tin bổ sung
      final additionalInfoMatch = RegExp(
        r'Thông tin bổ sung\s*:\s*([^\n]+)',
      ).firstMatch(text);
      final additionalInfo = additionalInfoMatch?.group(1)?.trim() ?? '';

      // Tìm ảnh
      final imageElement = container.querySelector('img');
      String imageUrl = '';
      if (imageElement != null) {
        final src = imageElement.attributes['src'];
        if (src != null && !src.contains('noimage.jpg')) {
          imageUrl = src.startsWith('http')
              ? src
              : '$timNguoiThatLacBaseUrl$src';
        }
      }

      // Tạo description từ các thông tin có sẵn
      List<String> descriptionParts = [];
      if (gender.isNotEmpty) descriptionParts.add('Giới tính: $gender');
      if (birthYear.isNotEmpty) descriptionParts.add('Năm sinh: $birthYear');
      if (hometown.isNotEmpty) descriptionParts.add('Quê quán: $hometown');
      if (missingTime.isNotEmpty)
        descriptionParts.add('Thất lạc từ: $missingTime');
      if (additionalInfo.isNotEmpty)
        descriptionParts.add('Thông tin thêm: $additionalInfo');

      final description = descriptionParts.join('\n');

      return MissingPerson.fromHtml({
        'id': id,
        'name': name,
        'age': birthYear,
        'lastSeenLocation': hometown,
        'lastSeenDate': missingTime,
        'description': description,
        'contactInfo': '', // Cần lấy từ trang chi tiết
        'imageUrl': imageUrl,
        'detailUrl': detailUrl ?? '',
      });
    } catch (e) {
      print('Error extracting person data: $e');
      return null;
    }
  }

  /// Lấy thông tin chi tiết từ trang profile
  Future<MissingPerson?> fetchPersonDetails(String profileUrl) async {
    try {
      print('Fetching person details from: $profileUrl');

      final response = await http.get(
        Uri.parse(profileUrl),
        headers: {
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
          'Accept':
              'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
          'Accept-Language': 'vi-VN,vi;q=0.9,en;q=0.8',
        },
      );

      if (response.statusCode == 200) {
        Document document = parser.parse(response.body);

        // Trích xuất thông tin chi tiết từ trang profile
        final text = document.body?.text ?? '';

        // Tìm thông tin liên hệ
        final contactMatch = RegExp(
          r'(?:Điện thoại|Phone|Tel|Liên hệ)[\s:]*([0-9\+\-\s\(\)]+)',
        ).firstMatch(text);
        final contactInfo = contactMatch?.group(1)?.trim() ?? '';

        // Tìm email
        final emailMatch = RegExp(
          r'([a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,})',
        ).firstMatch(text);
        final email = emailMatch?.group(1) ?? '';

        // Kết hợp thông tin liên hệ
        String finalContactInfo = '';
        if (contactInfo.isNotEmpty && email.isNotEmpty) {
          finalContactInfo = 'Tel: $contactInfo, Email: $email';
        } else if (contactInfo.isNotEmpty) {
          finalContactInfo = 'Tel: $contactInfo';
        } else if (email.isNotEmpty) {
          finalContactInfo = 'Email: $email';
        }

        // Trả về thông tin liên hệ để cập nhật
        return MissingPerson.fromHtml({
          'id': '',
          'name': '',
          'age': '',
          'lastSeenLocation': '',
          'lastSeenDate': '',
          'description': '',
          'contactInfo': finalContactInfo,
          'imageUrl': '',
          'detailUrl': profileUrl,
        });
      }
    } catch (e) {
      print('Error fetching person details: $e');
    }
    return null;
  }

  /// Lấy dữ liệu từ tất cả các nguồn có sẵn
  Future<List<MissingPerson>> fetchFromAllSources({int maxPages = 3}) async {
    List<MissingPerson> allPersons = [];

    try {
      // Lấy từ timnguoithatlac.vn
      print('Fetching from timnguoithatlac.vn...');
      for (int page = 1; page <= maxPages; page++) {
        try {
          final persons = await fetchMissingPersons(page: page);
          allPersons.addAll(persons);

          // Nếu trang trả về ít hơn 20 records, có thể đã hết dữ liệu
          if (persons.length < 20) break;

          // Delay để tránh spam server
          await Future.delayed(Duration(seconds: 1));
        } catch (e) {
          print('Error fetching page $page: $e');
          break;
        }
      }

      print('Fetched ${allPersons.length} missing persons from all sources');
      return allPersons;
    } catch (e) {
      print('Error fetching from all sources: $e');
      return allPersons;
    }
  }

  /// Tìm kiếm người mất tích theo tên
  Future<List<MissingPerson>> searchByName(
    String name, {
    int maxPages = 5,
  }) async {
    final allPersons = await fetchFromAllSources(maxPages: maxPages);

    final searchTerm = name.toLowerCase().trim();
    return allPersons.where((person) {
      return person.name.toLowerCase().contains(searchTerm) ||
          person.description.toLowerCase().contains(searchTerm);
    }).toList();
  }

  /// Tìm kiếm theo địa điểm
  Future<List<MissingPerson>> searchByLocation(
    String location, {
    int maxPages = 5,
  }) async {
    final allPersons = await fetchFromAllSources(maxPages: maxPages);

    final searchTerm = location.toLowerCase().trim();
    return allPersons.where((person) {
      return person.lastSeenLocation.toLowerCase().contains(searchTerm) ||
          person.description.toLowerCase().contains(searchTerm);
    }).toList();
  }

  /// Tìm kiếm theo năm sinh
  Future<List<MissingPerson>> searchByBirthYear(
    String year, {
    int maxPages = 5,
  }) async {
    final allPersons = await fetchFromAllSources(maxPages: maxPages);

    return allPersons.where((person) {
      return person.age.contains(year) || person.description.contains(year);
    }).toList();
  }

  /// Lấy thống kê tổng quan
  Future<Map<String, dynamic>> getStatistics() async {
    try {
      final persons = await fetchFromAllSources(maxPages: 2);

      int maleCount = 0;
      int femaleCount = 0;
      int unknownGenderCount = 0;
      Map<String, int> locationStats = {};
      Map<String, int> yearStats = {};

      for (var person in persons) {
        // Thống kê giới tính
        if (person.description.toLowerCase().contains('nam')) {
          maleCount++;
        } else if (person.description.toLowerCase().contains('nữ')) {
          femaleCount++;
        } else {
          unknownGenderCount++;
        }

        // Thống kê theo địa điểm
        if (person.lastSeenLocation.isNotEmpty) {
          final location = person.lastSeenLocation.split(',').last.trim();
          locationStats[location] = (locationStats[location] ?? 0) + 1;
        }

        // Thống kê theo năm
        if (person.age.isNotEmpty) {
          final year = person.age.substring(0, 4);
          if (year.length == 4) {
            final decade = '${year.substring(0, 3)}0s';
            yearStats[decade] = (yearStats[decade] ?? 0) + 1;
          }
        }
      }

      return {
        'total': persons.length,
        'gender': {
          'male': maleCount,
          'female': femaleCount,
          'unknown': unknownGenderCount,
        },
        'topLocations': locationStats.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value))
          ..take(10),
        'yearDistribution': yearStats.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value)),
      };
    } catch (e) {
      print('Error getting statistics: $e');
      return {'total': 0, 'error': e.toString()};
    }
  }
}
