// import 'package:supabase_flutter/supabase_flutter.dart';

// class SupabaseHelper {
//  static Future<void> init() async {
//     Supabase.initialize(
//       url: "https://sdzgmvjzybfdswsbqsie.supabase.co",
//       anonKey:
//           "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNkemdtdmp6eWJmZHN3c2Jxc2llIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjA3Mjc4OTYsImV4cCI6MjA3NjMwMzg5Nn0.5gkTMSb6XIUl9enmLB16JG8HAxTc4_Y1ZHpUB6w4MKA",
//     );
//   }
// }
// lib/core/supabase_helper.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseHelper {
  static const String url = "https://sdzgmvjzybfdswsbqsie.supabase.co";
  static const String anonKey =
      "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNkemdtdmp6eWJmZHN3c2Jxc2llIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjA3Mjc4OTYsImV4cCI6MjA3NjMwMzg5Nn0.5gkTMSb6XIUl9enmLB16JG8HAxTc4_Y1ZHpUB6w4MKA";

  static Future<void> init() async {
    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}