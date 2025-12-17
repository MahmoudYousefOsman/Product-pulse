import 'package:flutter/material.dart';
import '../service/order_service.dart';
import '../models/order_model.dart';
import 'new_order_screen.dart';
import 'invoice_screen.dart';
// بما أن صفحة AllProdect تستخدم CustomDrawer، قد تحتاج إلى استيرادها هنا إذا كانت موجودة
// import 'package:software_system/widgets/custom_drawer.dart'; 

// تعريف الألوان المستخدمة لضمان الثبات
const Color _kPrimaryColor = Color(0xFF6C63FF); // اللون الأساسي (بنفسجي/أزرق غامق)
const Color _kGradientEndColor = Color(0xFF8D88FF); // تدرج فاتح للون الأساسي
const Color _kAccentColor = Color(0xFF1ABC9C); // لون التمييز/الإجمالي (أخضر فيروزي)
const Color _kListBackgroundColor = Color(0xFFF8F9FF); // خلفية منطقة القائمة (فاتح جداً)


class OrdersListScreen extends StatefulWidget {
  const OrdersListScreen({super.key});

  @override
  State<OrdersListScreen> createState() => _OrdersListScreenState();
}

class _OrdersListScreenState extends State<OrdersListScreen> with SingleTickerProviderStateMixin {
  late Future<List<Order>> _ordersFuture;
  final OrderService _orderService = OrderService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _refreshOrders();
    _searchController.addListener(_updateSearchQuery);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _searchController.removeListener(_updateSearchQuery);
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _updateSearchQuery() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
    });
  }

  void _refreshOrders() {
    setState(() {
      _ordersFuture = _orderService.fetchOrdersList().then((orders) {
        if (orders.isNotEmpty && _animationController.status != AnimationStatus.forward) {
             _animationController.forward(from: 0);
        }
        return orders;
      });
    });
  }

  // دالة عرض رسالة عائمة
  void _showSnackbar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              color == Colors.green ? Icons.check_circle : Icons.error,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // دالة تأكيد الحذف
  void _confirmDeleteOrder(int orderId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
            ),
            const SizedBox(width: 12),
            const Text('تأكيد الحذف', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          ],
        ),
        content: const Text('هل أنت متأكد أنك تريد مسح هذا الطلب؟ لن تتمكن من استرجاعه.', style: TextStyle(fontSize: 15, height: 1.5)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('إلغاء', style: TextStyle(color: Colors.grey[700], fontSize: 16, fontWeight: FontWeight.w600)),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Colors.red, Colors.redAccent]),
              borderRadius: BorderRadius.circular(10),
            ),
            child: ElevatedButton.icon(
              onPressed: () async {
                Navigator.of(ctx).pop();
                try {
                  await _orderService.deleteOrder(orderId);
                  _refreshOrders();
                  _showSnackbar('تم مسح الطلب بنجاح ✓', Colors.green);
                } catch (e) {
                  _showSnackbar('فشل مسح الطلب: $e', Colors.red);
                }
              },
              icon: const Icon(Icons.delete_forever, size: 20),
              label: const Text('حذف', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ويدجت زر الإجراءات داخل البطاقة (مثل صفحة المنتجات)
  Widget _buildActionIcon({required IconData icon, required Color color, required VoidCallback onTap}) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: IconButton(
        icon: Icon(icon, color: color, size: 22),
        onPressed: onTap,
      ),
    );
  }

  // ============================ بطاقة الطلب (Card) بتصميم جديد ============================
  Widget _buildOrderCard(Order order) {
    final clientName = order.client?.name ?? 'عميل غير معروف';
    final orderIdLabel = 'ORD-${order.id}';
    final total = '${order.totalPrice.toStringAsFixed(2)} ج.م';
    final date = order.createdAt.toString().split(' ')[0];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // فتح شاشة التفاصيل (InvoiceScreen)
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => InvoiceScreen(orderId: order.id)),
            ).then((_) => _refreshOrders());
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // أيقونة الطلب (مثل صورة المنتج)
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [_kPrimaryColor, _kGradientEndColor],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: _kPrimaryColor.withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.receipt_long, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 16),
                
                // تفاصيل الطلب (الاسم والسعر)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        clientName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        orderIdLabel,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          // الإجمالي
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _kAccentColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.monetization_on, color: _kAccentColor, size: 14),
                                const SizedBox(width: 4),
                                Text(
                                  total,
                                  style: TextStyle(
                                    color: _kAccentColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          // التاريخ
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.calendar_today, color: Colors.grey[600], size: 12),
                                const SizedBox(width: 4),
                                Text(
                                  date,
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                
                // زر عرض (View)
                _buildActionIcon(
                  icon: Icons.visibility,
                  color: _kPrimaryColor,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => InvoiceScreen(orderId: order.id)),
                    ).then((_) => _refreshOrders());
                  },
                ),
                const SizedBox(width: 8),
                
                // زر الحذف (Delete)
                _buildActionIcon(
                  icon: Icons.delete_outline,
                  color: Colors.red.shade600!,
                  onTap: () => _confirmDeleteOrder(order.id),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  // ============================ بناء الشاشة الرئيسية ============================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // يمكن إضافة CustomDrawer هنا إذا كان مستخدماً في التطبيق
      // drawer: const CustomDrawer(),
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_kPrimaryColor, _kGradientEndColor], // #6C63FF -> #8D88FF
            ),
          ),
        ),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "قائمة الطلبات",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: _refreshOrders,
            tooltip: 'تحديث',
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Container(
        // الخلفية الرئيسية بتدرج الألوان
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_kPrimaryColor, _kGradientEndColor],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // قسم العنوان الفرعي
              Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.shopping_bag, color: Colors.white, size: 28),
                        SizedBox(width: 10),
                        Text(
                          "إدارة المبيعات",
                          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "كل الطلبات والفواتير الصادرة",
                      style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 16),
                    ),
                  ],
                ),
              ),
              
              // شريط البحث وزر الإضافة
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _searchController,
                          textAlign: TextAlign.right,
                          decoration: InputDecoration(
                            hintText: "ابحث باسم العميل أو رقم الطلب...",
                            hintStyle: TextStyle(color: Colors.grey[400]),
                            prefixIcon: const Icon(Icons.search, color: _kPrimaryColor),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // زر الإضافة
                    Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [_kPrimaryColor, _kGradientEndColor],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: _kPrimaryColor.withOpacity(0.4),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context)
                              .push(MaterialPageRoute(
                            builder: (context) => const NewOrderScreen(),
                          ))
                              .then((_) => _refreshOrders());
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const Icon(Icons.add, color: Colors.white, size: 28),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              
              // قائمة الطلبات (المنطقة الفاتحة)
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: _kListBackgroundColor, // خلفية البطاقات الفاتحة
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                    child: FutureBuilder<List<Order>>(
                      future: _ordersFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator(color: _kPrimaryColor));
                        }
                        
                        if (snapshot.hasError) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Text("خطأ: ${snapshot.error}", style: const TextStyle(color: Colors.red, fontSize: 16)),
                            ),
                          );
                        }

                        var orders = snapshot.data ?? [];
                        orders = orders.where((order) {
                          final clientName = order.client?.name.toLowerCase() ?? '';
                          final orderId = 'ord-${order.id}'.toLowerCase();
                          return clientName.contains(_searchQuery) || orderId.contains(_searchQuery);
                        }).toList();

                        if (orders.isEmpty && _searchQuery.isEmpty) {
                           return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.shopping_bag_outlined, size: 80, color: Colors.grey[400]),
                                const SizedBox(height: 16),
                                Text(
                                  "لا توجد طلبات حالياً",
                                  style: TextStyle(fontSize: 18, color: Colors.grey[600], fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          );
                        }
                         if (orders.isEmpty && _searchQuery.isNotEmpty) {
                            return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.search_off, size: 80, color: Colors.grey[400]),
                                const SizedBox(height: 16),
                                Text(
                                  "لا توجد نتائج بحث",
                                  style: TextStyle(fontSize: 18, color: Colors.grey[600], fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          );
                        }
                        
                        return RefreshIndicator(
                          onRefresh: () async => _refreshOrders(),
                          color: _kPrimaryColor,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: orders.length,
                            itemBuilder: (context, index) {
                              final order = orders[index];
                              
                              return FadeTransition(
                                opacity: _animationController,
                                child: SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(0.3, 0),
                                    end: Offset.zero,
                                  ).animate(CurvedAnimation(
                                    parent: _animationController,
                                    curve: Curves.easeOut,
                                  )),
                                  child: _buildOrderCard(order),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}