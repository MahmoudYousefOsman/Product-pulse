// screens/all_products_screen.dart
import 'package:flutter/material.dart';
import 'package:software_system/service/product_data.dart';
import 'package:software_system/Models/products.dart';
import 'package:software_system/screens/add_prodects.dart';
import 'package:software_system/screens/edit_prodect_screens.dart';
import 'package:software_system/widgets/custom_drawer.dart';

class AllProdect extends StatefulWidget {
  const AllProdect({super.key});

  @override
  State<AllProdect> createState() => _AllProdectState();
}

class _AllProdectState extends State<AllProdect> {
  late Future<List<Product>> _productsFuture;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _refreshProducts();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  void _refreshProducts() {
    setState(() {
      _productsFuture = ProductService.getAllProducts();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CustomDrawer(),
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "كل المنتجات",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: const [
          CircleAvatar(
            radius: 25,
            backgroundColor: Colors.transparent,
            backgroundImage: AssetImage("assets/Images/smart_inventory.png"),
          ),
          SizedBox(width: 10),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "كل المنتجات",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              "إدارة مخزوني",
              style: TextStyle(color: Colors.grey, fontSize: 17),
            ),
            const SizedBox(height: 20),

            // البحث + إضافة
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: "بحث",
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: () async {
                    final newProduct = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AddProductScreen()),
                    );
                    if (newProduct == true) _refreshProducts(); // تحديث بعد الإضافة
                  },
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text("إضافة منتج", style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // عرض المنتجات من Supabase
            Expanded(
              child: FutureBuilder<List<Product>>(
                future: _productsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.error, color: Colors.red, size: 50),
                          Text("خطأ: ${snapshot.error}"),
                          ElevatedButton(onPressed: _refreshProducts, child: const Text("إعادة المحاولة")),
                        ],
                      ),
                    );
                  }

                  var products = snapshot.data ?? [];

                  // فلترة البحث
                  if (_searchQuery.isNotEmpty) {
                    products = products
                        .where((p) =>
                            p.name.toLowerCase().contains(_searchQuery) ||
                            p.code.toLowerCase().contains(_searchQuery))
                        .toList();
                  }

                  if (products.isEmpty) {
                    return const Center(
                      child: Text(
                        "لا توجد منتجات",
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async => _refreshProducts(),
                    child: ListView.builder(
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        final int quantity = product.totalQuantity;
                        final bool isLow = quantity <= 3;

                        return GestureDetector(
                          onTap: () async {
                            final updated = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => EditProductScreen(product: product),
                              ),
                            );

                            // إذا رجع منتج محدث أو تم حذفه
                            if (updated == true || updated is Product) {
                              _refreshProducts(); // أفضل طريقة مع Supabase
                            }
                          },
                          child: Container(
                            width: double.infinity,
                            height: 83,
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: const [
                                BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
                              ],
                            ),
                            child: Row(
                              children: [
                                // الصورة
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 15),
                                  child: SizedBox(
                                    width: 70,
                                    height: 60,
                                    child:Image.asset(
                                      product.image,
                                      width: 70,
                                      height: 60,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Image.asset(
                                          'assets/images/placeholder.jpg',
                                          width: 70,
                                          height: 60,
                                          fit: BoxFit.cover,
                                        );
                                      },

                                    ),
                                  ),
                                ),

                                // الاسم والكود
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(15.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(product.name, style: const TextStyle(fontWeight: FontWeight.w500)),
                                        Text(product.code, style: const TextStyle(color: Colors.black38)),
                                      ],
                                    ),
                                  ),
                                ),

                                // الكمية
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      isLow ? Icons.arrow_downward : Icons.arrow_upward,
                                      color: isLow ? Colors.red : Colors.green,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      "$quantity",
                                      style: TextStyle(
                                        color: isLow ? Colors.red : Colors.green.shade700,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),

                                const Spacer(),

                                // الأسعار
                                Padding(
                                  padding: const EdgeInsets.all(15.0),
                                  child: Column(
                                    children: [
                                      Text("${product.purchasePrice} \$"),
                                      Text("${product.sellingPrice} \$"),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}