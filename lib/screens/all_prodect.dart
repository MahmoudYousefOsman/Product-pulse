import 'package:flutter/material.dart';
import 'package:software_system/service/Product_Service.dart';
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

  // دالة عرض الصور سواء من assets أو Supabase
  Widget _buildSmartImage(String imagePath) {
    if (imagePath.startsWith('http') || imagePath.startsWith('https')) {
      return Image.network(
        imagePath,
        width: 70,
        height: 60,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: 70,
            height: 60,
            color: Colors.grey[200],
            child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Image.asset(
            "assets/images/placeholder.jpg",
            width: 70,
            height: 60,
            fit: BoxFit.cover,
          );
        },
      );
    } else {
      return Image.asset(
        imagePath,
        width: 70,
        height: 60,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Image.asset(
            "assets/images/placeholder.jpg",
            width: 70,
            height: 60,
            fit: BoxFit.cover,
          );
        },
      );
    }
  }

  // نافذة تفاصيل المنتج مع دعم الصور الجديدة
  void _showProductDetails(Product product) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 10,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.blue.shade400, Colors.blue.shade600],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'تفاصيل المنتج',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.3), shape: BoxShape.circle),
                        padding: const EdgeInsets.all(6),
                        child: const Icon(Icons.close, size: 18, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          width: double.infinity,
                          height: 150,
                          decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(14)),
                          child: _buildSmartImage(product.image), // دعم الصور الجديدة هنا
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.grey[200]!, width: 1),
                      ),
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        children: [
                          _buildDetailRow('الاسم', product.name),
                          const Divider(height: 18, color: Colors.grey),
                          _buildDetailRow('الكود', product.code),
                          const Divider(height: 18, color: Colors.grey),
                          _buildDetailRow('سعر الشراء', '${product.purchasePrice} \$'),
                          const Divider(height: 18, color: Colors.grey),
                          _buildDetailRow('سعر البيع', '${product.sellingPrice} \$'),
                          const Divider(height: 18, color: Colors.grey),
                          _buildDetailRow('الكمية الإجمالية', '${product.totalQuantity}'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade500,
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('إغلاق', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.black54)),
        Flexible(
          child: Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.black87),
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }

  Future<void> _deleteProduct(Product product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف المنتج'),
        content: Text('هل تريد حذف "${product.name}" بشكل نهائي؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('إلغاء')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ProductService.deleteProduct(product.id!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              content: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [Colors.green.shade400, Colors.green.shade700]),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(16),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.white, size: 26),
                    SizedBox(width: 12),
                    Text('تم حذف المنتج بنجاح!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              backgroundColor: Colors.transparent,
            ),
          );
          _refreshProducts();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('خطأ في الحذف: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
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
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Colors.blue.shade400, Colors.blue.shade500]),
          ),
        ),
        elevation: 0,
        centerTitle: true,
        title: const Text("كل المنتجات", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        actions: const [
          CircleAvatar(radius: 25, backgroundColor: Colors.transparent, backgroundImage: AssetImage("assets/Images/smart_inventory.png")),
          SizedBox(width: 10),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Colors.blue.shade400, Colors.blue.shade700]),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("كل المنتجات", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 4),
                const Text("إدارة مخزوني", style: TextStyle(color: Colors.white, fontSize: 17)),
                const SizedBox(height: 20),
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
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      onPressed: () async {
                        final newProduct = await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddProductScreen()));
                        if (newProduct == true) _refreshProducts();
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
                Expanded(
                  child: FutureBuilder<List<Product>>(
                    future: _productsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.error, color: Colors.red, size: 50), Text("خطأ: ${snapshot.error}"), ElevatedButton(onPressed: _refreshProducts, child: const Text("إعادة المحاولة"))]));
                      }

                      var products = snapshot.data ?? [];

                      if (_searchQuery.isNotEmpty) {
                        products = products.where((p) => p.name.toLowerCase().contains(_searchQuery) || p.code.toLowerCase().contains(_searchQuery)).toList();
                      }

                      if (products.isEmpty) {
                        return const Center(child: Text("لا توجد منتجات", style: TextStyle(fontSize: 18, color: Colors.grey)));
                      }

                      return RefreshIndicator(
                        onRefresh: () async => _refreshProducts(),
                        child: ListView.builder(
                          itemCount: products.length,
                          itemBuilder: (context, index) {
                            final product = products[index];
                            final bool isLow = product.totalQuantity <= 3;

                            return Container(
                              width: double.infinity,
                              height: 83,
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                              ),
                              child: Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 15),
                                    child: SizedBox(
                                      width: 70,
                                      height: 60,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: _buildSmartImage(product.image),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(15.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(product.name, style: const TextStyle(fontWeight: FontWeight.w500)),
                                          Text(product.code, style: const TextStyle(color: Colors.black38)),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(isLow ? Icons.arrow_downward : Icons.arrow_upward, color: isLow ? Colors.red : Colors.green, size: 18),
                                      const SizedBox(width: 5),
                                      Text(
                                        "${product.totalQuantity}", // تم تصليح null هنا
                                        style: TextStyle(color: isLow ? Colors.red : Colors.green.shade700, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  const Spacer(),
                                  Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text("${product.purchasePrice} \$"),
                                        Text("${product.sellingPrice} \$"),
                                      ],
                                    ),
                                  ),
                                  PopupMenuButton<String>(
                                    onSelected: (value) {
                                      if (value == 'show') {
                                        _showProductDetails(product);
                                      } else if (value == 'edit') {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (_) => EditProductScreen(product: product)),
                                        ).then((_) => _refreshProducts());
                                      } else if (value == 'delete') {
                                        _deleteProduct(product);
                                      }
                                    },
                                    itemBuilder: (context) => const [
                                      PopupMenuItem(value: 'show', child: Row(children: [Icon(Icons.visibility, color: Colors.blue), SizedBox(width: 8), Text('عرض')])),
                                      PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, color: Colors.orange), SizedBox(width: 8), Text('تعديل')])),
                                      PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, color: Colors.red), SizedBox(width: 8), Text('حذف')])),
                                    ],
                                    icon: const Icon(Icons.more_vert, color: Colors.grey),
                                  ),
                                ],
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
        ),
      ),
    );
  }
}
