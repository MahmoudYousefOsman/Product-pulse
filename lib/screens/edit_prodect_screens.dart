import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:software_system/Models/products.dart';
import 'package:software_system/service/product_service.dart';

class EditProductScreen extends StatefulWidget {
  final Product product;
  const EditProductScreen({super.key, required this.product});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  late TextEditingController _nameController;
  late TextEditingController _purchasePriceController;
  late TextEditingController _sellingPriceController;
  late TextEditingController _quantityController;

  File? _pickedFile;           // للجوال والكمبيوتر
  Uint8List? _pickedBytes;    
  bool _isUploading = false;

  // دالة رفع الصورة (شغالة على الويب والموبايل والديسكتوب)
  Future<String?> _uploadImageToSupabase(Uint8List bytes, String fileName) async {
    try {
      await Supabase.instance.client.storage
          .from('product-images')
          .uploadBinary(
            fileName,
            bytes,
            fileOptions: const FileOptions(upsert: true),
          );

      final url = Supabase.instance.client.storage
          .from('product-images')
          .getPublicUrl(fileName);

      debugPrint('تم رفع الصورة بنجاح: $url');
      return url;
    } catch (e) {
      debugPrint('خطأ في رفع الصورة: $e');
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product.name);
    _purchasePriceController = TextEditingController(text: widget.product.purchasePrice.toString());
    _sellingPriceController = TextEditingController(text: widget.product.sellingPrice.toString());
    _quantityController = TextEditingController(text: widget.product.totalQuantity.toString());
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      if (kIsWeb) {
        _pickedBytes = await image.readAsBytes();
      } else {
        _pickedFile = File(image.path);
      }
      setState(() {});
    }
  }

  Future<void> _updateProduct() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("اسم المنتج مطلوب")),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      String imageUrl = widget.product.image; // الصورة القديمة

      // لو اختار صورة جديدة → ارفعها
      if (_pickedFile != null || _pickedBytes != null) {
        final bytes = kIsWeb ? _pickedBytes! : await _pickedFile!.readAsBytes();
        final fileName = 'prod_${widget.product.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final newUrl = await _uploadImageToSupabase(bytes, fileName);
        if (newUrl != null) imageUrl = newUrl;
      }

      // تحديث المنتج في قاعدة البيانات
      final updatedProduct = Product(
        id: widget.product.id,
        name: _nameController.text.trim(),
        code: widget.product.code,
        image: imageUrl,
        totalQuantity: int.tryParse(_quantityController.text) ?? 0,
        purchasePrice: double.tryParse(_purchasePriceController.text) ?? 0.0,
        sellingPrice: double.tryParse(_sellingPriceController.text) ?? 0.0,
      );

      await ProductService.updateProduct(updatedProduct);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم تعديل المنتج بنجاح'), backgroundColor: Colors.green),
        );
        Navigator.pop(context, true); // رجوع مع تحديث القائمة
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _purchasePriceController.dispose();
    _sellingPriceController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // تحديد الصورة اللي هتتعرض
    Widget imageWidget;
    if (kIsWeb && _pickedBytes != null) {
      imageWidget = Image.memory(_pickedBytes!, fit: BoxFit.cover);
    } else if (!kIsWeb && _pickedFile != null) {
      imageWidget = Image.file(_pickedFile!, fit: BoxFit.cover);
    } else if (widget.product.image.startsWith('http')) {
      imageWidget = Image.network(
        widget.product.image,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Image.asset("assets/images/placeholder.jpg", fit: BoxFit.cover),
      );
    } else {
      imageWidget = Image.asset("assets/images/placeholder.jpg", fit: BoxFit.cover);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("تعديل المنتج"),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // الصورة مع زر التغيير
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: SizedBox(
                    height: 200,
                    width: double.infinity,
                    child: imageWidget,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: FloatingActionButton(
                    mini: true,
                    backgroundColor: Colors.orange,
                    onPressed: _pickImage,
                    child: const Icon(Icons.camera_alt, color: Colors.white),
                  ),
                ),
              ],
            ),

            if (_isUploading) ...[
              const SizedBox(height: 15),
              const LinearProgressIndicator(),
            ],

            const SizedBox(height: 25),

            TextField(controller: _nameController, decoration: const InputDecoration(labelText: "اسم المنتج", border: OutlineInputBorder())),
            const SizedBox(height: 15),
            TextField(controller: _quantityController, decoration: const InputDecoration(labelText: "الكمية", border: OutlineInputBorder()), keyboardType: TextInputType.number),
            const SizedBox(height: 15),
            TextField(controller: _purchasePriceController, decoration: const InputDecoration(labelText: "سعر الشراء", border: OutlineInputBorder()), keyboardType: TextInputType.number),
            const SizedBox(height: 15),
            TextField(controller: _sellingPriceController, decoration: const InputDecoration(labelText: "سعر البيع", border: OutlineInputBorder()), keyboardType: TextInputType.number),
            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isUploading ? null : _updateProduct,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: _isUploading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("حفظ التعديلات", style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}