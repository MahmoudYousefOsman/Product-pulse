import 'package:software_system/service/supabase_helper.dart';
import '../models/client_model.dart';

class ClientsService {
  final _client = SupabaseHelper.client;

  Future<List<Client>> getAllClients() async {
    try {
      final response = await _client
          .from('clients')
          .select()
          .order('id', ascending: false);

      return (response as List)
          .map((e) => Client.fromMap(e))
          .toList();
    } catch (e) {
      throw Exception('خطأ في جلب العملاء: $e');
    }
  }

  Future<void> addClient(Client client) async {
    try {
      await _client
          .from('clients')
          .insert(client.toMap());
    } catch (e) {
      throw Exception('خطأ في إضافة العميل: $e');
    }
  }

  Future<String?> addClientWithValidation(Client client) async {
    try {
      await _client.from('clients').insert(client.toMap());
      return null;
    } catch (e) {
      if (e.toString().contains('clients_phone_key')) {
        return 'رقم الموبايل موجود بالفعل';
      }
      return 'حصل خطأ: $e';
    }
  }

  Future<void> updateClient(int id, Client client) async {
    try {
      await _client
          .from('clients')
          .update(client.toMap())
          .eq('id', id);
    } catch (e) {
      throw Exception('خطأ في تحديث العميل: $e');
    }
  }


  Future<void> deleteClient(int id) async {
    try {
      await _client
          .from('clients')
          .delete()
          .eq('id', id);
    } catch (e) {
      throw Exception('خطأ في حذف العميل: $e');
    }
  }

  Future<Client?> getClientByPhone(String phone) async {
    try {
      final response = await _client
          .from('clients')
          .select()
          .eq('phone', phone)
          .maybeSingle();

      return response == null ? null : Client.fromMap(response);
    } catch (e) {
      throw Exception('خطأ في جلب العميل برقم الهاتف: $e');
    }
  }
}