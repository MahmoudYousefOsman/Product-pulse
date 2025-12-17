import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProductMovementsScreen extends StatefulWidget {
  const ProductMovementsScreen({super.key});

  @override
  State<ProductMovementsScreen> createState() =>
      _ProductMovementsScreenState();
}

class _ProductMovementsScreenState extends State<ProductMovementsScreen> {
  bool loading = true;
  List<Map<String, dynamic>> transactions = [];

  @override
  void initState() {
    super.initState();
    fetchTransactions();
  }

  Future fetchTransactions() async {
    try {
      final response = await Supabase.instance.client
          .from('product_transactions')
          .select('*, products(name)')
          .order('created_at', ascending: false);

      setState(() {
        transactions = List<Map<String, dynamic>>.from(response);
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryBlue = Colors.blue.shade700;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade700,
              Colors.blue.shade500,
              Colors.blue.shade300,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              /// ===== Header =====
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back,
                            color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 15),
                    const Text(
                      "حركات المنتجات",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              /// ===== Content =====
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                  ),
                  child: loading
                      ? const Center(child: CircularProgressIndicator())
                      : transactions.isEmpty
                          ? const Center(
                              child: Text("لا توجد حركات حتى الآن"),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(20),
                              itemCount: transactions.length,
                              itemBuilder: (context, index) {
                                final item = transactions[index];

                                final productName =
                                    item['products']?['name'] ?? 'غير معروف';

                                final model = (item['model'] ?? "")
                                    .toString()
                                    .toLowerCase();

                                final type = item['type'] ?? "in";
                                final quantity = item['quantity'] ?? 0;
                                final createdAt = item['created_at']
                                        ?.toString()
                                        .substring(0, 16) ??
                                    "";

                                String title;
                                Color color;
                                IconData icon;

                                switch (model) {
                                  case "stock":
                                    title = "رصيد افتتاحي";
                                    color = Colors.green;
                                    icon = Icons.inventory;
                                    break;
                                  case "orders":
                                    title = "أوردر";
                                    color = Colors.red;
                                    icon = Icons.shopping_cart;
                                    break;
                                  case "purchases":
                                    title = "مشتريات";
                                    color = Colors.blue;
                                    icon = Icons.shopping_bag;
                                    break;
                                  default:
                                    title = "غير معروف";
                                    color = Colors.grey;
                                    icon = Icons.help_outline;
                                }

                                // تحديد لون الخلفية للمربع بالكامل
                                Color backgroundColor;
                                if (model == "orders" && type == "in") {
                                  backgroundColor = Colors.green.withOpacity(0.15);
                                } else {
                                  backgroundColor = color.withOpacity(0.08);
                                }

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 15),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: backgroundColor,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: color, width: 1),
                                  ),
                                  child: Row(
                                    children: [
                                      /// Icon
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: color.withOpacity(0.15),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(icon, color: color),
                                      ),

                                      const SizedBox(width: 15),

                                      /// Info
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              productName,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 5),
                                            Text(
                                              title,
                                              style: TextStyle(
                                                color: color,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(height: 5),
                                            Text(
                                              createdAt,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      /// Quantity
                                      Column(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: type == "in"
                                                  ? Colors.green.withOpacity(0.15)
                                                  : Colors.red.withOpacity(0.15),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              type == "in" ? "وارد" : "صادر",
                                              style: TextStyle(
                                                color: type == "in"
                                                    ? Colors.green
                                                    : Colors.red,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            quantity.toString(),
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: primaryBlue,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
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
