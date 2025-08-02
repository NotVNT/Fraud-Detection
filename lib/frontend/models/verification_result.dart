class VerificationResult {
  final String status; // 'safe', 'warning', 'danger'
  final String message;
  final double? fraudPercentage;
  final List<String> warnings;
  final String? source;
  final DateTime checkedAt;

  VerificationResult({
    required this.status,
    required this.message,
    this.fraudPercentage,
    this.warnings = const [],
    this.source,
    DateTime? checkedAt,
  }) : checkedAt = checkedAt ?? DateTime.now();

  bool get isSafe => status == 'safe';
  bool get isWarning => status == 'warning';
  bool get isDanger => status == 'danger';

  factory VerificationResult.fromJson(Map<String, dynamic> json) {
    return VerificationResult(
      status: json['status'] ?? 'safe',
      message: json['message'] ?? '',
      fraudPercentage: json['fraud_percentage']?.toDouble(),
      warnings: List<String>.from(json['warnings'] ?? []),
      source: json['source'],
      checkedAt: json['checked_at'] != null 
          ? DateTime.parse(json['checked_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'fraud_percentage': fraudPercentage,
      'warnings': warnings,
      'source': source,
      'checked_at': checkedAt.toIso8601String(),
    };
  }
}
