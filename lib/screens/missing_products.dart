import 'package:flutter/material.dart';
import 'package:software_system/service/Product_Service.dart';
import 'package:software_system/Models/products.dart';

// تعريف درجات اللون الأزرق المستخدمة في صفحة AllClient
const Color _kPrimaryDark = Color(0xFF1976D2); // Colors.blue.shade700
const Color _kAccentLight = Color(0xFFE3F2FD); // Colors.blue.shade50 (خلفية فاتحة)
const Color _kDarkTextColor = Color(0xFF0D47A1); // Colors.blue.shade900 (نص غامق)
const Color _kAccentMid = Color(0xFF42A5F5); // Colors.blue.shade400 (تدرج أيقونة)
const Color _kShadowLight = Color(0xFFBBDEFB); // Colors.blue.shade100 (ظل خفيف)

class MissingProducts extends StatefulWidget {
  const MissingProducts({super.key});

  @override
  State<MissingProducts> createState() => _MissingProductsState();
}

class _MissingProductsState extends State<MissingProducts> with SingleTickerProviderStateMixin {
  late Future<List<Product>> _productsFuture;
  AnimationController? _animationController;

  @override
  void initState() {
    super.initState();
    _productsFuture = _fetchMissingProducts();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  Future<List<Product>> _fetchMissingProducts() async {
    final allProducts = await ProductService.getAllProducts();
    
    // تصفية المنتجات التي كميتها أقل من أو تساوي 3
    final missingProducts = allProducts.where((p) => ProductService.isLowStock(p)).toList();

    if (missingProducts.isNotEmpty) {
      _animationController?.forward(from: 0);
    }
    
    return missingProducts;
  }

  // ألوان حالة الكمية (تم إبقائها واضحة ولكن متناسقة مع الخلفية)
  Color _getColor(int quantity) {
    if (quantity == 0) return Colors.red.shade600;
    if (quantity <= 2) return Colors.amber.shade700;
    return Colors.green.shade600;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // لون الخلفية الأساسي يعتمد على تدرج غامق في الأعلى وفاتح في الأسفل
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_kPrimaryDark, _kAccentLight], // من الأزرق الغامق إلى الفاتح جداً
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // رأس الصفحة (Header)
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      "المنتجات الناقصة",
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const Spacer(),
                    // عرض عدد المنتجات الناقصة
                    FutureBuilder<List<Product>>(
                      future: _productsFuture,
                      builder: (context, snapshot) {
                        final count = snapshot.data?.length ?? 0;
                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2), // خلفية شفافة بيضاء
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Text(
                            "$count",
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              // قائمة المنتجات
              Expanded(
                child: FutureBuilder<List<Product>>(
                  future: _productsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: Colors.white));
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          "حدث خطأ: ${snapshot.error}",
                          style: const TextStyle(color: Colors.white, fontSize: 18),
                          textAlign: TextAlign.center,
                        ),
                      );
                    }

                    final missingProducts = snapshot.data ?? [];

                    if (missingProducts.isEmpty) {
                      return Center(
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          margin: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [BoxShadow(color: _kShadowLight, blurRadius: 10)], // ظل خفيف
                          ),
                          child: Text(
                            "🎉 جميع المنتجات متوفرة بكمية كافية!",
                            style: TextStyle(fontSize: 20, color: _kDarkTextColor, fontWeight: FontWeight.bold),
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: missingProducts.length,
                      itemBuilder: (context, index) {
                        final product = missingProducts[index];

                        final animation = Tween<double>(begin: 0, end: 1).animate(
                          CurvedAnimation(
                            parent: _animationController!,
                            curve: Interval(
                              (index / missingProducts.length) * 0.5,
                              ((index + 1) / missingProducts.length) * 0.5 + 0.5,
                              curve: Curves.easeOut,
                            ),
                          ),
                        );

                        return AnimatedBuilder(
                          animation: animation,
                          builder: (context, child) => Transform.translate(
                            offset: Offset(0, 50 * (1 - animation.value)),
                            child: Opacity(opacity: animation.value, child: child),
                          ),
                          child: _ProductCard(
                            product: product,
                            quantityColor: _getColor(product.totalQuantity),
                            kAccentMid: _kAccentMid,
                            kPrimaryDark: _kPrimaryDark,
                            kDarkTextColor: _kDarkTextColor,
                            kAccentLight: _kAccentLight,
                            kShadowLight: _kShadowLight,
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================ بطاقة المنتج بتصميم الأزرق ============================
class _ProductCard extends StatelessWidget {
  final Product product;
  final Color quantityColor;
  final Color kAccentMid;
  final Color kPrimaryDark;
  final Color kDarkTextColor;
  final Color kAccentLight;
  final Color kShadowLight;

  const _ProductCard({
    required this.product,
    required this.quantityColor,
    required this.kAccentMid,
    required this.kPrimaryDark,
    required this.kDarkTextColor,
    required this.kAccentLight,
    required this.kShadowLight,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 5,
      child: Container(
        decoration: BoxDecoration(
          // تدرج البطاقة من الأبيض إلى الأزرق الفاتح جداً
          gradient: LinearGradient(
            colors: [Colors.white, kAccentLight],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: kShadowLight,
              blurRadius: 10,
              spreadRadius: 1,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // أيقونة المنتج بتدرج أزرق غامق
            Container(
              width: 55,
              height: 55,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [kAccentMid, kPrimaryDark], // Colors.blue.shade400 to Colors.blue.shade700
                ),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(color: kShadowLight, blurRadius: 10, spreadRadius: 2),
                ],
              ),
              child: const Icon(Icons.inventory_2, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 15),
            
            // تفاصيل المنتج
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: kDarkTextColor, // Colors.blue.shade900
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Icon(Icons.qr_code, size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 5),
                      Text(product.code,
                          style: TextStyle(color: Colors.grey.shade700)),
                    ],
                  ),
                ],
              ),
            ),
            
            // الكمية مع اللون المناسب للحالة
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
              decoration: BoxDecoration(
                color: quantityColor.withOpacity(0.1), // خلفية خفيفة بلون الحالة
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: quantityColor.withOpacity(0.5), width: 1),
              ),
              child: Text(
                product.totalQuantity.toString(),
                style: TextStyle(
                  color: quantityColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}