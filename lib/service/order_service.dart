import 'package:software_system/service/supabase_helper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/order_model.dart';
import 'package:software_system/models/client_model.dart';

class OrderService {
  final SupabaseClient _client = SupabaseHelper.client;

  static const String _ordersTable = 'orders';
  static const String _clientsTable = 'clients';
  static const String _productsTable = 'products';
  static const String _orderDetailsTable = 'order_details';
  static const String _productTransactionsTable = 'product_transactions';

  // ================== جلب كل الأوردرات ==================
  Future<List<Order>> fetchOrdersList() async {
    try {
      final response = await _client
          .from(_ordersTable)
          .select(
              'id, created_at, total_price, discount, notes, client_id(id, name)')
          .order('created_at', ascending: false)
          .limit(100);

      return (response as List<dynamic>)
          .map((map) =>
              Order.fromMapForList(map as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to load orders list: $e');
    }
  }

  // ================== تفاصيل أوردر ==================
  Future<Order> fetchOrderDetails(int orderId) async {
    try {
      final orderResponse = await _client
          .from(_ordersTable)
          .select('*, client_id(*)')
          .eq('id', orderId)
          .single();

      Order order = Order.fromMapForDetails(orderResponse);

      final detailsResponse = await _client
          .from(_orderDetailsTable)
          .select('*, product_id(*)')
          .eq('order_id', orderId);

      final items = (detailsResponse as List<dynamic>)
          .map((map) =>
              OrderItemDetails.fromMap(map as Map<String, dynamic>))
          .toList();

      return Order(
        id: order.id,
        clientId: order.clientId,
        totalPrice: order.totalPrice,
        discount: order.discount,
        notes: order.notes,
        createdAt: order.createdAt,
        client:
            order.client ?? Client(id: order.clientId, name: 'غير معروف'),
        items: items,
      );
    } catch (e) {
      throw Exception('Failed to load order details: $e');
    }
  }

  // ================== إنشاء أوردر جديد ==================
  Future<void> createNewOrder({
    required int clientId,
    required double totalPrice,
    required double discount,
    String? notes,
    required List<Map<String, dynamic>> orderItems,
  }) async {
    try {
      final orderCode =
          DateTime.now().microsecondsSinceEpoch.toString();

      // 1️⃣ إنشاء الأوردر
      final orderResponse = await _client
          .from(_ordersTable)
          .insert({
            'client_id': clientId,
            'total_price': totalPrice,
            'discount': discount,
            'notes': notes,
            'code': orderCode,
          })
          .select('id')
          .single();

      final int orderId = orderResponse['id'];

      // 2️⃣ تفاصيل الأوردر
      final List<Map<String, dynamic>> detailsToInsert =
          orderItems.map((item) {
        return {
          'order_id': orderId,
          'product_id': item['product_id'],
          'quantity': item['quantity'],
          'price': item['price'],
        };
      }).toList();

      await _client.from(_orderDetailsTable).insert(detailsToInsert);

      // 3️⃣ تحديث المخزون + تسجيل الحركات
      for (var item in orderItems) {
        final int productId = item['product_id'];
        final int quantitySold = item['quantity'];

        // جلب المخزون الحالي
        final productResponse = await _client
            .from(_productsTable)
            .select('totalQuantity')
            .eq('id', productId)
            .single();

        final int currentStock = productResponse['totalQuantity'];
        final int newStock = currentStock - quantitySold;

        // تحديث المخزون
        await _client
            .from(_productsTable)
            .update({'totalQuantity': newStock})
            .eq('id', productId);

        // 4️⃣ تسجيل حركة مخزون (OUT)
        await _client.from(_productTransactionsTable).insert({
          'product_id': productId,
          'quantity': quantitySold,
          'model': 'orders',
          'model_id': orderId,
          'type': 'out',
          'created_at': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      throw Exception(
          'Failed to create order and transactions: ${e.toString()}');
    }
  }

  // ================== حذف أوردر + عكس المخزون ==================
  Future<void> deleteOrder(int orderId) async {
    try {
      final detailsResponse = await _client
          .from(_orderDetailsTable)
          .select('product_id, quantity')
          .eq('order_id', orderId);

      for (var item in detailsResponse) {
        final int productId = item['product_id'];
        final int quantityToReturn = item['quantity'];

        final productResponse = await _client
            .from(_productsTable)
            .select('totalQuantity')
            .eq('id', productId)
            .single();

        final int currentStock = productResponse['totalQuantity'];
        final int newStock = currentStock + quantityToReturn;

        // عكس المخزون
        await _client
            .from(_productsTable)
            .update({'totalQuantity': newStock})
            .eq('id', productId);

        // تسجيل حركة رجوع (IN)
        await _client.from(_productTransactionsTable).insert({
          'product_id': productId,
          'quantity': quantityToReturn,
          'model': 'orders',
          'model_id': orderId,
          'type': 'in',
          'created_at': DateTime.now().toIso8601String(),
        });
      }

      await _client
          .from(_orderDetailsTable)
          .delete()
          .eq('order_id', orderId);

      await _client.from(_ordersTable).delete().eq('id', orderId);
    } catch (e) {
      throw Exception('فشل حذف الطلب وعكس المخزون: $e');
    }
  }

  // ================== العملاء ==================
  Future<List<Map<String, dynamic>>> fetchClients() async {
    try {
      final response = await _client
          .from(_clientsTable)
          .select('id, name')
          .order('name', ascending: true);

      return response as List<Map<String, dynamic>>;
    } catch (e) {
      return [];
    }
  }

  // ================== المنتجات ==================
  Future<List<Map<String, dynamic>>> fetchProducts() async {
    try {
      final response = await _client
          .from(_productsTable)
          .select('id, name, SellingPrice, totalQuantity')
          .order('name', ascending: true);

      return response as List<Map<String, dynamic>>;
    } catch (e) {
      throw Exception('Failed to load products: $e');
    }
  }
}
