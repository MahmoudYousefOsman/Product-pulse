import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller; // الكنترولر
  final String hintText; // النص اللي بيظهر كمثال
  final IconData prefixIcon; // الأيقونة على الشمال
  final bool obscureText; // لو عايز تستخدمه للباسورد كمان

  const CustomTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 68,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Focus(
          onFocusChange: (hasFocus) {}, // ممكن تستخدمها لاحقًا لإضافة تأثير
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: const TextStyle(color: Color(0xff97989f)),
              prefixIcon: Icon(prefixIcon, color: const Color(0xff97989f)),
              filled: true,
              fillColor: const Color(0xfff3f3f5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(7),
                borderSide: const BorderSide(color: Colors.black38, width: 3),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
