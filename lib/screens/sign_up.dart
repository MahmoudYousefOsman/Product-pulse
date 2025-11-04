import 'package:flutter/material.dart';
import 'package:software_system/widgets/animation_logo.dart';
import 'package:software_system/widgets/custom_text_filed.dart';

class SignUp extends StatelessWidget {
  SignUp({super.key});

  final TextEditingController email = TextEditingController();
  final TextEditingController fullName = TextEditingController();
  final TextEditingController mystory = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController confirmPassword = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
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
              height: 750,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 15),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Icon(Icons.arrow_back_rounded),
                          ),
                          SizedBox(width: 10),
                          Text(
                            "Back to login",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                
                    AnimatedLogo(imagePath: "assets/Images/smart_inventory.png"),
                    Text(
                      "Create Account",
                      style: TextStyle(fontWeight: FontWeight.w500, fontSize: 17),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Start managing your inventory",
                      style: TextStyle(fontWeight: FontWeight.w400, fontSize: 16),
                    ),
                    SizedBox(height: 30),
                    //-------------------------------------------------
                    Container(
                      alignment: Alignment.centerLeft,
                
                      child: Row(
                        children: [
                          SizedBox(width: 15),
                          Text(
                            "Full Name",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                
                    CustomTextField(
                      controller: fullName,
                      hintText: "Team 404 Error",
                      prefixIcon: Icons.person_outline_rounded,
                    ),
                
                    ///---------------------------------------------
                    Container(
                      alignment: Alignment.centerLeft,
                
                      child: Row(
                        children: [
                          SizedBox(width: 15),
                          Text(
                            "Email Address",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                
                    CustomTextField(
                      controller: email,
                      hintText: "name@gmail.com",
                      prefixIcon: Icons.email_outlined,
                    ),
                    //----------------------------------------------------
                    Container(
                      alignment: Alignment.centerLeft,
                
                      child: Row(
                        children: [
                          SizedBox(width: 15),
                          Text(
                            "Company / Story Name",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                
                    CustomTextField(
                      controller: mystory,
                      hintText: "My Story",
                      prefixIcon: Icons.home_work_outlined,
                    ),
                    //-------------------------------------------------------------------
                    Container(
                      alignment: Alignment.centerLeft,
                
                      child: Row(
                        children: [
                          SizedBox(width: 15),
                          Text(
                            "Password",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                
                    CustomTextField(
                      obscureText: true,
                      controller: password,
                      hintText: "..............",
                      prefixIcon: Icons.lock_outline_rounded,
                    ),
                
                    ///---------------------------------------------------
                    Container(
                      alignment: Alignment.centerLeft,
                
                      child: Row(
                        children: [
                          SizedBox(width: 15),
                          Text(
                            "Confirm Password",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                
                    CustomTextField(
                      obscureText: true,
                      controller: confirmPassword,
                      hintText: "..............",
                      prefixIcon: Icons.lock_outline_rounded,
                    ),
                
                    ///----------------------------------------------------
                    Padding(
                      padding: const EdgeInsets.all(15),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF1960fb), Color(0xFF3d37c1)],
                          ),
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(7),
                        ),
                        width: double.infinity,
                        height: 40,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Create Account",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
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
