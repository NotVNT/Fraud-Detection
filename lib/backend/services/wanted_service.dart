import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart';
import '../../frontend/models/wanted_person.dart';

class WantedService {
  // Base URL for Bộ Công An website
  static const String baseUrl = 'https://truyna.bocongan.gov.vn';
  
  // Method to fetch wanted persons from the website
  Future<List<WantedPerson>> fetchWantedPersons({int page = 1}) async {
    try {
      // Send HTTP request to the website
      final response = await http.get(Uri.parse('$baseUrl/Trang-chủ'));
      
      if (response.statusCode == 200) {
        // Parse the HTML content
        Document document = parser.parse(response.body);
        
        // Extract the table containing wanted persons
        final table = document.querySelector('table.dnnGrid');
        if (table == null) {
          throw Exception('Could not find the wanted persons table');
        }
        
        // Extract rows from the table (skip header row)
        List<Element> rows = table.querySelectorAll('tr');
        if (rows.isEmpty || rows.length < 2) {
          throw Exception('No data found in the table');
        }
        
        // Skip the header row
        rows = rows.sublist(1);
        
        // Convert HTML rows to WantedPerson objects
        List<WantedPerson> wantedPersons = [];
        
        for (var row in rows) {
          try {
            final cells = row.querySelectorAll('td');
            if (cells.length < 7) continue;
            
            // Extract person ID from the link
            final nameCell = cells[1];
            final nameLink = nameCell.querySelector('a');
            final detailUrl = nameLink?.attributes['href'] ?? '';
            final id = _extractIdFromUrl(detailUrl);
            
            // Extract name
            final name = nameLink?.text.trim() ?? 'Không rõ';
            
            // Extract other information
            final birthYear = cells[2].text.trim();
            final address = cells[3].text.trim();
            final parentNames = cells[4].text.trim();
            final crime = cells[5].text.trim();
            final decisionNumber = cells[6].text.trim();
            final issuingUnit = cells.length > 7 ? cells[7].text.trim() : '';
            
            // Add to the list
            wantedPersons.add(WantedPerson.fromHtml({
              'id': id,
              'name': name,
              'birthYear': birthYear,
              'address': address,
              'parentNames': parentNames,
              'crime': crime,
              'decisionNumber': decisionNumber,
              'issuingUnit': issuingUnit,
              'detailUrl': detailUrl.isNotEmpty ? (detailUrl.startsWith('http') ? detailUrl : '$baseUrl$detailUrl') : '',
            }));
            
          } catch (e) {
            print('Error parsing row: $e');
            continue;
          }
        }
        
        // If we couldn't parse any data or the list is too small, return fallback data
        if (wantedPersons.isEmpty || wantedPersons.length < 5) {
          return _getFallbackData();
        }
        
        return wantedPersons;
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching wanted persons: $e');
      // Return fallback data in case of error
      return _getFallbackData();
    }
  }
  
  // Extract ID from URL
  String _extractIdFromUrl(String url) {
    final regex = RegExp(r'ma/([a-zA-Z0-9-]+)');
    final match = regex.firstMatch(url);
    return match?.group(1) ?? '';
  }
  
  // Fetch details for a specific person
  Future<Map<String, String>> fetchPersonDetails(String detailUrl) async {
    try {
      final response = await http.get(Uri.parse(detailUrl));
      
      if (response.statusCode == 200) {
        Document document = parser.parse(response.body);
        
        // Try to find the image
        final imageElement = document.querySelector('.person-image img') ?? 
                            document.querySelector('.wanted-person-image img') ??
                            document.querySelector('img[alt*="wanted"]');
        
        final imageUrl = imageElement?.attributes['src'] ?? '';
        
        return {
          'imageUrl': imageUrl.startsWith('http') ? imageUrl : '$baseUrl$imageUrl',
        };
      }
    } catch (e) {
      print('Error fetching person details: $e');
    }
    
    return {'imageUrl': ''};
  }
  
  // Fallback data in case the website is not available
  List<WantedPerson> _getFallbackData() {
    return [
      WantedPerson(
        id: '1',
        name: 'Võ Thế Hùng',
        birthYear: '1982',
        address: 'Vĩnh Giang, Vĩnh Linh, Quảng Trị',
        parentNames: 'Võ Quang Huy, Trần Thị Nhường',
        crime: 'Tội giết người',
        decisionNumber: 'Số 2508 ngày 22/05/2025',
        issuingUnit: 'Cơ quan CSĐT TP về TTXHCA tỉnh Quảng Trị',
      ),
      WantedPerson(
        id: '2',
        name: 'Lê Thị Giang',
        birthYear: '1983',
        address: 'thôn Duyên Ứng, xã Lam Điền, Chương Mỹ, Hà Nội',
        parentNames: 'Lê Quang Kéo, Cấn Thị Vân',
        crime: 'Tội trộm cắp tài sản',
        decisionNumber: 'Số A7732 ngày 21/05/2025',
        issuingUnit: 'Văn phòng cơ quan CSĐTCA TP. Hà Nội',
      ),
      WantedPerson(
        id: '3',
        name: 'Lê Văn Quân',
        birthYear: '1996',
        address: 'thôn 1, xã Hạ Mỹ, Bố Trạch, Quảng Bình',
        parentNames: 'Lê Văn Tính, Nguyễn Thị Thanh Hoa',
        crime: 'Tội giết người',
        decisionNumber: 'Số A2540 ngày 21/05/2025',
        issuingUnit: 'Văn phòng Cơ quan CSĐTCA tỉnh Bình Dương',
      ),
      WantedPerson(
        id: '4',
        name: 'Hà Văn Tuyên',
        birthYear: '1997',
        address: 'thôn An Khang, Tân An, Chiêm Hoá, Tuyên Quang',
        parentNames: 'Hà Văn Khoát, Hà Thị Phương',
        crime: 'Tội gây rối trật tự công cộng',
        decisionNumber: 'Số 7124 ngày 21/05/2025',
        issuingUnit: 'Cơ quan CSĐT TP về TTXHCA TP. Hải Phòng',
      ),
      WantedPerson(
        id: '5',
        name: 'Trần Hoàng Tân',
        birthYear: '1997',
        address: 'ấp An Quới, xã An Thạnh 3, Cù Lao Dung, Sóc Trăng',
        parentNames: 'Trần Văn Phước, Huỳnh Thị Danh',
        crime: 'Tội hủy hoại hoặc cố ý làm hư hỏng tài sản + Tội gây rối trật tự công cộng',
        decisionNumber: 'Số 2920 ngày 21/05/2025',
        issuingUnit: 'Cơ quan CSĐT TP về TTXHCA tỉnh Bình Dương',
      ),
      WantedPerson(
        id: '6',
        name: 'Trần Anh Thư',
        birthYear: '2008',
        address: 'tổ 7, phường Hùng Vương, thành phố Phúc Yên, tỉnh Vĩnh Phúc',
        parentNames: 'Trần Đức Hiền, Lưu Thị Hạnh',
        crime: 'Tội cố ý gây thương tích hoặc gây tổn hại cho sức khỏe của người khác',
        decisionNumber: 'Số A1651 ngày 20/05/2025',
        issuingUnit: 'Cơ quan CSĐT TP về TTXHCA tỉnh Vĩnh Phúc',
      ),
      WantedPerson(
        id: '7',
        name: 'Nguyễn Việt Thịnh',
        birthYear: '1994',
        address: 'ấp Phước Phong, xã Phú Tân, huyện Châu Thành, tỉnh Sóc Trăng',
        parentNames: 'Nguyễn Hữu Thọ, Thạch Thị Dinh',
        crime: 'Tội giao cấu hoặc thực hiện hành vi quan hệ tình dục khác với người từ đủ 13 tuổi đến dưới 16 tuổi',
        decisionNumber: 'Số 4318 ngày 20/05/2025',
        issuingUnit: 'Cơ quan CSĐTCA tỉnh Sóc Trăng',
      ),
      WantedPerson(
        id: '8',
        name: 'Vũ Thế Tới',
        birthYear: '1993',
        address: 'Không rõ',
        parentNames: 'Vũ Văn Tịnh, Vũ Thị Tơ',
        crime: 'Tội cho vay lãi nặng trong giao dịch dân sự',
        decisionNumber: 'Số C1146 ngày 19/05/2025',
        issuingUnit: 'Cơ quan CSĐT TP về TTXHCA TP. Hồ Chí Minh',
      ),
      WantedPerson(
        id: '9',
        name: 'Lại Văn Cường',
        birthYear: '1989',
        address: 'Không rõ',
        parentNames: 'Lại Văn Ghi, Phạm Thị Sách',
        crime: 'Tội cho vay lãi nặng trong giao dịch dân sự',
        decisionNumber: 'Số C1145 ngày 19/05/2025',
        issuingUnit: 'Cơ quan CSĐT TP về TTXHCA TP. Hồ Chí Minh',
      ),
      WantedPerson(
        id: '10',
        name: 'Nguyễn Văn Tứ',
        birthYear: '1999',
        address: 'ấp Xóm Rẫy, xã Quách Phẩm Bắc, Đầm Rơi, Cà Mau',
        parentNames: 'Nguyễn Văn Chanh, Mai Thị Sáu',
        crime: 'Tội cố ý gây thương tích hoặc gây tổn hại cho sức khỏe của người khác',
        decisionNumber: 'Số 07 ngày 08/05/2025',
        issuingUnit: 'Cơ quan Thi hành án Hình sự và Hỗ trợ Tư phápCA tỉnh Bình Dương',
      ),
    ];
  }
} 