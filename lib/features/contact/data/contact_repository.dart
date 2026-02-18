import '../../../core/network/api_client.dart';
import '../models/contact_item.dart';

class ContactRepository {
  const ContactRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<List<ContactItem>> fetchContacts() async {
    final payload = await _apiClient.get('/contact');
    if (payload is! List<dynamic>) {
      return const <ContactItem>[];
    }

    return payload
        .whereType<Map<String, dynamic>>()
        .map(ContactItem.fromJson)
        .toList(growable: false);
  }
}
