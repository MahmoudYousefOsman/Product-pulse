// screens/missing_products.dart
import 'package:flutter/material.dart';
import 'package:software_system/service/prodect_data.dart'; // ← الكلاس اللي عملناه
import 'package:software_system/Models/prodects.dart';

class MissingProducts extends StatelessWidget {
  const MissingProducts({super.key});

  // نفس الدالة بتاعتك للألوان
  Color _getColor(int quantity) {
    if (quantity == 0) return Colors.red;
    if (quantity <= 2) return Colors.amber;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("المنتجات الناقصة"),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<List<Product>>(
          future: ProductService.getMissingProducts(),
          
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  "حدث خطأ: ${snapshot.error}",
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              );
            }

            final missingProducts = snapshot.data ?? [];

            if (missingProducts.isEmpty) {
              return const Center(
                child: Text(
                  "لا توجد منتجات ناقصة",
                  style: TextStyle(fontSize: 20, color: Colors.green),
                ),
              );
            }

            return Center(
              child: Table(
                border: TableBorder.all(color: Colors.black, width: 1),
                columnWidths: const {
                  0: FlexColumnWidth(3),
                  1: FlexColumnWidth(1),
                },
                children: [
                  // العنوان
                  const TableRow(
                    decoration: BoxDecoration(color: Color(0xFFE3F2FD)),
                    children: [
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Center(
                          child: Text(
                            "اسم المنتج",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Center(
                          child: Text(
                            "الكمية",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // الصفوف
                  for (var product in missingProducts)
                    TableRow(
                      children: [
                        // اسم المنتج
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            product.name,
                            style: const TextStyle(fontSize: 15),
                          ),
                        ),

                        // الكمية مع اللون
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: _getColor(product.totalQuantity),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: _getColor(product.totalQuantity),
                                  width: 1.5,
                                ),
                              ),
                              child: Text(
                                product.totalQuantity.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
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
    );
  }
}