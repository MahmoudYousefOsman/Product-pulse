import 'package:flutter/material.dart';
import 'package:software_system/screens/spalsh_screens.dart';
import 'package:software_system/service/supabase_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseHelper.init();
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreens() 
    );
  }
}
