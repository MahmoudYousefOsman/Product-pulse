import 'package:flutter/material.dart';

/// 🧩 Custom Text Field Widget
/// Widget جاهزة لإعادة الاستخدام في أي صفحة
class CustomAddProdect extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool enabled;

  const CustomAddProdect({
    super.key,
    required this.label,
    required this.controller,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          enabled: enabled,
          decoration: InputDecoration(
            hintText: label.toLowerCase(),
            filled: true,
            fillColor: Colors.grey.shade100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
          ),
        ),
      ],
    );
  }
}
