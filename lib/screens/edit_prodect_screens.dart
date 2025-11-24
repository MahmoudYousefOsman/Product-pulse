import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:software_system/Models/products.dart';

class EditProductScreen extends StatefulWidget {
  final Product product;

  const EditProductScreen({super.key, required this.product});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  late TextEditingController nameController;
  late TextEditingController codeController;
  late TextEditingController totalQuantityController;
  late TextEditingController soldQuantityController;
  late TextEditingController purchasePriceController;
  late TextEditingController sellingPriceController;

  String? _imagePath;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.product.name);
    codeController = TextEditingController(text: widget.product.code);
    totalQuantityController =
        TextEditingController(text: widget.product.totalQuantity.toString());
    soldQuantityController =
        TextEditingController(text: widget.product.soldQuantity.toString());
    purchasePriceController =
        TextEditingController(text: widget.product.purchasePrice.toString());
    sellingPriceController =
        TextEditingController(text: widget.product.sellingPrice.toString());
    _imagePath = widget.product.image;
  }

  // 📸 لاختيار صورة من المعرض
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imagePath = pickedFile.path;
      });
    }
  }

  // ⚠️ تأكيد الحذف
  Future<void> _confirmDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("تأكيد الحذف"),
        content: const Text("هل أنت متأكد أنك تريد حذف هذا المنتج نهائيًا؟"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("إلغاء"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("حذف"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      Navigator.pop(context, "delete");
    }
  }

  // 🖼 عرض الصورة
  Widget _buildProductImage() {
    if (_imagePath == null || _imagePath!.isEmpty) {
      return _noImageBox();
    }

    if (File(_imagePath!).existsSync()) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          File(_imagePath!),
          height: 180,
          width: 250,
          fit: BoxFit.cover,
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.asset(
        _imagePath!,
        height: 180,
        width: 250,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _noImageBox(),
      ),
    );
  }

  // 📦 لو مفيش صورة
  Widget _noImageBox() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text("اضغط لاختيار صورة", style: TextStyle(color: Colors.grey)),
        ),
      ),
    );
  }

  // 🧱 حقل إدخال منسق
  Widget _buildTextField(String label, TextEditingController controller,
      {bool isNumber = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            )),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            filled: true,
            fillColor: Colors.white24,
          ),
          style: const TextStyle(color: Colors.black),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 🎨 الخلفية
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1960fb), Color(0xFF3d37c1)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // 📄 المحتوى
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // 🔙 العنوان والأزرار
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Text(
                        "تعديل المنتج",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon:
                            const Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: _confirmDelete,
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // 🖼 الصورة
                  _buildProductImage(),
                  const SizedBox(height: 10),

                  ElevatedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.photo, color: Colors.white),
                    label: const Text("تغيير الصورة",
                        style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0B0C2A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // 🧩 الحقول
                  Row(
                    children: [
                      Expanded(
                          child:
                              _buildTextField("اسم المنتج", nameController)),
                      const SizedBox(width: 10),
                      Expanded(
                          child:
                              _buildTextField("كود المنتج", codeController)),
                    ],
                  ),
                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Expanded(
                          child: _buildTextField(
                              "الكمية الكلية", totalQuantityController,
                              isNumber: true)),
                      const SizedBox(width: 10),
                      Expanded(
                          child: _buildTextField(
                              "الكمية المباعة", soldQuantityController,
                              isNumber: true)),
                    ],
                  ),
                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Expanded(
                          child: _buildTextField(
                              "سعر الشراء", purchasePriceController,
                              isNumber: true)),
                      const SizedBox(width: 10),
                      Expanded(
                          child: _buildTextField(
                              "سعر البيع", sellingPriceController,
                              isNumber: true)),
                    ],
                  ),
                  const SizedBox(height: 25),

                  // 💾 زر الحفظ
                  ElevatedButton.icon(
                    icon: const Icon(Icons.save, color: Colors.white),
                    label: const Text(
                      "حفظ التعديلات",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 55),
                      backgroundColor: const Color(0xFF0B0C2A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 6,
                    ),
                    onPressed: () {
                      final updatedProduct = Product(
                        name: nameController.text,
                        code: codeController.text,
                        image: _imagePath ?? widget.product.image,
                        totalQuantity:
                            int.tryParse(totalQuantityController.text) ?? 0,
                        soldQuantity:
                            int.tryParse(soldQuantityController.text) ?? 0,
                        purchasePrice:
                            double.tryParse(purchasePriceController.text) ??
                                widget.product.purchasePrice,
                        sellingPrice:
                            double.tryParse(sellingPriceController.text) ??
                                widget.product.sellingPrice,
                        type: '',
                        move: '',
                      );

                      Navigator.pop(context, updatedProduct);
                    },
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
