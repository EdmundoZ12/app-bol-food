class Order {
  final String id;
  final double totalAmount;
  final double? driverEarnings;
  final String status;
  final String? paymentMethod;
  final String paymentStatus;
  final String? deliveryAddress;
  final double? latitude;
  final double? longitude;
  final String? phone;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Order({
    required this.id,
    required this.totalAmount,
    this.driverEarnings,
    required this.status,
    this.paymentMethod,
    required this.paymentStatus,
    this.deliveryAddress,
    this.latitude,
    this.longitude,
    this.phone,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      totalAmount: (json['totalAmount'] as num).toDouble(),
      driverEarnings: json['driverEarnings'] != null
          ? (json['driverEarnings'] as num).toDouble()
          : null,
      status: json['status'],
      paymentMethod: json['paymentMethod'],
      paymentStatus: json['paymentStatus'],
      deliveryAddress: json['deliveryAddress'],
      latitude: json['latitude'] != null
          ? (json['latitude'] as num).toDouble()
          : null,
      longitude: json['longitude'] != null
          ? (json['longitude'] as num).toDouble()
          : null,
      phone: json['phone'],
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}
