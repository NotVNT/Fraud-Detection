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
      // Update the URL to ensure we're accessing the correct page
      // Try the main page first, then fallback to other possible paths
      final String url = '$baseUrl${page > 1 ? "/danh-sach?page=$page" : ""}';
      
      print('Attempting to fetch data from: $url');
      
      // Send HTTP request to the website
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        // Parse the HTML content
        Document document = parser.parse(response.body);
        
        // Debug: Print part of the HTML content to see what we're getting
        print('HTML content preview: ${response.body.length > 500 ? response.body.substring(0, 500) : response.body}...');
        
        // Debug: Check for any tables in the document
        final allTables = document.querySelectorAll('table');
        print('Found ${allTables.length} tables on the page');
        
        // Try multiple selector variations to find the wanted persons table
        Element? table = document.querySelector('table.dnnGrid');
        
        if (table == null) {
          // Try alternative selectors
          final possibleSelectors = [
            'table.wanted-list',
            'table.data-table',
            'table.list-data',
            'table.wanted-persons',
            'table.persons-list',
            'table' // Last resort: try any table
          ];
          
          for (var selector in possibleSelectors) {
            table = document.querySelector(selector);
            if (table != null) {
              print('Found table using selector: $selector');
              break;
            }
          }
          
          // If still no table found, try looking for div containers that might have the data
          if (table == null) {
            final personCards = document.querySelectorAll('div.person-card, div.wanted-card, div.person-item');
            if (personCards.isNotEmpty) {
              print('Found ${personCards.length} person cards instead of table');
              
              // Process person cards and convert to WantedPerson objects
              List<WantedPerson> wantedPersons = [];
              
              for (var card in personCards) {
                try {
                  // Extract data from card elements
                  final nameElement = card.querySelector('.name, .person-name, h3, h4');
                  final name = nameElement?.text.trim() ?? 'Không rõ';
                  
                  final detailUrl = nameElement?.parent?.attributes['href'] ?? '';
                  final id = _extractIdFromUrl(detailUrl);
                  
                  final birthYearElement = card.querySelector('.birth-year, .year, .dob');
                  final birthYear = birthYearElement?.text.trim() ?? '';
                  
                  final addressElement = card.querySelector('.address, .location');
                  final address = addressElement?.text.trim() ?? '';
                  
                  final parentNamesElement = card.querySelector('.parents, .parent-names');
                  final parentNames = parentNamesElement?.text.trim() ?? '';
                  
                  final crimeElement = card.querySelector('.crime, .offense');
                  final crime = crimeElement?.text.trim() ?? '';
                  
                  final decisionNumberElement = card.querySelector('.decision, .decision-number');
                  final decisionNumber = decisionNumberElement?.text.trim() ?? '';
                  
                  final issuingUnitElement = card.querySelector('.unit, .issuing-unit');
                  final issuingUnit = issuingUnitElement?.text.trim() ?? '';
                  
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
                  print('Error parsing card: $e');
                  continue;
                }
              }
              
              // If we found and parsed person cards, return them
              if (wantedPersons.isNotEmpty) {
                return wantedPersons;
              }
            }
            
            // If we still couldn't find the data, throw an exception
            throw Exception('Không tìm thấy dữ liệu đối tượng truy nã trên trang web');
          }
        }
        
        // If we found a table, extract rows and process as before
        List<Element> rows = table!.querySelectorAll('tr');
        if (rows.isEmpty || rows.length < 2) {
          throw Exception('Không tìm thấy dữ liệu trong bảng');
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
        
        // If we couldn't parse any data, throw an exception
        if (wantedPersons.isEmpty) {
          throw Exception('Không tìm thấy dữ liệu đối tượng truy nã');
        }
        
        return wantedPersons;
      } else {
        print('Failed to load data: ${response.statusCode}');
        throw Exception('Không thể tải dữ liệu: Mã lỗi ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching wanted persons: $e');
      // Instead of returning fallback data, rethrow the exception
      // so the UI can handle it appropriately
      rethrow;
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
} 