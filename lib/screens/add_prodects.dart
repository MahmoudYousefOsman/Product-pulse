import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:software_system/widgets/custom_add_prodect.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final nameController = TextEditingController();
  final quantityController = TextEditingController();
  final purchaseController = TextEditingController();
  final saleController = TextEditingController();

  File? selectedImageFile;
  Uint8List? webImageBytes;
  final picker = ImagePicker();

  // دالة رفع الصورة
  Future<String?> _uploadImageToSupabase(Uint8List bytes, String fileName) async {
    try {
      await Supabase.instance.client.storage
          .from('product-images')
          .uploadBinary(fileName, bytes, fileOptions: const FileOptions(upsert: true));

      final url = Supabase.instance.client.storage
          .from('product-images')
          .getPublicUrl(fileName);

      debugPrint('تم رفع الصورة: $url');
      return url;
    } catch (e) {
      debugPrint('خطأ رفع الصورة: $e');
      return null;
    }
  }

  Future<void> pickImage() async {
    final XFile? picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      if (kIsWeb) {
        final bytes = await picked.readAsBytes();
        setState(() => webImageBytes = bytes);
      } else {
        setState(() => selectedImageFile = File(picked.path));
      }
    }
  }

  Future<void> addProduct() async {
    final name = nameController.text.trim();
    final quantity = int.tryParse(quantityController.text.trim()) ?? 0;
    final purchasePrice = double.tryParse(purchaseController.text.trim()) ?? 0.0;
    final salePrice = double.tryParse(saleController.text.trim()) ?? 0.0;

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("اسم المنتج مطلوب"), backgroundColor: Colors.red),
      );
      return;
    }

    try {
      String? imageUrl;
      final fileName = 'prod_${DateTime.now().millisecondsSinceEpoch}.jpg';

      // فقط لو المستخدم فعلاً اختار صورة
      if (selectedImageFile != null || webImageBytes != null) {
        final bytes = kIsWeb 
            ? webImageBytes! 
            : await selectedImageFile!.readAsBytes(); // هنا آمن لأننا متأكدين إنه مش null

        imageUrl = await _uploadImageToSupabase(bytes, fileName);
      }

      // إضافة المنتج
      await Supabase.instance.client.from('products').insert({
        'name': name,
        'code': 'PRD-${DateTime.now().millisecondsSinceEpoch}',
        'totalQuantity': quantity,
        'PurchasePrice': purchasePrice,
        'SellingPrice': salePrice,
        'image': imageUrl ?? 'https://via.placeholder.com/150',
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("تم إضافة المنتج بنجاح"), backgroundColor: Colors.green),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("خطأ: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    quantityController.dispose();
    purchaseController.dispose();
    saleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [Color(0xFF1960fb), Color(0xFF3d37c1)]),
        ),
        child: Center(
          child: Container(
            width: 400,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8)],
            ),
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  const Text("إضافة منتج جديد", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),

                  CustomAddProdect(label: "اسم المنتج", controller: nameController, keyboardType: TextInputType.text),
                  const SizedBox(height: 12),
                  CustomAddProdect(label: "الكمية", controller: quantityController, keyboardType: TextInputType.number),
                  const SizedBox(height: 12),
                  CustomAddProdect(label: "سعر الشراء", controller: purchaseController, keyboardType: TextInputType.number),
                  const SizedBox(height: 12),
                  CustomAddProdect(label: "سعر البيع", controller: saleController, keyboardType: TextInputType.number),
                  const SizedBox(height: 25),

                  ElevatedButton.icon(
                    onPressed: pickImage,
                    icon: const Icon(Icons.photo_library),
                    label: Text(
                      webImageBytes != null || selectedImageFile != null 
                          ? "تم اختيار الصورة" 
                          : "اختر صورة من الجهاز",
                    ),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange),
                  ),

                  if (webImageBytes != null || selectedImageFile != null) ...[
                    const SizedBox(height: 15),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: kIsWeb
                          ? Image.memory(webImageBytes!, height: 180, fit: BoxFit.cover)
                          : Image.file(selectedImageFile!, height: 180, fit: BoxFit.cover),
                    ),
                  ],

                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: addProduct,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                      child: const Text("إضافة المنتج", style: TextStyle(color: Colors.white, fontSize: 18)),
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