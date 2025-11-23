import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:software_system/widgets/custom_add_prodect.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController codeController = TextEditingController(
    text: "PRD-XXX",
  );
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController supplierController = TextEditingController();
  final TextEditingController purchaseController = TextEditingController();
  final TextEditingController saleController = TextEditingController();

  File? _imageFile;

  // 📸 دالة لاختيار الصورة من الجهاز
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1960fb), Color(0xFF3d37c1)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Center(
            child: Container(
              width: 400,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const Text(
                      "اضف منتج جديد",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      "قم بإدخال تفاصيل المنتج لإضافته إلى مخزونك ",
                      style: TextStyle(color: Colors.grey, fontSize: 17),
                    ),
                    const SizedBox(height: 20),

                    // 🔹 اسم المنتج + الكود
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
                            label: "الكود ",
                            controller: codeController,
                            enabled: false,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // 🔹 الكمية والمورد
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

                    // 🔹 سعر الشراء والبيع
                    Row(
                      children: [
                        Expanded(
                          child: CustomAddProdect(
                            label: "سعر الشراء ",
                            controller: purchaseController,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: CustomAddProdect(
                            label: "سعر البيع " ,
                            controller: saleController,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 15),

                    // 🔹 الصورة
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "اضافه صوره ",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(height: 5),

                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        width: double.infinity,
                        height: 45,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.upload, color: Colors.black54),
                            const SizedBox(width: 8),
                            Text(
                              _imageFile == null
                                  ? "رفع الصوره "
                                  : "تم تحديد الصوره ",
                              style: const TextStyle(color: Colors.black87),
                            ),
                          ],
                        ),
                      ),
                    ),

                    if (_imageFile != null) ...[
                      const SizedBox(height: 10),
                      Image.file(_imageFile!, height: 120),
                    ],

                    const SizedBox(height: 20),

                    // 🔹 زر الإضافة
                    SizedBox(
                      width: double.infinity,
                      height: 45,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(7),
                          ),
                        ),
                        onPressed: () {
                          // هنا تقدر تضيف دالة حفظ المنتج في Supabase
                          print("Product Added!");
                        },
                        child: const Text(
                          "اضف المنتج",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // 🔹 زر الإلغاء
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        "الغاء",
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
