class MissingPerson {
  final String id;
  final String name;
  final String age;
  final String lastSeenLocation;
  final String lastSeenDate;
  final String description;
  final String contactInfo;
  final String imageUrl;
  final String detailUrl;

  MissingPerson({
    required this.id,
    required this.name,
    required this.age,
    required this.lastSeenLocation,
    required this.lastSeenDate,
    required this.description,
    required this.contactInfo,
    this.imageUrl = '',
    this.detailUrl = '',
  });

  factory MissingPerson.fromHtml(Map<String, dynamic> data) {
    return MissingPerson(
      id: data['id'] ?? '',
      name: data['name'] ?? 'Không rõ',
      age: data['age'] ?? '',
      lastSeenLocation: data['lastSeenLocation'] ?? 'Không rõ',
      lastSeenDate: data['lastSeenDate'] ?? '',
      description: data['description'] ?? '',
      contactInfo: data['contactInfo'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      detailUrl: data['detailUrl'] ?? '',
    );
  }
}