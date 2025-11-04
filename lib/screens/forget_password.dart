import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:software_system/widgets/animation_logo.dart';
import 'package:software_system/widgets/custom_text_filed.dart';
import 'package:flutter/cupertino.dart';

class ForgetPassword extends StatelessWidget {
  ForgetPassword({super.key});

  final TextEditingController email = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1960fb), Color(0xFF3d37c1)],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(50),
              ),
              width: double.infinity,
              height: 430,
              child: Column(
                children: [
                  const SizedBox(height: 25),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(CupertinoIcons.arrow_left, size: 28),
                        ).animate().fade(duration: 400.ms).slideX(begin: -0.5, end: 0),
                        const SizedBox(width: 10),
                        const Text(
                          "العودة لتسجيل الدخول",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ).animate().fade(duration: 400.ms).slideX(begin: -0.5, end: 0),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  AnimatedLogo(imagePath: "assets/Images/smart_inventory.png")
                      .animate()
                      .fade(duration: 600.ms)
                      .scaleXY(begin: 0.8, end: 1.0, curve: Curves.easeOut),
                  const Text(
                    "إعادة تعيين كلمة المرور",
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 17),
                  ).animate().fade(duration: 600.ms).slideY(begin: -0.3, end: 0),
                  const SizedBox(height: 10),
                  const Text(
                    "أدخل بريدك الإلكتروني لتلقي رابط إعادة التعيين",
                    style: TextStyle(fontWeight: FontWeight.w400, fontSize: 16),
                  ).animate().fade(duration: 600.ms).slideY(begin: -0.3, end: 0),
                  const SizedBox(height: 30),
                  Container(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: const [
                        SizedBox(width: 15),
                        Text(
                          "البريد الالكتروني ",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ).animate().fade(duration: 600.ms).slideX(begin: -0.5, end: 0),
                  ),
                  CustomTextField(
                    controller: email,
                    hintText: "name@gmail.com",
                    prefixIcon: CupertinoIcons.mail_solid,
                  ).animate().fade(duration: 600.ms).slideX(begin: -0.5, end: 0),
                  Padding(
                    padding: const EdgeInsets.all(15),
                    child: GestureDetector(
                      onTap: () {
                        // هنا ممكن تضيف وظيفة إرسال رابط إعادة التعيين
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF1960fb), Color(0xFF3d37c1)],
                          ),
                          borderRadius: BorderRadius.circular(7),
                        ),
                        width: double.infinity,
                        height: 40,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "أرسل رابط إعادة الضبط",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 7),
                            Image.asset(
                              "assets/Images/send_icons.png",
                              width: 20,
                              height: 20,
                            ),
                          ],
                        ),
                      ).animate().fade(duration: 600.ms).scaleXY(begin: 0.8, end: 1.0),
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
}
