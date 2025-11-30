import 'package:software_system/Models/products.dart';
import 'package:software_system/service/supabase_helper.dart';

class ProductService {
  static const String _table = 'products';

  // Get All Products
  static Future<List<Product>> getAllProducts() async {
    final response = await SupabaseHelper.client
        .from(_table)
        .select();

    return (response as List)
        .map((item) => Product.fromJson(item))
        .toList();
  }

  // Update Product
  static Future<void> updateProduct(Product product) async {
    if (product.id == null) {
      throw Exception("Product ID is null!");
    }

    await SupabaseHelper.client
        .from(_table)
        .update(product.toJson())
        .eq("id", product.id as Object);
  }

  // Add New Product
  static Future<void> addProduct(Product product) async {
    await SupabaseHelper.client
        .from(_table)
        .insert(product.toJson());
  }

  // Delete Product
  static Future<void> deleteProduct(int id) async {
    await SupabaseHelper.client
        .from(_table)
        .delete()
        .eq("id", id);
  }
}
