class Driver {
  final String id;
  final String email;
  final String name;
  final String lastname;
  final String phone;
  final String vehicle;
  final String status;
  final bool isActive;
  final String? appToken;

  Driver({
    required this.id,
    required this.email,
    required this.name,
    required this.lastname,
    required this.phone,
    required this.vehicle,
    required this.status,
    required this.isActive,
    this.appToken,
  });

  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      lastname: json['lastname'] ?? '',
      phone: json['phone'] ?? '',
      vehicle: json['vehicle'] ?? '',
      status: json['status'] ?? 'OFFLINE',
      isActive: json['isActive'] ?? true,
      appToken: json['appToken'],
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
      'appToken': appToken,
    };
  }

  String get fullName => '$name $lastname';

  bool get isAvailable => status == 'AVAILABLE';
  bool get isBusy => status == 'BUSY';
  bool get isOffline => status == 'OFFLINE';
}
