import 'package:software_system/models/client_model.dart';
import 'package:software_system/models/products.dart';

class Order {
  final int id;
  final int clientId;
  final double totalPrice;
  final double discount;
  final String? notes;
  final DateTime createdAt;
  final Client? client;
  final List<OrderItemDetails>? items;

  Order({
    required this.id,
    required this.clientId,
    required this.totalPrice,
    required this.discount,
    this.notes,
    required this.createdAt,
    this.client,
    this.items,
  });

  factory Order.fromMapForList(Map<String, dynamic> map) {
    final clientData = map['client_id'];
    int actualClientId = map['client_id'] is Map
        ? map['client_id']['id'] as int
        : map['client_id'] as int;
    return Order(
      id: map['id'] as int,
      clientId: actualClientId,
      totalPrice: (map['total_price'] as num?)?.toDouble() ?? 0.0,
      discount: (map['discount'] as num?)?.toDouble() ?? 0.0,
      notes: map['notes'],
      createdAt: DateTime.parse(map['created_at']),
      client: clientData is Map
          ? Client(id: clientData['id'], name: clientData['name'])
          : null,
      items: null,
    );
  }

  factory Order.fromMapForDetails(Map<String, dynamic> map) {
    final clientData = map['client_id'];
    int idFromFkey = clientData is Map ? clientData['id'] : map['client_id'] as int;
    return Order(
      id: map['id'] as int,
      clientId: idFromFkey,
      totalPrice: (map['total_price'] as num?)?.toDouble() ?? 0.0,
      discount: (map['discount'] as num?)?.toDouble() ?? 0.0,
      notes: map['notes'],
      createdAt: DateTime.parse(map['created_at']),
      client: clientData != null ? Client.fromMap(clientData) : null,
      items: null,
    );
  }
}

class OrderItemDetails {
  final int id;
  final int orderId;
  final int productId;
  final int quantity;
  final double price;
  final Product? product;

  OrderItemDetails({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.quantity,
    required this.price,
    this.product,
  });

  factory OrderItemDetails.fromMap(Map<String, dynamic> map) {
    final productData = map['product_id'];
    int idFromFkey = productData is Map ? productData['id'] : map['product_id'] as int;
    return OrderItemDetails(
      id: map['id'] as int,
      orderId: map['order_id'] as int,
      productId: idFromFkey,
      quantity: (map['quantity'] as num).toInt(),
      price: (map['price'] as num).toDouble(),
      product: productData != null ? Product.fromJson(productData) : null,
    );
  }
}
