class Driver {
  final int id;
  final String name;
  final String contactInfo;
  final String paymentType;
  final double perStopRate;
  final double fixedDailyRate;

  // var fixedPrice;

  Driver({
    required this.id,
    required this.name,
    required this.contactInfo,
    required this.paymentType,
    this.perStopRate = 0.0,
    this.fixedDailyRate = 0.0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'contactInfo': contactInfo,
      'paymentType': paymentType,
      'perStopRate': perStopRate,
      'fixedDailyRate': fixedDailyRate,
    };
  }

  factory Driver.fromMap(Map<String, dynamic> map) {
    return Driver(
      id: map['id'] is int ? map['id'] : int.tryParse(map['id'].toString()) ?? 0,
      name: map['name'] ?? '',
      contactInfo: map['contactInfo'] ?? '',
      paymentType: map['paymentType'] ?? '',
      perStopRate: (map['perStopRate'] is num)
          ? (map['perStopRate'] as num).toDouble()
          : double.tryParse(map['perStopRate'].toString()) ?? 0.0,
      fixedDailyRate: (map['fixedDailyRate'] is num)
          ? (map['fixedDailyRate'] as num).toDouble()
          : double.tryParse(map['fixedDailyRate'].toString()) ?? 0.0,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Driver && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
