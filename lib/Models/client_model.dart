class Client {
  final int? id;
  final String name;
  final String? phone;
  final String? address;
  final bool newClient;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Client({
    this.id,
    required this.name,
    this.phone,
    this.address,
    this.newClient = true,
    this.createdAt,
    this.updatedAt,
  });

  factory Client.fromMap(Map<String, dynamic> map) {
    return Client(
      id: map['id'],
      name: map['name'],
      phone: map['phone'],
      address: map['address'],
      newClient: map['new_client'] ?? true,
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
      'new_client': newClient,
    };
  }
}