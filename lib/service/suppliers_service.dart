import 'package:software_system/service/supabase_helper.dart';
import '../models/supplier_model.dart';

class SuppliersService {
  final _client = SupabaseHelper.client;

  Future<List<Supplier>> getAllSupplier() async {
    try {
      final response = await _client
          .from('suppliers')
          .select()
          .order('id', ascending: false);

      return (response as List)
          .map((e) => Supplier.fromMap(e))
          .toList();
    } catch (e) {
      throw Exception('خطأ في جلب العملاء: $e');
    }
  }

  Future<void> addSupplier(Supplier supplier) async {
    try {
      await _client
          .from('suppliers')
          .insert(supplier.toMap());
    } catch (e) {
      throw Exception('خطأ في إضافة المورد: $e');
    }
  }

  Future<String?> addSupplierWithValidation(Supplier supplier) async {
    try {
      await _client.from('suppliers').insert(supplier.toMap());
      return null;
    } catch (e) {
      if (e.toString().contains('suppliers_phone_key')) {
        return 'رقم الموبايل موجود بالفعل';
      }
      return 'حصل خطأ: $e';
    }
  }

  Future<void> updateSupplier(int id, Supplier supplier) async {
    try {
      await _client
          .from('suppliers')
          .update(supplier.toMap())
          .eq('id', id);
    } catch (e) {
      throw Exception('خطأ في تحديث المورد: $e');
    }
  }
  Future<String?> validateSupplier({required String name, required String phone, int? supplierId}) async {

    if (name.trim().length < 3) {
      return "الاسم يجب أن يكون على الأقل 3 حروف";
    }


    try {
      final existingSupplier = await getSupplierByPhone(phone);
      if (existingSupplier != null && existingSupplier.id != supplierId) {
        return "رقم الهاتف موجود بالفعل";
      }
    } catch (e) {
      return "خطأ أثناء التحقق من رقم الهاتف: $e";
    }

    return null;
  }


  Future<void> deleteSupplier(int id) async {
    try {
      await _client
          .from('suppliers')
          .delete()
          .eq('id', id);
    } catch (e) {
      throw Exception('خطأ في حذف المورد: $e');
    }
  }

  Future<Supplier?> getSupplierByPhone(String phone) async {
    try {
      final response = await _client
          .from('suppliers')
          .select()
          .eq('phone', phone)
          .maybeSingle();

      return response == null ? null : Supplier.fromMap(response);
    } catch (e) {
      throw Exception('خطأ في جلب المورد برقم الهاتف: $e');
    }
  }
}