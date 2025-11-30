class Supplier {
  final int? id;
  final String name;
  final String? phone;
  final String? address;
  final int currentBalance;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Supplier({
    this.id,
    required this.name,
    this.phone,
    this.address,
    this.currentBalance = 0,
    this.createdAt,
    this.updatedAt,
  });

  factory Supplier.fromMap(Map<String, dynamic> map) {
    return Supplier(
      id: map['id'],
      name: map['name'],
      phone: map['phone'],
      address: map['address'],
      currentBalance: map['current_balance'] ?? 0,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'address': address,
      'current_balance': currentBalance,
    };
  }
}