import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProductMovementsScreen extends StatefulWidget {
  const ProductMovementsScreen({super.key});

  @override
  _ProductMovementsScreenState createState() => _ProductMovementsScreenState();
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
      print("Supabase Error: $e");
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("حركات المنتجات"),
          centerTitle: true,
          backgroundColor: Colors.blueAccent,
        ),
        body: loading
            ? const Center(child: CircularProgressIndicator())
            : transactions.isEmpty
            ? const Center(child: Text("لا توجد حركات حتى الآن"))
            : Padding(
            padding: const EdgeInsets.all(12.0),
            child: ListView.builder(
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final item = transactions[index];

                final String productName =
                    item['products']?['name'] ?? 'غير معروف';
                final String model =
                (item['model'] ?? "").toString().toLowerCase();
                final String type = item['type'] ?? "in"; // in / out
                final int quantity = item['quantity'] ?? 0;
                final String createdAt =
                    item['created_at']?.toString().substring(0, 16) ?? "";


                String transactionType;
                Color typeColor;

                switch (model) {
                  case "stock":
                    transactionType = "رصيد افتتاحي";
                    typeColor = Colors.green;
                    break;
                  case "orders":
                    transactionType = "أوردر";
                    typeColor = Colors.red;
                    break;
                  case "purchases":
                    transactionType = "مشتريات";
                    typeColor = Colors.green;
                    break;
                  default:
                    transactionType = "غير معروف";
                    typeColor = Colors.grey;
                }


                Color backgroundColor = typeColor.withOpacity(0.15);

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [

                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                productName,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                transactionType,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: typeColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 10),


                        Expanded(
                          flex: 1,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            decoration: BoxDecoration(
                              color: backgroundColor,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: typeColor),
                            ),
                            child: Center(
                              child: Text(
                                type == "in" ? "وارد" : "صادر",
                                style: TextStyle(
                                  color: typeColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 10),


                        Expanded(
                          flex: 1,
                          child: Center(
                            child: Text(
                              quantity.toString(),
                              style: TextStyle(
                                color: typeColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 10),


                        Expanded(
                          flex: 2,
                          child: Text(
                            createdAt,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            ),
        );
    }
}
