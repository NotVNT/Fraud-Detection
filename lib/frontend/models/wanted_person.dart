class WantedPerson {
  final String id;
  final String name;
  final String birthYear;
  final String address;
  final String parentNames;
  final String crime;
  final String decisionNumber;
  final String issuingUnit;
  final String imageUrl;
  final String detailUrl;

  WantedPerson({
    required this.id,
    required this.name,
    required this.birthYear,
    required this.address,
    required this.parentNames,
    required this.crime,
    required this.decisionNumber,
    required this.issuingUnit,
    this.imageUrl = '',
    this.detailUrl = '',
  });

  factory WantedPerson.fromHtml(Map<String, dynamic> data) {
    return WantedPerson(
      id: data['id'] ?? '',
      name: data['name'] ?? 'Không rõ',
      birthYear: data['birthYear'] ?? '',
      address: data['address'] ?? 'Không rõ',
      parentNames: data['parentNames'] ?? 'Không rõ',
      crime: data['crime'] ?? 'Không rõ',
      decisionNumber: data['decisionNumber'] ?? '',
      issuingUnit: data['issuingUnit'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      detailUrl: data['detailUrl'] ?? '',
    );
  }
} 