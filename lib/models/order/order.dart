import 'order_item.dart';

enum OrderStatus {
  pending,
  confirmed,
  searchingDriver,
  assigned,
  accepted,
  pickingUp,
  pickedUp,
  inTransit,
  atDoor,
  delivered,
  cancelled,
  rejected,
}

extension OrderStatusExtension on OrderStatus {
  String get value {
    switch (this) {
      case OrderStatus.pending:
        return 'PENDING';
      case OrderStatus.confirmed:
        return 'CONFIRMED';
      case OrderStatus.searchingDriver:
        return 'SEARCHING_DRIVER';
      case OrderStatus.assigned:
        return 'ASSIGNED';
      case OrderStatus.accepted:
        return 'ACCEPTED';
      case OrderStatus.pickingUp:
        return 'PICKING_UP';
      case OrderStatus.pickedUp:
        return 'PICKED_UP';
      case OrderStatus.inTransit:
        return 'IN_TRANSIT';
      case OrderStatus.atDoor:
        return 'AT_DOOR';
      case OrderStatus.delivered:
        return 'DELIVERED';
      case OrderStatus.cancelled:
        return 'CANCELLED';
      case OrderStatus.rejected:
        return 'REJECTED';
    }
  }

  static OrderStatus fromString(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return OrderStatus.pending;
      case 'CONFIRMED':
        return OrderStatus.confirmed;
      case 'SEARCHING_DRIVER':
        return OrderStatus.searchingDriver;
      case 'ASSIGNED':
        return OrderStatus.assigned;
      case 'ACCEPTED':
        return OrderStatus.accepted;
      case 'PICKING_UP':
        return OrderStatus.pickingUp;
      case 'PICKED_UP':
        return OrderStatus.pickedUp;
      case 'IN_TRANSIT':
        return OrderStatus.inTransit;
      case 'AT_DOOR':
        return OrderStatus.atDoor;
      case 'DELIVERED':
        return OrderStatus.delivered;
      case 'CANCELLED':
        return OrderStatus.cancelled;
      case 'REJECTED':
        return OrderStatus.rejected;
      default:
        return OrderStatus.pending;
    }
  }
}

class Order {
  final String id;
  final double totalAmount;
  final OrderStatus status;
  final String? paymentMethod;
  final String? paymentStatus;
  final String? deliveryAddress;
  final double? latitude;
  final double? longitude;
  final String? phone;
  final String? notes;
  final double? deliveryDistance;
  final double? deliveryFee;
  final double? driverEarnings;
  final List<OrderItem> orderItems;
  final OrderUser? user;
  final DateTime? createdAt;
  final DateTime? assignedAt;
  final DateTime? acceptedAt;

  Order({
    required this.id,
    required this.totalAmount,
    required this.status,
    this.paymentMethod,
    this.paymentStatus,
    this.deliveryAddress,
    this.latitude,
    this.longitude,
    this.phone,
    this.notes,
    this.deliveryDistance,
    this.deliveryFee,
    this.driverEarnings,
    this.orderItems = const [],
    this.user,
    this.createdAt,
    this.assignedAt,
    this.acceptedAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] ?? '',
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      status: OrderStatusExtension.fromString(json['status'] ?? 'PENDING'),
      paymentMethod: json['paymentMethod'],
      paymentStatus: json['paymentStatus'],
      deliveryAddress: json['deliveryAddress'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      phone: json['phone'],
      notes: json['notes'],
      deliveryDistance: json['deliveryDistance']?.toDouble(),
      deliveryFee: json['deliveryFee']?.toDouble(),
      driverEarnings: json['driverEarnings']?.toDouble(),
      orderItems: json['orderItems'] != null
          ? (json['orderItems'] as List)
                .map((item) => OrderItem.fromJson(item))
                .toList()
          : [],
      user: json['user'] != null ? OrderUser.fromJson(json['user']) : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      assignedAt: json['assignedAt'] != null
          ? DateTime.parse(json['assignedAt'])
          : null,
      acceptedAt: json['acceptedAt'] != null
          ? DateTime.parse(json['acceptedAt'])
          : null,
    );
  }

  String get shortId {
    if (id.length >= 8) {
      return '#ORD-${id.substring(0, 8).toUpperCase()}';
    }
    return '#ORD-$id';
  }

  String get paymentMethodText {
    switch (paymentMethod) {
      case 'CASH':
        return 'Efectivo';
      case 'QR':
        return 'QR';
      default:
        return 'No especificado';
    }
  }

  int get itemsCount => orderItems.length;

  double get totalToCobrar => totalAmount + (deliveryFee ?? 0);
}

class OrderUser {
  final String? id;
  final String? name;
  final String? phone;
  final String? telegramId;

  OrderUser({this.id, this.name, this.phone, this.telegramId});

  factory OrderUser.fromJson(Map<String, dynamic> json) {
    return OrderUser(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
      telegramId: json['telegramId'],
    );
  }

  String get displayName => name ?? 'Cliente';
}
