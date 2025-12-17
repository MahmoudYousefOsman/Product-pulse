import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:software_system/Models/products.dart';
import 'package:software_system/service/supabase_helper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProductService {
  static const String _table = 'products';
  static const String _transactionsTable = 'product_transactions';
  static const String _storageBucket = 'product-images';

  // ===============================
  // Get All Products
  // ===============================
  static Future<List<Product>> getAllProducts() async {
    final response =
        await SupabaseHelper.client.from(_table).select();
    return (response as List)
        .map((item) => Product.fromJson(item))
        .toList();
  }

  // ===============================
  // Search Products
  // ===============================
  static List<Product> searchProducts(
      List<Product> products, String query) {
    if (query.isEmpty) return products;
    final lowerQuery = query.toLowerCase();
    return products.where((p) {
      return p.name.toLowerCase().contains(lowerQuery) ||
          p.code.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  // ===============================
  // Check low stock
  // ===============================
  static bool isLowStock(Product product) {
    return product.totalQuantity <= 3;
  }

  // ===============================
  // Update Product
  // ===============================
  static Future<void> updateProduct(Product product) async {
    if (product.id == null) {
      throw Exception("Product ID is null");
    }

    await SupabaseHelper.client
        .from(_table)
        .update(product.toJson())
        .eq('id', product.id as Object);
  }

  // ===============================
  // Add New Product + Transaction
  // ===============================
  static Future<Product> addProduct({
    required String name,
    required int quantity,
    required double purchasePrice,
    required double salePrice,
    File? imageFile,
    Uint8List? imageBytes,
  }) async {
    if (name.isEmpty) {
      throw Exception("اسم المنتج مطلوب");
    }

    // ---------- Upload Image ----------
    String? imageUrl;
    if (imageFile != null || imageBytes != null) {
      final fileName =
          'prod_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final bytes =
          imageBytes ?? await imageFile!.readAsBytes();
      imageUrl = await _uploadImageToSupabase(bytes, fileName);
    }

    final code = 'PRD-${DateTime.now().millisecondsSinceEpoch}';

    // ---------- Insert Product ----------
    final productResponse = await SupabaseHelper.client
        .from(_table)
        .insert({
          'name': name,
          'code': code,
          'totalQuantity': quantity,
          'PurchasePrice': purchasePrice,
          'SellingPrice': salePrice,
          'image': imageUrl ?? 'https://via.placeholder.com/150',
        })
        .select()
        .single();

    final product = Product.fromJson(productResponse);

    // ---------- Insert Transaction ----------
    await SupabaseHelper.client
        .from(_transactionsTable)
        .insert({
      'product_id': product.id,
      'quantity': quantity,
      'model': 'stock',
      'model_id': product.id,
      'type': 'in', // دخول مخزون
      'created_at': DateTime.now().toIso8601String(),
    });

    return product;
  }

  // ===============================
  // Update Product With Image
  // ===============================
  static Future<Product> updateProductWithImage({
    required Product product,
    required String name,
    required int quantity,
    required double purchasePrice,
    required double sellingPrice,
    File? imageFile,
    Uint8List? imageBytes,
  }) async {
    if (product.id == null) {
      throw Exception("Product ID is null");
    }

    if (name.isEmpty) {
      throw Exception("اسم المنتج مطلوب");
    }

    String imageUrl = product.image;

    if (imageFile != null || imageBytes != null) {
      final fileName =
          'prod_${product.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final bytes =
          imageBytes ?? await imageFile!.readAsBytes();
      final newUrl =
          await _uploadImageToSupabase(bytes, fileName);
      if (newUrl != null) imageUrl = newUrl;
    }

    final updatedProduct = Product(
      id: product.id,
      name: name,
      code: product.code,
      image: imageUrl,
      totalQuantity: quantity,
      purchasePrice: purchasePrice,
      sellingPrice: sellingPrice,
    );

    await updateProduct(updatedProduct);

    return updatedProduct;
  }

  // ===============================
  // Delete Product
  // ===============================
  static Future<void> deleteProduct(int id) async {
    await SupabaseHelper.client
        .from(_table)
        .delete()
        .eq('id', id);
  }

  // ===============================
  // Upload Image
  // ===============================
  static Future<String?> _uploadImageToSupabase(
      Uint8List bytes, String fileName) async {
    try {
      await Supabase.instance.client.storage
          .from(_storageBucket)
          .uploadBinary(
            fileName,
            bytes,
            fileOptions: const FileOptions(upsert: true),
          );

      final url = Supabase.instance.client.storage
          .from(_storageBucket)
          .getPublicUrl(fileName);

      debugPrint('تم رفع الصورة: $url');
      return url;
    } catch (e) {
      debugPrint('خطأ رفع الصورة: $e');
      return null;
    }
  }

  // ===============================
  // Check Image Type
  // ===============================
  static bool isNetworkImage(String imagePath) {
    return imagePath.startsWith('http');
  }
}
