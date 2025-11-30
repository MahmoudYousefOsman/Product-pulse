import 'package:flutter/material.dart';
import 'package:software_system/screens/add_client_sccreens.dart';
import 'package:software_system/screens/login.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:software_system/screens/add_prodects.dart';
import 'package:software_system/screens/add_suppliers.dart';
import 'package:software_system/screens/all_client.dart';
import 'package:software_system/screens/all_prodect.dart';
import 'package:software_system/screens/all_suppliers_screens.dart';
import 'package:software_system/screens/missing_products.dart';
import 'package:software_system/screens/prodect_move_ment.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({super.key});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  String? expandedItem;

  void toggleExpand(String key) {
    setState(() {
      expandedItem = expandedItem == key ? null : key;
    });
  }

  // ============ زرار تسجيل الخروج ============
  Future<void> _logout() async {
    final supabase = Supabase.instance.client;

    try {
      // حذف التوكن من الذاكرة
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token'); // غيّر اسم الـ key حسب استخدامك
      
      // تسجيل الخروج من Supabase
      await supabase.auth.signOut();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("تم تسجيل الخروج بنجاح"),
          duration: Duration(seconds: 1),
        ),
      );

      await Future.delayed(const Duration(seconds: 1));

      // الانتقال إلى صفحة تسجيل الدخول
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Login_screen()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("خطأ أثناء تسجيل الخروج: $e")),
      );
    }
  }
  // ===========================================

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF1B1F27),
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 20),
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              color: Color(0xFF272C36),
            ),
            currentAccountPicture: const CircleAvatar(
              backgroundImage: AssetImage("assets/Images/smart_inventory.png"),
            ),
            accountName: const Text(
              "404 Error Team",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            accountEmail: const Text("404error@gmail.com"),
          ),

          _drawerItem(
            title: "لوحة التحكم",
            icon: Icons.dashboard_outlined,
          ),

          _expandableItem(
            title: "العملاء",
            icon: Icons.assignment_ind_outlined,
            keyValue: "clients",
            children: [
              _subItem("كل العملاء", Icons.list_alt_outlined, const AllClient()),
              _subItem("إضافة عميل", Icons.person_add_alt_1_outlined, const AddClientScreen()),
            ],
          ),

          _expandableItem(
            title: "الموردين",
            icon: Icons.local_shipping_outlined,
            keyValue: "suppliers",
            children: [
              _subItem("كل الموردين", Icons.list, const AllSuppliersScreens()),
              _subItem("إضافة مورد", Icons.add, const AddSuppliers()),
            ],
          ),

          _expandableItem(
            title: "المنتجات",
            icon: Icons.inventory_2_outlined,
            keyValue: "products",
            children: [
              _subItem("كل المنتجات", Icons.list, const AllProdect()),
              _subItem("إضافة منتج", Icons.add, const AddProductScreen()),
              _subItem("حركة المنتج", Icons.swap_horiz,  ProductMovementsScreen()),
              _subItem("المنتجات الناقصة", Icons.warning_amber_outlined, const MissingProducts()),
            ],
          ),

          _drawerItem(
            title: "المشتريات",
            icon: Icons.shopping_bag_outlined,
          ),

          _drawerItem(
            title: "أوردرات",
            icon: Icons.shopping_cart_outlined,
          ),

          _drawerItem(
            title: "الإعدادات",
            icon: Icons.settings_outlined,
          ),

          const Divider(color: Colors.white54, height: 30),

          // ========== زرار تسجيل الخروج ==========
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: const Text(
              "تسجيل الخروج",
              style: TextStyle(color: Colors.redAccent, fontSize: 20),
            ),
            trailing: const Icon(Icons.exit_to_app, color: Colors.redAccent),
            onTap: _logout,
          ),
        ],
      ),
    );
  }

  Widget _drawerItem({required String title, required IconData icon}) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 20),
      ),
    );
  }

  Widget _expandableItem({
    required String title,
    required IconData icon,
    required String keyValue,
    required List<Widget> children,
  }) {
    final isExpanded = expandedItem == keyValue;
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: Colors.white),
          title: Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 20),
          ),
          trailing: Icon(
            isExpanded ? Icons.expand_less : Icons.expand_more,
            color: Colors.white,
          ),
          onTap: () => toggleExpand(keyValue),
        ),
        if (isExpanded)
          Container(
            margin: const EdgeInsets.only(right: 40),
            child: Column(children: children),
          ),
      ],
    );
  }

  Widget _subItem(String title, IconData icon, Widget page) {
    return ListTile(
      leading: Icon(icon, color: Colors.white70, size: 20),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white70, fontSize: 18),
      ),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),
        );
      },
    );
  }
}