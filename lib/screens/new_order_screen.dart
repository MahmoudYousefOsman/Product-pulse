// fileName: new_order_screen.dart
import 'package:flutter/material.dart';
import '../Models/products.dart';
import '../Models/OrderItem.dart';
import '../service/order_service.dart';
import '../service/product_service.dart';

class NewOrderScreen extends StatefulWidget {
  const NewOrderScreen({super.key});

  @override
  State<NewOrderScreen> createState() => _NewOrderScreenState();
}

class _NewOrderScreenState extends State<NewOrderScreen> {
  // الألوان الرئيسية المستلهمة من تصميم الفاتورة
  static const Color primaryColor = Color(0xFF6C63FF);
  static const Color secondaryColor = Color(0xFF8D88FF);
  static const Color backgroundColor = Color(0xFFF8F9FF);

  final OrderService _orderService = OrderService();
  final _formKey = GlobalKey<FormState>();

  List<Map<String, dynamic>> _clients = [];
  List<Product> _products = [];

  int? _selectedClientId;
  String _notes = '';
  double _discount = 0.0;
  List<OrderItem> _orderItems = [];

  int? _selectedProductId;
  int _quantity = 1;
  double _unitPrice = 0.0;

  bool _isLoading = false;
  bool _dataLoaded = false;

  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();
  final TextEditingController _unitPriceController = TextEditingController();
  final TextEditingController _quantityController =
  TextEditingController(text: '1');

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
    _discountController.text = '0.0';
    _discountController.addListener(_updateDiscount);
  }

  @override
  void dispose() {
    _notesController.dispose();
    _discountController.removeListener(_updateDiscount);
    _discountController.dispose();
    _unitPriceController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  void _updateDiscount() {
    final newDiscount = double.tryParse(_discountController.text) ?? 0.0;
    if (_discount != newDiscount) {
      setState(() {
        _discount = newDiscount;
      });
    }
  }

  double get _subtotal =>
      _orderItems.fold(0.0, (sum, item) => sum + item.total);

  double get _totalPrice => (_subtotal - _discount).clamp(0.0, double.infinity);

  Future<void> _fetchInitialData() async {
    setState(() => _isLoading = true);
    try {
      final clients = await _orderService.fetchClients();
      final products = await ProductService.getAllProducts();
      setState(() {
        _clients = clients;
        _products = products.where((p) => p.totalQuantity > 0).toList();
        _dataLoaded = true;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل تحميل البيانات: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  void _addItemToOrder() {
    if (_selectedProductId == null || _quantity <= 0) return;

    final product =
    _products.firstWhere((p) => p.id == _selectedProductId);

    final existingIndex =
    _orderItems.indexWhere((item) => item.productId == _selectedProductId);
    final currentQuantity =
    existingIndex != -1 ? _orderItems[existingIndex].quantity : 0;

    if (_quantity + currentQuantity > product.totalQuantity) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'الكمية المطلوبة أكبر من المخزون المتاح (${product.totalQuantity - currentQuantity})'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (existingIndex != -1) {
      setState(() {
        _orderItems[existingIndex].quantity += _quantity;
        _orderItems[existingIndex].unitPrice = _unitPrice;
      });
    } else {
      setState(() {
        _orderItems.add(
          OrderItem(
            productId: product.id!,
            productName: product.name,
            unitPrice: _unitPrice,
            quantity: _quantity,
          ),
        );
      });
    }

    // Adjusting stock for the selected product in the local list
    final updatedQuantity = product.totalQuantity - _quantity;
    final updatedProduct = Product(
      id: product.id,
      name: product.name,
      code: product.code,
      image: product.image,
      totalQuantity: updatedQuantity,
      purchasePrice: product.purchasePrice,
      sellingPrice: product.sellingPrice,
    );

    final productIndex = _products.indexWhere((p) => p.id == product.id);

    setState(() {
      if (updatedQuantity > 0) {
        _products[productIndex] = updatedProduct;
      } else {
        // Remove product if stock is zero after adding to order
        _products.removeAt(productIndex);
      }

      // Reset item addition form
      _selectedProductId = null;
      _quantity = 1;
      _unitPrice = 0.0;
      _unitPriceController.clear();
      _quantityController.text = '1';
    });
  }

  void _removeItem(int index) {
    final item = _orderItems[index];
    final productIndex = _products.indexWhere((p) => p.id == item.productId);

    setState(() {
      _orderItems.removeAt(index);

      if (productIndex != -1) {
        // Product exists in the available list, update its stock
        final updatedProduct = _products[productIndex];
        _products[productIndex] = Product(
          id: updatedProduct.id,
          name: updatedProduct.name,
          code: updatedProduct.code,
          image: updatedProduct.image,
          totalQuantity: updatedProduct.totalQuantity + item.quantity,
          purchasePrice: updatedProduct.purchasePrice,
          sellingPrice: updatedProduct.sellingPrice,
        );
      } else {
        // Product was completely removed from the list (stock went to 0), re-add it
        _products.add(
          Product(
            id: item.productId,
            name: item.productName,
            code: '',
            image: '',
            totalQuantity: item.quantity,
            purchasePrice: 0.0, // Assuming this is not used here
            sellingPrice: item.unitPrice,
          ),
        );
      }
    });
  }

  Future<void> _submitOrder() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedClientId == null) {
      _showSnackbar('يجب اختيار العميل.', Colors.red);
      return;
    }
    if (_orderItems.isEmpty) {
      _showSnackbar('يجب إضافة منتج واحد على الأقل.', Colors.red);
      return;
    }

    _formKey.currentState!.save();
    setState(() => _isLoading = true);

    try {
      final orderItemsMaps = _orderItems.map((item) => item.toMap()).toList();
      await _orderService.createNewOrder(
        clientId: _selectedClientId!,
        totalPrice: _totalPrice,
        discount: _discount,
        notes: _notes,
        orderItems: orderItemsMaps,
      );

      _showSnackbar('تم حفظ الطلب بنجاح.', Colors.green);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      _showSnackbar('فشل حفظ الطلب: $e', Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackbar(String message, Color color) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message,
            textAlign: TextAlign.right,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          backgroundColor: color,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryColor, secondaryColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 22, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'إنشاء طلب جديد',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 24,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.25),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.shopping_bag_outlined,
                color: Colors.white, size: 22),
          ),
        ],
      ),
      body: _isLoading && !_dataLoaded
          ? Center(
        child: CircularProgressIndicator(
          strokeWidth: 3,
          valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
        ),
      )
          : Form(
        key: _formKey,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          children: [
            _buildSectionTitle('👤 بيانات العميل'),
            _buildCustomCard(child: _buildClientSelection()),
            const SizedBox(height: 16),
            _buildSectionTitle('📦 إضافة منتجات'),
            _buildCustomCard(child: _buildAddItemSection()),
            const SizedBox(height: 16),
            _buildSectionTitle('🛒 المنتجات المضافة (${_orderItems.length})'),
            _buildOrderItemsList(),
            const SizedBox(height: 16),
            _buildSectionTitle('📝 التفاصيل الإضافية'),
            _buildCustomCard(child: _buildDetailsSection()),
            const SizedBox(height: 24),
            _buildSummaryCard(),
            const SizedBox(height: 30),
            _buildSaveButton(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 4, right: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Colors.grey[800],
        ),
        textAlign: TextAlign.right,
      ),
    );
  }

  Widget _buildCustomCard({required Widget child, Color? color}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 0),
      decoration: BoxDecoration(
        color: color ?? Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.15),
            spreadRadius: 0,
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: child,
      ),
    );
  }


  Widget _buildClientSelection() {
    return DropdownButtonFormField<int>(
      decoration: _getInputDecoration(Icons.person_outline_rounded, 'اختر العميل'),
      value: _selectedClientId,
      items: _clients
          .map(
            (client) => DropdownMenuItem<int>(
          value: client['id'] as int,
          child: Text(
            client['name'],
            style: const TextStyle(fontSize: 16),
          ),
        ),
      )
          .toList(),
      onChanged: (newValue) {
        setState(() {
          _selectedClientId = newValue;
        });
      },
      validator: (value) => value == null ? 'الرجاء اختيار العميل' : null,
      dropdownColor: Colors.white,
      borderRadius: BorderRadius.circular(16),
      icon: const Icon(Icons.expand_more_rounded, color: primaryColor),
      style: const TextStyle(color: Colors.black87),
    );
  }

  Widget _buildAddItemSection() {
    return Column(
      children: [
        DropdownButtonFormField<int>(
          decoration: _getInputDecoration(Icons.inventory_2_outlined, 'المنتج'),
          value: _selectedProductId,
          items: _products
              .map(
                (product) => DropdownMenuItem<int>(
              value: product.id,
              child: Text(
                '${product.name} (${product.totalQuantity})',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          )
              .toList(),
          onChanged: (newValue) {
            if(newValue != null) {
              final selectedProduct =
              _products.firstWhere((p) => p.id == newValue);
              setState(() {
                _selectedProductId = newValue;
                _unitPrice = selectedProduct.sellingPrice;
                _unitPriceController.text =
                    selectedProduct.sellingPrice.toStringAsFixed(2);
              });
            }
          },
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(16),
          icon: const Icon(Icons.expand_more_rounded, color: primaryColor),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _unitPriceController,
                keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
                decoration:
                _getInputDecoration(Icons.monetization_on_outlined, 'سعر الوحدة'),
                onChanged: (value) {
                  _unitPrice = double.tryParse(value) ?? 0.0;
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                decoration: _getInputDecoration(Icons.format_list_numbered, 'الكمية'),
                onChanged: (value) {
                  _quantity = int.tryParse(value) ?? 1;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _selectedProductId != null && _quantity > 0
                ? _addItemToOrder
                : null,
            icon: const Icon(Icons.add_circle_outline_rounded, size: 22),
            label: const Text(
              'أضف للمنتجات المطلوبة',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              padding: const EdgeInsets.symmetric(vertical: 16),
              elevation: 8,
              shadowColor: primaryColor.withOpacity(0.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderItemsList() {
    if (_orderItems.isEmpty) {
      return _buildCustomCard(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            children: [
              Icon(
                Icons.shopping_cart_outlined,
                size: 60,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'لم يتم إضافة أي منتجات بعد',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'قم بإضافة منتجات من القسم أعلاه',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return _buildCustomCard(
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: _orderItems.length,
        separatorBuilder: (context, index) => Divider(
          height: 1,
          color: Colors.grey[200],
          indent: 64,
        ),
        itemBuilder: (context, index) {
          final item = _orderItems[index];
          return Dismissible(
            key: ValueKey(item.productId),
            direction: DismissDirection.endToStart,
            onDismissed: (_) => _removeItem(index),
            background: Container(
              alignment: Alignment.centerRight,
              margin: const EdgeInsets.symmetric(vertical: 4),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.red[400],
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.delete_forever_rounded,
                  color: Colors.white, size: 28),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.inventory_rounded,
                        color: primaryColor, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.productName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${item.quantity} × ${item.unitPrice.toStringAsFixed(2)} ج.م',
                          style: TextStyle(
                            color: Colors.blueGrey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${item.total.toStringAsFixed(2)} ج.م',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailsSection() {
    return Column(
      children: [
        TextFormField(
          controller: _discountController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: _getInputDecoration(
              Icons.discount_outlined, 'الخصم (ج.م)'),
          onSaved: (value) =>
          _discount = double.tryParse(value ?? '0.0') ?? 0.0,
          validator: (value) {
            if (double.tryParse(value ?? '') == null) {
              return 'أدخل قيمة رقمية صحيحة';
            }
            if ((double.tryParse(value ?? '0.0') ?? 0.0) < 0) {
              return 'يجب أن يكون الخصم موجباً';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _notesController,
          maxLines: 3,
          decoration: _getInputDecoration(Icons.note_alt_outlined, 'ملاحظات إضافية'),
          onSaved: (value) => _notes = value ?? '',
        ),
      ],
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primaryColor,
            secondaryColor,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.4),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.receipt_long_rounded,
                    color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              const Text(
                'ملخص الطلب',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildSummaryRow('الإجمالي الفرعي:', _subtotal,
              Colors.white70, FontWeight.w600),
          const SizedBox(height: 8),
          _buildSummaryRow('الخصم:', _discount, Colors.red.shade100, FontWeight.w600,
              isDiscount: true),
          const SizedBox(height: 16),
          Divider(
            height: 1,
            thickness: 1.5,
            color: Colors.white.withOpacity(0.4),
          ),
          const SizedBox(height: 20),
          _buildSummaryRow('الإجمالي النهائي:', _totalPrice, Colors.white,
              FontWeight.w800),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: Colors.white.withOpacity(0.8),
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'سيتم خصم الكمية من المخزون تلقائياً بعد تأكيد الطلب',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
      String label, double amount, Color color, FontWeight fontWeight,
      {bool isDiscount = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: fontWeight,
            color: Colors.white.withOpacity(0.9),
          ),
        ),
        Text(
          '${isDiscount ? '-' : ''}${amount.toStringAsFixed(2)} ج.م',
          style: TextStyle(
            fontSize: fontWeight == FontWeight.w800 ? 24 : 18,
            fontWeight: fontWeight,
            color: color,
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }

  InputDecoration _getInputDecoration(IconData icon, String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.w500),
      prefixIcon: Icon(icon, color: primaryColor),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      filled: true,
      fillColor: backgroundColor, // استخدام لون الخلفية الفاتح
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: primaryColor, width: 1.5),
      ),
      floatingLabelStyle: const TextStyle(color: primaryColor),
    );
  }

  Widget _buildSaveButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : _submitOrder,
        icon: _isLoading
            ? SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2.5,
          ),
        )
            : const Icon(Icons.check_circle_outline_rounded, size: 26),
        label: Text(
          _isLoading ? 'جاري حفظ الطلب...' : 'تأكيد وإنشاء الطلب',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
        ),
      ),
    );
  }
}