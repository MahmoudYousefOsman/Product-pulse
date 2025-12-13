import 'package:flutter/material.dart';
import '../models/client_model.dart';
import '../service/clients_service.dart';

class AllClient extends StatefulWidget {
  const AllClient({super.key});

  @override
  State<AllClient> createState() => _AllClientState();
}

class _AllClientState extends State<AllClient> with SingleTickerProviderStateMixin {
  final ClientsService _clientsService = ClientsService();
  List<Client> _clients = [];
  bool _loading = true;
  AnimationController? _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fetchClients();
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  Future<void> _fetchClients() async {
    setState(() => _loading = true);
    try {
      final clients = await _clientsService.getAllClients();
      setState(() => _clients = clients);
      _animationController?.forward(from: 0);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("خطأ: $e")));
    } finally {
      setState(() => _loading = false);
    }
  }

  void _showClientDetails(Client client) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
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
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade400, Colors.blue.shade700],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.shade200,
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(Icons.person, size: 40, color: Colors.white),
              ),
              const SizedBox(height: 20),
              Text(
                client.name,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade900,
                ),
              ),
              const SizedBox(height: 20),
              _buildDetailRow(Icons.phone, "الهاتف", client.phone ?? '-'),
              _buildDetailRow(Icons.location_on, "العنوان", client.address ?? '-'),
              _buildDetailRow(Icons.new_releases, "عميل جديد", client.newClient ? 'نعم' : 'لا'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: const Text("إغلاق", style: TextStyle(fontSize: 16, color: Colors.white)),
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
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.blue.shade900,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _editClient(Client client) {
    final nameController = TextEditingController(text: client.name);
    final phoneController = TextEditingController(text: client.phone);
    final addressController = TextEditingController(text: client.address);
    bool newClient = client.newClient;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.blue.shade50, Colors.blue.shade100],
              ),
              borderRadius: BorderRadius.circular(25),
            ),
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.edit, size: 50, color: Colors.blue.shade700),
                  const SizedBox(height: 10),
                  Text(
                    "تعديل العميل",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue.shade900),
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(nameController, "الاسم", Icons.person),
                  const SizedBox(height: 15),
                  _buildTextField(phoneController, "الهاتف", Icons.phone, TextInputType.phone),
                  const SizedBox(height: 15),
                  _buildTextField(addressController, "العنوان", Icons.location_on),
                  const SizedBox(height: 15),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: SwitchListTile(
                      value: newClient,
                      title: const Text("عميل جديد؟"),
                      activeThumbColor: Colors.blue.shade700,
                      onChanged: (value) => setState(() => newClient = value),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade400,
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                        child: const Text("إلغاء", style: TextStyle(color: Colors.white)),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          final errorMessage = await _clientsService.validateClient(
                            name: nameController.text,
                            phone: phoneController.text,
                            clientId: client.id,
                          );
                          if (errorMessage != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(errorMessage)),
                            );
                            return;
                          }
                          final updatedClient = Client(
                            name: nameController.text,
                            phone: phoneController.text,
                            address: addressController.text,
                            newClient: newClient,
                          );
                          try {
                            await _clientsService.updateClient(client.id!, updatedClient);
                            Navigator.pop(context);
                            _fetchClients();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("تم تحديث بيانات العميل ✅")),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("خطأ: $e")),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade700,
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                        child: const Text("حفظ", style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, [TextInputType? keyboardType]) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blue.shade700),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
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

  void _deleteClient(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.red.shade50, Colors.red.shade100],
            ),
            borderRadius: BorderRadius.circular(25),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.warning_amber_rounded, size: 50, color: Colors.red),
              ),
              const SizedBox(height: 20),
              const Text("تأكيد الحذف", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              const Text("هل أنت متأكد أنك تريد حذف هذا العميل؟", textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.black54)),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade400,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: const Text("إلغاء", style: TextStyle(color: Colors.white)),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: const Text("حذف", style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirm == true) {
      try {
        await _clientsService.deleteClient(id);
        _fetchClients();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("تم حذف العميل ✅")),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("خطأ: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade700, Colors.blue.shade50],
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
                    const Text("كل العملاء", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text("${_clients.length}", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator(color: Colors.white))
                    : _clients.isEmpty
                    ? const Center(child: Text("لم يتم العثور على عملاء", style: TextStyle(fontSize: 18, color: Colors.white)))
                    : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _clients.length,
                  itemBuilder: (context, index) {
                    final client = _clients[index];
                    Widget card = _ClientCard(
                      client: client,
                      onView: () => _showClientDetails(client),
                      onEdit: () => _editClient(client),
                      onDelete: () => _deleteClient(client.id!),
                    );
                    if (_animationController != null) {
                      final animation = Tween<double>(begin: 0, end: 1).animate(
                        CurvedAnimation(
                          parent: _animationController!,
                          curve: Interval(
                            (index / _clients.length) * 0.5,
                            ((index + 1) / _clients.length) * 0.5 + 0.5,
                            curve: Curves.easeOut,
                          ),
                        ),
                      );
                      return AnimatedBuilder(
                        animation: animation,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(0, 50 * (1 - animation.value)),
                            child: Opacity(opacity: animation.value, child: child),
                          );
                        },
                        child: card,
                      );
                    }
                    return card;
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

class _ClientCard extends StatefulWidget {
  final Client client;
  final VoidCallback onView;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ClientCard({
    required this.client,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<_ClientCard> createState() => _ClientCardState();
}

class _ClientCardState extends State<_ClientCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 16),
        transform: _hovering ? (Matrix4.identity()..scale(1.02)) : Matrix4.identity(),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.blue.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: _hovering ? Colors.blue.shade300 : Colors.blue.shade100,
              blurRadius: _hovering ? 20 : 10,
              spreadRadius: _hovering ? 2 : 0,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [Colors.blue.shade400, Colors.blue.shade700]),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(color: Colors.blue.shade200, blurRadius: 10, spreadRadius: 2),
                  ],
                ),
                child: const Icon(Icons.person, color: Colors.white, size: 30),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.client.name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue.shade900)),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Icon(Icons.phone, size: 16, color: Colors.grey.shade600),
                        const SizedBox(width: 5),
                        Text(widget.client.phone ?? '-', style: TextStyle(color: Colors.grey.shade700)),
                      ],
                    ),
                  ],
                ),
              ),
              _buildActionButton(Icons.visibility, Colors.blue.shade700, widget.onView),
              const SizedBox(width: 8),
              _buildActionButton(Icons.edit, Colors.blue.shade700, widget.onEdit),
              const SizedBox(width: 8),
              _buildActionButton(Icons.delete, Colors.red, widget.onDelete),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, Color color, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(icon: Icon(icon), color: color, iconSize: 22, onPressed: onPressed),
    );
  }
}
