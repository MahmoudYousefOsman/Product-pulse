import 'package:flutter/material.dart';
import '../models/supplier_model.dart';
import '../service/suppliers_service.dart';

class AllSuppliersScreens extends StatefulWidget {
  const AllSuppliersScreens({super.key});

  @override
  State<AllSuppliersScreens> createState() => _AllSuppliersScreensState();
}

class _AllSuppliersScreensState extends State<AllSuppliersScreens> with SingleTickerProviderStateMixin {
  final SuppliersService _suppliersService = SuppliersService();
  List<Supplier> _suppliers = [];
  bool _loading = true;

  AnimationController? _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fetchSuppliers();
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  Future<void> _fetchSuppliers() async {
    setState(() => _loading = true);
    try {
      final suppliers = await _suppliersService.getAllSupplier();
      setState(() => _suppliers = suppliers);
      _animationController?.forward(from: 0);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("خطأ: $e")),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  //============================ DETAILS DIALOG ============================
  void _showSupplierDetails(Supplier supplier) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade50, Colors.blue.shade100],
            ),
            borderRadius: BorderRadius.circular(25),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    Colors.blue.shade400,
                    Colors.blue.shade700
                  ]),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person, size: 40, color: Colors.white),
              ),
              const SizedBox(height: 20),
              Text(
                supplier.name,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade900,
                ),
              ),
              const SizedBox(height: 20),
              _buildDetailRow(Icons.phone, "الهاتف", supplier.phone ?? '-'),
              _buildDetailRow(Icons.location_on, "العنوان", supplier.address ?? '-'),

              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: const Text("إغلاق", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.blue.shade700, size: 20),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                Text(value,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue.shade900,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  //============================ EDIT SUPPLIER ============================
  void _editSupplier(Supplier supplier) {
    final nameController = TextEditingController(text: supplier.name);
    final phoneController = TextEditingController(text: supplier.phone);
    final addressController = TextEditingController(text: supplier.address);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade50, Colors.blue.shade100],
              ),
              borderRadius: BorderRadius.circular(25),
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Icon(Icons.edit, size: 50, color: Colors.blue.shade700),
                  const SizedBox(height: 10),
                  Text(
                    "تعديل المورد",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade900,
                    ),
                  ),
                  const SizedBox(height: 20),

                  _buildTextField(nameController, "الاسم", Icons.person),
                  const SizedBox(height: 15),
                  _buildTextField(phoneController, "الهاتف", Icons.phone, TextInputType.phone),
                  const SizedBox(height: 15),
                  _buildTextField(addressController, "العنوان", Icons.location_on),

                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade400,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                        child: const Text("إلغاء", style: TextStyle(color: Colors.white)),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          final updated = Supplier(
                            id: supplier.id,
                            name: nameController.text,
                            phone: phoneController.text,
                            address: addressController.text,
                          );

                          try {
                            await _suppliersService.updateSupplier(supplier.id!, updated);
                            Navigator.pop(context);
                            _fetchSuppliers();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("تم التحديث بنجاح")),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("خطأ: $e")),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade700,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                        child: const Text("حفظ", style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon,
      [TextInputType? type]) {
    return TextField(
      controller: controller,
      keyboardType: type,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blue.shade700),
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.blue.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.blue.shade700, width: 2),
        ),
      ),
    );
  }

  //============================ DELETE SUPPLIER ============================
  void _deleteSupplier(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("تأكيد الحذف"),
        content: const Text("هل أنت متأكد من حذف هذا المورد؟"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("إلغاء")),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("حذف", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _suppliersService.deleteSupplier(id);
        _fetchSuppliers();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("تم الحذف بنجاح")),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("خطأ: $e")),
        );
      }
    }
  }

  //============================ MAIN BUILD ============================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade700, Colors.blue.shade50],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      "كل الموردين",
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        "${_suppliers.length}",
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator(color: Colors.white))
                    : _suppliers.isEmpty
                        ? const Center(
                            child: Text(
                              "لا يوجد موردين",
                              style: TextStyle(fontSize: 18, color: Colors.white),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _suppliers.length,
                            itemBuilder: (context, index) {
                              final supplier = _suppliers[index];

                              final animation = Tween<double>(begin: 0, end: 1).animate(
                                CurvedAnimation(
                                  parent: _animationController!,
                                  curve: Interval(
                                    (index / _suppliers.length) * 0.5,
                                    ((index + 1) / _suppliers.length) * 0.5 + 0.5,
                                    curve: Curves.easeOut,
                                  ),
                                ),
                              );

                              return AnimatedBuilder(
                                animation: animation,
                                builder: (context, child) => Transform.translate(
                                  offset: Offset(0, 50 * (1 - animation.value)),
                                  child: Opacity(opacity: animation.value, child: child),
                                ),
                                child: _SupplierCard(
                                  supplier: supplier,
                                  onView: () => _showSupplierDetails(supplier),
                                  onEdit: () => _editSupplier(supplier),
                                  onDelete: () => _deleteSupplier(supplier.id!),
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//============================ SUPPLIER CARD ============================
class _SupplierCard extends StatefulWidget {
  final Supplier supplier;
  final VoidCallback onView;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _SupplierCard({
    required this.supplier,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<_SupplierCard> createState() => _SupplierCardState();
}

class _SupplierCardState extends State<_SupplierCard> {
  bool hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => hovering = true),
      onExit: (_) => setState(() => hovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.only(bottom: 16),
        transform: hovering ? (Matrix4.identity()..scale(1.02)) : Matrix4.identity(),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.blue.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: hovering ? Colors.blue.shade300 : Colors.blue.shade100,
              blurRadius: hovering ? 20 : 10,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 55,
                height: 55,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade400, Colors.blue.shade700],
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(Icons.person, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.supplier.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Icon(Icons.phone, size: 16, color: Colors.grey.shade600),
                        const SizedBox(width: 5),
                        Text(widget.supplier.phone ?? '-',
                            style: TextStyle(color: Colors.grey.shade800)),
                      ],
                    ),
                  ],
                ),
              ),
              _btn(Icons.visibility, Colors.blue, widget.onView),
              const SizedBox(width: 6),
              _btn(Icons.edit, Colors.blue, widget.onEdit),
              const SizedBox(width: 6),
              _btn(Icons.delete, Colors.red, widget.onDelete),
            ],
          ),
        ),
      ),
    );
  }

  Widget _btn(IconData icon, Color c, VoidCallback onPress) {
    return Container(
      decoration: BoxDecoration(
        color: c.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        icon: Icon(icon, color: c, size: 22),
        onPressed: onPress,
      ),
    );
  }
}