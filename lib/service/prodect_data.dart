// lib/services/product_service.dart
import 'package:software_system/Models/prodects.dart';
import 'package:software_system/service/supabase_helper.dart';

class ProductService {  // صح: ProductService مش ProdectData
  static const String _table = 'products';

  // جلب كل المنتجات
  static Future<List<Product>> getAllProducts() async {
    final response = await SupabaseHelper.client
        .from(_table)
        .select()
        .order('name', ascending: true);

    return (response as List).map((json) => Product.fromJson(json)).toList();
  }

  // جلب المنتجات الناقصة فقط
  static Future<List<Product>> getMissingProducts() async {
    final response = await SupabaseHelper.client
        .from(_table)
        .select()
        .lte('totalQuantity', 3)
        .order('totalQuantity', ascending: true);

    return (response as List).map((json) => Product.fromJson(json)).toList();
  }

  // إضافة منتج جديد
  static Future<void> addProduct(Product product) async {
    await SupabaseHelper.client.from(_table).insert(product.toJson());
  }
}