import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:software_system/screens/all_prodect.dart';
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
  bool _obscurePassword = true;

  final storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    // ما نشيك على التوكنات في initState
    // الشيك بيكون في main أو splash screen
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
        if (rememberMe) {
          // حفظ التوكنات فقط إذا اختار المستخدم "تذكرني"
          await storage.write(
            key: 'accessToken',
            value: response.session?.accessToken,
          );
          await storage.write(
            key: 'refreshToken',
            value: response.session?.refreshToken,
          );
        } else {
          // حذف أي توكنات قديمة إذا لم يختر "تذكرني"
          await storage.delete(key: 'accessToken');
          await storage.delete(key: 'refreshToken');
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم تسجيل الدخول بنجاح ✅'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );

          await Future.delayed(const Duration(milliseconds: 500));

          if (mounted) {
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
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('فشل تسجيل الدخول ❌'),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ: $error'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isloaded = false;
        });
      }
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
                      prefixIcon: CupertinoIcons.mail_solid,
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

                    // 👁️ هنا يظهر زر العين
                    CustomTextField(
                      controller: password,
                      hintText: "........",
                      prefixIcon: CupertinoIcons.lock_fill,
                      obscureText: _obscurePassword,
                      suffixIcon: GestureDetector(
                        onTap: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                        child: Icon(
                          _obscurePassword
                              ? CupertinoIcons.eye_slash_fill
                              : CupertinoIcons.eye_fill,
                          color: Colors.grey,
                        ),
                      ),
                    ),

                    // تذكرني ونسيت كلمة السر
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
                        const Spacer(),
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
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
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
                                        CupertinoIcons.arrow_right,
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