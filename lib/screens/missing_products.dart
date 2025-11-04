import 'package:flutter/material.dart';
import 'package:software_system/data/prodect_data.dart';

class MissingProducts extends StatelessWidget {
  const MissingProducts({super.key});

  
  Color _getColor(int quantity) {
    if (quantity == 0) return Colors.red; 
    if (quantity <= 2) return Colors.amber; 
    return Colors.green; 
  }

  @override
  Widget build(BuildContext context) {
    
    final missingProducts = ProductData.products
        .where((product) => product.totalQuantity <= 3)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("المنتجات الناقصة"),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: missingProducts.isEmpty
            ? const Center(
                child: Text(
                  "لا توجد منتجات ناقصة 🎉",
                  style: TextStyle(fontSize: 18, color: Colors.green),
                ),
              )
            : Center(
                child: Table(
                  border: TableBorder.all(color: Colors.black, width: 1),
                  columnWidths: const {
                    0: FlexColumnWidth(3),
                    1: FlexColumnWidth(1),
                  },
                  children: [
                  
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

                    
                    for (var product in missingProducts)
                      TableRow(
                        children: [
                          
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              product.name,
                              style: const TextStyle(fontSize: 15),
                            ),
                          ),

                         
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
              ),
      ),
    );
  }
}
