class DriverStats {
  final int todayDeliveries;
  final double todayEarnings;
  final double hoursWorked;
  final int acceptanceRate;
  final int totalDeliveries;
  final double totalEarnings;

  DriverStats({
    required this.todayDeliveries,
    required this.todayEarnings,
    required this.hoursWorked,
    required this.acceptanceRate,
    required this.totalDeliveries,
    required this.totalEarnings,
  });

  factory DriverStats.fromJson(Map<String, dynamic> json) {
    return DriverStats(
      todayDeliveries: json['todayDeliveries'] ?? 0,
      todayEarnings: (json['todayEarnings'] ?? 0).toDouble(),
      hoursWorked: (json['hoursWorked'] ?? 0).toDouble(),
      acceptanceRate: json['acceptanceRate'] ?? 100,
      totalDeliveries: json['totalDeliveries'] ?? 0,
      totalEarnings: (json['totalEarnings'] ?? 0).toDouble(),
    );
  }

  factory DriverStats.empty() {
    return DriverStats(
      todayDeliveries: 0,
      todayEarnings: 0,
      hoursWorked: 0,
      acceptanceRate: 100,
      totalDeliveries: 0,
      totalEarnings: 0,
    );
  }

  String get hoursWorkedText => '${hoursWorked}h';
  String get todayEarningsText => 'Bs. ${todayEarnings.toStringAsFixed(2)}';
  String get acceptanceRateText => '$acceptanceRate%';
}
