import 'dart:math';
import 'package:flutter/material.dart';
import 'package:software_system/service/supabase_helper.dart';
import 'package:software_system/widgets/custom_add_prodect.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final nameController = TextEditingController();
  final codeController = TextEditingController();
  final quantityController = TextEditingController();
  final supplierController = TextEditingController();
  final purchaseController = TextEditingController();
  final saleController = TextEditingController();

  String? selectedImageAsset;

  final List<String> imageList = [
    "assets/images/4kAction.jpg",
    "assets/images/DRON-X.jpg",
    "assets/images/fintness.jpg",
    "assets/images/gamingchar.jpg",
    "assets/images/gaminglaptop.jpg",
    "assets/images/HardDisk.jpg",
    "assets/images/headphone.jpg",
    "assets/images/iphone14.png",
    "assets/images/keyboardRGB.png",
    "assets/images/laptopMac.jpg",
    "assets/images/mouseWireLess.png",
    "assets/images/placeholder.jpg",
    "assets/images/profile.jpg",
    "assets/images/send_icons.png",
    "assets/images/smart_inventory.png",
    "assets/images/smartTV.png",
    "assets/images/Tablet.jpg",
  ];

  String generateProductCode() {
    final now = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(999);
    return "PRD-$now$random";
  }

  void pickImageFromAssets() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("اختار صورة"),
        content: SizedBox(
          width: 300,
          height: 300,
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: imageList.length,
            itemBuilder: (_, i) => InkWell(
              onTap: () {
                setState(() => selectedImageAsset = imageList[i]);
                Navigator.pop(context);
              },
              child: Image.asset(imageList[i], fit: BoxFit.cover),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> addProduct() async {
    final name = nameController.text.trim();
    final code = generateProductCode();
    final quantity = int.tryParse(quantityController.text.trim()) ?? 0;
    final purchasePrice =
        double.tryParse(purchaseController.text.trim()) ?? 0.0;
    final salePrice = double.tryParse(saleController.text.trim()) ?? 0.0;

    if (name.isEmpty) return;

    try {
      final response = await SupabaseHelper.client
          .from('products')
          .insert({
            'name': name,
            'code': code,
            'totalQuantity': quantity,
            'PurchasePrice': purchasePrice,
            'SellingPrice': salePrice,
            'image': selectedImageAsset,
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .select()
          .maybeSingle();

      print("Added: $response");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("تم إضافة المنتج بنجاح"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("حدث خطأ أثناء إضافة المنتج"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    codeController.text = generateProductCode();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1960fb), Color(0xFF3d37c1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Container(
            width: 400,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: const [
                BoxShadow(color: Colors.black26, blurRadius: 8),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const Text(
                    "اضف منتج جديد",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: CustomAddProdect(
                          label: "اسم المنتج",
                          controller: nameController,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: CustomAddProdect(
                          label: "الكود",
                          controller: codeController,
                          enabled: false,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Expanded(
                        child: CustomAddProdect(
                          label: "الكميه",
                          controller: quantityController,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: CustomAddProdect(
                          label: "المورد",
                          controller: supplierController,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Expanded(
                        child: CustomAddProdect(
                          label: "سعر الشراء",
                          controller: purchaseController,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: CustomAddProdect(
                          label: "سعر البيع",
                          controller: saleController,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: pickImageFromAssets,
                    child: const Text("اختيار صورة"),
                  ),

                  if (selectedImageAsset != null) ...[
                    const SizedBox(height: 10),
                    Image.asset(selectedImageAsset!, height: 120),
                  ],

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: ElevatedButton(
                      onPressed: addProduct,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                      child: const Text(
                        "اضف المنتج",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                  ),

                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("إلغاء"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
