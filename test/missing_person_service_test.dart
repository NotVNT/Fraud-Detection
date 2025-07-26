import '../lib/backend/services/missing_person_service.dart';

/// Test file để kiểm tra MissingPersonService
/// Chạy file này để test các chức năng scraping
void main() async {
  final service = MissingPersonService();

  print('=== TESTING MISSING PERSON SERVICE ===\n');

  try {
    // Test 1: Lấy danh sách người mất tích từ trang đầu tiên
    print('1. Testing fetchMissingPersons (page 1)...');
    final firstPagePersons = await service.fetchMissingPersons(page: 1);
    print('Found ${firstPagePersons.length} missing persons on page 1');

    if (firstPagePersons.isNotEmpty) {
      final firstPerson = firstPagePersons.first;
      print('First person: ${firstPerson.name}');
      print('Age: ${firstPerson.age}');
      print('Location: ${firstPerson.lastSeenLocation}');
      print('Description: ${firstPerson.description.substring(0, 100)}...\n');
    }

    // Test 2: Lấy từ nhiều trang
    print('2. Testing fetchFromAllSources (2 pages)...');
    final allPersons = await service.fetchFromAllSources(maxPages: 2);
    print('Total found: ${allPersons.length} missing persons\n');

    // Test 3: Tìm kiếm theo tên
    print('3. Testing search by name...');
    final searchResults = await service.searchByName('Nguyễn', maxPages: 2);
    print(
      'Found ${searchResults.length} persons with name containing "Nguyễn"\n',
    );

    // Test 4: Tìm kiếm theo địa điểm
    print('4. Testing search by location...');
    final locationResults = await service.searchByLocation(
      'Hà Nội',
      maxPages: 2,
    );
    print('Found ${locationResults.length} persons from Hà Nội area\n');

    // Test 5: Lấy thống kê
    print('5. Testing statistics...');
    final stats = await service.getStatistics();
    print('Statistics:');
    print('- Total: ${stats['total']}');
    print('- Gender distribution: ${stats['gender']}');
    print('- Top locations: ${stats['topLocations']}');
    print('- Year distribution: ${stats['yearDistribution']}\n');

    // Test 6: Lấy chi tiết một profile (nếu có)
    if (firstPagePersons.isNotEmpty &&
        firstPagePersons.first.detailUrl.isNotEmpty) {
      print('6. Testing fetchPersonDetails...');
      final detailUrl = firstPagePersons.first.detailUrl;
      final details = await service.fetchPersonDetails(detailUrl);
      if (details != null) {
        print('Contact info: ${details.contactInfo}');
      } else {
        print('No additional details found');
      }
    }
  } catch (e) {
    print('Error during testing: $e');
  }

  print('\n=== TESTING COMPLETED ===');
}
