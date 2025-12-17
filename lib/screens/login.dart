import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:software_system/screens/all_prodect.dart';
import 'package:software_system/screens/forget_password.dart';
import 'package:software_system/widgets/animation_logo.dart';
import 'package:software_system/widgets/custom_text_filed.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:page_transition/page_transition.dart';
import 'package:flutter/cupertino.dart';

class Login_screen extends StatefulWidget {
  const Login_screen({super.key});

  @override
  State<Login_screen> createState() => _Login_screenState();
}

class _Login_screenState extends State<Login_screen> {
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  bool rememberMe = false;
  bool isloaded = false;
  // 1. المتغير الجديد للتحكم في إخفاء/إظهار كلمة السر
  bool _isPasswordObscured = true;

  final storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _checkStoredTokens();
  }

  Future<void> _checkStoredTokens() async {
    String? accessToken = await storage.read(key: 'accessToken');
    String? refreshToken = await storage.read(key: 'refreshToken');

    print('AccessToken: $accessToken');
    print('RefreshToken: $refreshToken');

    if (accessToken != null && refreshToken != null) {
      Navigator.pushReplacement(
        context,
        PageTransition(
          type: PageTransitionType.rightToLeft,
          child: const AllProdect(),
          duration: const Duration(milliseconds: 400),
        ),
      );
    }
  }

  // 2. دالة لتبديل حالة الإخفاء/الإظهار
  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordObscured = !_isPasswordObscured;
    });
  }

  Future<void> _handleLogin() async {
    final supabase = Supabase.instance.client;

    if (email.text.isEmpty || password.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Center(
            child: Text('من فضلك أدخل البريد الإلكتروني وكلمة السر'),
          ),
          backgroundColor: Colors.blueGrey,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      isloaded = true;
    });

    try {
      final AuthResponse response = await supabase.auth.signInWithPassword(
        email: email.text.trim(),
        password: password.text.trim(),
      );

      if (response.user != null) {
        // تخزين التوكنات لو rememberMe مفعّل
        if (rememberMe) {
          await storage.write(key: 'accessToken', value: response.session?.accessToken);
          await storage.write(key: 'refreshToken', value: response.session?.refreshToken);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم تسجيل الدخول بنجاح ✅'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );

        Navigator.pushReplacement(
          context,
          PageTransition(
            type: PageTransitionType.rightToLeft,
            child: const AllProdect(),
            duration: const Duration(milliseconds: 400),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('فشل تسجيل الدخول ❌'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ: $error'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      setState(() {
        isloaded = false;
      });
    }
  }

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
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(50),
              ),
              width: double.infinity,
              height: 550,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    const AnimatedLogo(
                      imagePath: "assets/Images/smart_inventory.png",
                    ),
                    AutoSizeText(
                      "نبض المنتج",
                      style: GoogleFonts.aBeeZee(fontSize: 18),
                    )
                        .animate(
                          onPlay: (controller) => controller.repeat(),
                        )
                        .fadeIn(duration: 500.ms)
                        .then()
                        .fadeOut(duration: 500.ms),
                    const SizedBox(height: 5),
                    const Text(
                      "تسجيل الدخول لإدارة عملك",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 30),

                    // البريد الإلكتروني
                    Container(
                      alignment: Alignment.centerLeft,
                      child: const Padding(
                        padding: EdgeInsets.only(left: 15),
                        child: Text(
                          "البريد الإلكتروني",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    CustomTextField(
                      controller: email,
                      hintText: "name@gmail.com",
                      prefixIcon: CupertinoIcons.mail_solid, // هنا استخدمنا CupertinoIcons
                    ),

                    const SizedBox(height: 10),

                    // كلمة السر
                    Container(
                      alignment: Alignment.centerLeft,
                      child: const Padding(
                        padding: EdgeInsets.only(left: 15),
                        child: Text(
                          "كلمة السر",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    CustomTextField(
                      controller: password,
                      hintText: "........",
                      prefixIcon: CupertinoIcons.lock_fill, // هنا استخدمنا CupertinoIcons
                      // **التعديل رقم 3: استخدام المتغير للتحكم في الإخفاء**
                      obscureText: _isPasswordObscured, 
                      // **التعديل رقم 4: إضافة زر العين لـ suffixIcon**
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordObscured
                              ? CupertinoIcons.eye_slash_fill // عين مغلقة (إخفاء)
                              : CupertinoIcons.eye_fill, // عين مفتوحة (إظهار)
                          color: const Color(0xff97989f),
                        ),
                        onPressed: _togglePasswordVisibility, // ربط الدالة بالضغط
                      ),
                    ),

                    // تذكرني (مع إزالة "هل نسيت كلمة السر؟")
                    Row(
                      children: [
                        Transform.scale(
                          scale: 0.9,
                          child: Checkbox(
                            value: rememberMe,
                            onChanged: (value) {
                              setState(() {
                                rememberMe = value ?? false;
                              });
                            },
                            activeColor: Colors.black,
                          ),
                        ),
                        const Text(
                          "تذكرنى",
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xff97989f),
                          ),
                        ),
                        const Spacer(), // سيأخذ كل المساحة المتبقية
                        // **التعديل رقم 5: تم حذف GestureDetector الخاص بـ "هل نسيت كلمة السر؟"**
                        const SizedBox(width: 15),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // زر تسجيل الدخول
                    GestureDetector(
                      onTap: _handleLogin,
                      child: Padding(
                        padding: const EdgeInsets.all(15),
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
                          child: Center(
                            child: isloaded
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Text(
                                        "تسجيل الدخول ",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 17,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      SizedBox(width: 5),
                                      Icon(
                                        CupertinoIcons.arrow_right, // هنا استخدمنا CupertinoIcons
                                        color: Colors.white,
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}