import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:software_system/Models/products.dart';
import 'package:software_system/service/product_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditProductScreen extends StatefulWidget {
  final Product product;

  const EditProductScreen({super.key, required this.product});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  late TextEditingController _nameController;
  late TextEditingController _codeController;
  late TextEditingController _purchasePriceController;
  late TextEditingController _sellingPriceController;
  late TextEditingController _quantityController;

  Timer? _debounce;
  File? _pickedFile; // Mobile/Desktop
  Uint8List? _pickedBytes; // Web

  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product.name);
    _codeController = TextEditingController(text: widget.product.code);
    _purchasePriceController =
        TextEditingController(text: widget.product.purchasePrice.toString());
    _sellingPriceController =
        TextEditingController(text: widget.product.sellingPrice.toString());
    _quantityController =
        TextEditingController(text: widget.product.totalQuantity.toString());

    _nameController.addListener(_onFieldChanged);
    _codeController.addListener(_onFieldChanged);
    _purchasePriceController.addListener(_onFieldChanged);
    _sellingPriceController.addListener(_onFieldChanged);
    _quantityController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {});
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

  // ✅ الدالة النهائية لرفع الصورة على Supabase وجلب public URL
  Future<String?> _uploadImageToSupabase(Uint8List bytes, String fileName) async {
    final supabase = Supabase.instance.client;

    try {
      final path = 'assets/images/$fileName';

      await supabase.storage
          .from('product-images')
          .uploadBinary(
            path,
            bytes,
            fileOptions: const FileOptions(upsert: true),
          );

      // publicUrl مباشر بدون .publicUrl
      final publicUrl = supabase.storage.from('product-images').getPublicUrl(path);
      debugPrint('Public URL: $publicUrl');
      return publicUrl;
    } catch (e) {
      debugPrint('Upload error: $e');
      return null;
    }
  }

  Future<void> _updateProductRealtime() async {
    if (_nameController.text.isEmpty ||
        _codeController.text.isEmpty ||
        _purchasePriceController.text.isEmpty ||
        _sellingPriceController.text.isEmpty ||
        _quantityController.text.isEmpty) return;

    if (widget.product.id == null) return;

    try {
      setState(() => _isUploading = true);

      double purchasePrice = double.tryParse(_purchasePriceController.text) ?? 0;
      double sellingPrice = double.tryParse(_sellingPriceController.text) ?? 0;
      int quantity = int.tryParse(_quantityController.text) ?? 0;

      String imageUrl = widget.product.image;

      // رفع الصورة إذا تم اختيارها
      if (kIsWeb && _pickedBytes != null) {
        final url = await _uploadImageToSupabase(_pickedBytes!, 'product_${widget.product.id}.png');
        if (url != null) imageUrl = url;
      } else if (_pickedFile != null) {
        final bytes = await _pickedFile!.readAsBytes();
        final url = await _uploadImageToSupabase(bytes, 'product_${widget.product.id}.png');
        if (url != null) imageUrl = url;
      }

      final updatedProduct = Product(
        id: widget.product.id,
        name: _nameController.text.trim(),
        code: _codeController.text.trim(),
        purchasePrice: purchasePrice,
        sellingPrice: sellingPrice,
        totalQuantity: quantity,
        image: imageUrl,
      );

      await ProductService.updateProduct(updatedProduct);

      if (mounted) {
        setState(() => _isUploading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم تحديث المنتج بنجاح ✅'),
            backgroundColor: Colors.green,
            duration: Duration(milliseconds: 800),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() => _isUploading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(milliseconds: 1200),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _nameController.dispose();
    _codeController.dispose();
    _purchasePriceController.dispose();
    _sellingPriceController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;
    if (kIsWeb && _pickedBytes != null) {
      imageWidget = Image.memory(_pickedBytes!, fit: BoxFit.contain);
    } else if (!kIsWeb && _pickedFile != null) {
      imageWidget = Image.file(_pickedFile!, fit: BoxFit.contain);
    } else {
      imageWidget = widget.product.image.startsWith('http')
          ? Image.network(widget.product.image, fit: BoxFit.contain)
          : Image.asset(widget.product.image, fit: BoxFit.contain);
    }

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, true);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade400, Colors.blue.shade500],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          elevation: 0,
          centerTitle: true,
          title: const Text(
            "تعديل المنتج",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade400, Colors.blue.shade700],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            width: double.infinity,
                            height: 150,
                            color: Colors.grey[100],
                            child: imageWidget,
                          ),
                        ),
                        Positioned(
                          bottom: 8,
                          right: 8,
                          child: ElevatedButton(
                            onPressed: _pickImage,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange.shade400,
                              shape: const CircleBorder(),
                              padding: const EdgeInsets.all(8),
                            ),
                            child: const Icon(Icons.edit, color: Colors.white, size: 20),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_isUploading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: LinearProgressIndicator(),
                    ),
                  const SizedBox(height: 24),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
                      ],
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildTextField(_nameController, 'اسم المنتج', Icons.shopping_bag),
                        const SizedBox(height: 16),
                        _buildTextField(_codeController, 'كود المنتج', Icons.code),
                        const SizedBox(height: 16),
                        _buildTextField(_purchasePriceController, 'سعر الشراء', Icons.attach_money,
                            keyboardType: TextInputType.number),
                        const SizedBox(height: 16),
                        _buildTextField(_sellingPriceController, 'سعر البيع', Icons.price_check,
                            keyboardType: TextInputType.number),
                        const SizedBox(height: 16),
                        _buildTextField(_quantityController, 'الكمية', Icons.inventory,
                            keyboardType: TextInputType.number),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _updateProductRealtime,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade500,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text(
                        'تعديل',
                        style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade500,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text(
                        'إغلاق',
                        style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon,
      {TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blue.shade400),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        enabledBorder:
            OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
        focusedBorder:
            OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.blue.shade400, width: 2)),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    );
  }
}
