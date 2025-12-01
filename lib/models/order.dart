class Order {
  final String id;
  final double totalAmount;
  final String status;
  final String? paymentMethod;
  final String paymentStatus;
  final String? deliveryAddress;
  final double? latitude;
  final double? longitude;
  final String? phone;
  final String? notes;
  final double? driverEarnings;
  final double? distanceKm;
  final DateTime? assignedAt;
  final DateTime? pickedUpAt;
  final DateTime? deliveredAt;
  final Driver? driver;
  final List<OrderItem> orderItems;
  final DateTime createdAt;

  Order({
    required this.id,
    required this.totalAmount,
    required this.status,
    this.paymentMethod,
    required this.paymentStatus,
    this.deliveryAddress,
    this.latitude,
    this.longitude,
    this.phone,
    this.notes,
    this.driverEarnings,
    this.distanceKm,
    this.assignedAt,
    this.pickedUpAt,
    this.deliveredAt,
    this.driver,
    required this.orderItems,
    required this.createdAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      totalAmount: _parseDouble(json['totalAmount']),
      status: json['status'],
      paymentMethod: json['paymentMethod'],
      paymentStatus: json['paymentStatus'],
      deliveryAddress: json['deliveryAddress'],
      latitude: json['latitude'] != null ? _parseDouble(json['latitude']) : null,
      longitude: json['longitude'] != null ? _parseDouble(json['longitude']) : null,
      phone: json['phone'],
      notes: json['notes'],
      driverEarnings: json['driverEarnings'] != null ? _parseDouble(json['driverEarnings']) : null,
      distanceKm: json['distanceKm'] != null ? _parseDouble(json['distanceKm']) : null,
      assignedAt: json['assignedAt'] != null ? DateTime.parse(json['assignedAt']) : null,
      pickedUpAt: json['pickedUpAt'] != null ? DateTime.parse(json['pickedUpAt']) : null,
      deliveredAt: json['deliveredAt'] != null ? DateTime.parse(json['deliveredAt']) : null,
      driver: json['driver'] != null ? Driver.fromJson(json['driver']) : null,
      orderItems: (json['orderItems'] as List?)?.map((item) => OrderItem.fromJson(item)).toList() ?? [],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.parse(value);
    return 0.0;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'totalAmount': totalAmount,
      'status': status,
      'paymentMethod': paymentMethod,
      'paymentStatus': paymentStatus,
      'deliveryAddress': deliveryAddress,
      'latitude': latitude,
      'longitude': longitude,
      'phone': phone,
      'notes': notes,
      'driverEarnings': driverEarnings,
      'distanceKm': distanceKm,
      'assignedAt': assignedAt?.toIso8601String(),
      'pickedUpAt': pickedUpAt?.toIso8601String(),
      'deliveredAt': deliveredAt?.toIso8601String(),
      'driver': driver?.toJson(),
      'orderItems': orderItems.map((item) => item.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class OrderItem {
  final String id;
  final int quantity;
  final double price;
  final String? productName;

  OrderItem({
    required this.id,
    required this.quantity,
    required this.price,
    this.productName,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'],
      quantity: json['quantity'] is int ? json['quantity'] : int.parse(json['quantity'].toString()),
      price: Order._parseDouble(json['price']),
      productName: json['product']?['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quantity': quantity,
      'price': price,
    };
  }
}

// Import para Driver
class Driver {
  final String id;
  final String email;
  final String name;
  final String lastname;
  final String? phone;
  final String? vehicle;
  final String status;
  final bool isActive;

  Driver({
    required this.id,
    required this.email,
    required this.name,
    required this.lastname,
    this.phone,
    this.vehicle,
    required this.status,
    required this.isActive,
  });

  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      lastname: json['lastname'],
      phone: json['phone'],
      vehicle: json['vehicle'],
      status: json['status'],
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'lastname': lastname,
      'phone': phone,
      'vehicle': vehicle,
      'status': status,
      'isActive': isActive,
    };
  }
}
