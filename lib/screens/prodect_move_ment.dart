import 'package:flutter/material.dart';
import 'package:software_system/data/prodect_data.dart';

class ProductMovementsScreen extends StatelessWidget {
  const ProductMovementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('حركات المنتجات'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ListView.builder(
          itemCount: ProductData.products.length,
          itemBuilder: (context, index) {
            final product = ProductData.products[index];

            final String name = product.name;
            final String move = product.move;
            final String type = product.type;
            final int remainingQuantity = product.remainingQuantity;

            final bool isIncoming = type == 'وارد';
            final bool isLowStock = remainingQuantity < 3;

            // ✅ تحديد اللون حسب نوع الحركة
            Color moveTextColor;
            Color? moveBackgroundColor;

            if (move == 'رصيد افتتاحي') {
              moveTextColor = Colors.green[700]!;
              moveBackgroundColor = Colors.green[50];
            } else if (move == 'مشتريات') {
              moveTextColor = Colors.green[700]!; // أخضر غامق للمشتريات
              moveBackgroundColor = Colors.green[100];
            } else {
              moveTextColor = Colors.red[700]!;
              moveBackgroundColor = Colors.red[50];
            }

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
                    // 📦 اسم المنتج + الحركة تحته
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: moveBackgroundColor,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              move,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: moveTextColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 10),

                    // 🔄 النوع (وارد / صادر)
                    Expanded(
                      flex: 1,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          color: isIncoming
                              ? Colors.green[50]
                              : Colors.red[50],
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color:
                                isIncoming ? Colors.green : Colors.red,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            type,
                            style: TextStyle(
                              color: isIncoming
                                  ? Colors.green[700]
                                  : Colors.red[700],
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    //  الكمية المتبقية
                    Expanded(
                      flex: 1,
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isLowStock
                                  ? Icons.arrow_downward
                                  : Icons.arrow_upward,
                              color:
                                  isLowStock ? Colors.red : Colors.green,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              remainingQuantity.toString(),
                              style: TextStyle(
                                color: isLowStock
                                    ? Colors.red
                                    : Colors.green,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    // 🕒 التاريخ
                    Expanded(
                      flex: 2,
                      child: Text(
                        DateTime.now()
                            .subtract(Duration(days: index))
                            .toString()
                            .substring(0, 16),
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
