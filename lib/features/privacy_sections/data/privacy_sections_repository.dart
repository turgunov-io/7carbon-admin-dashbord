import '../../../core/network/api_client.dart';
import '../models/privacy_section_item.dart';

class PrivacySectionsRepository {
  const PrivacySectionsRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<List<PrivacySectionItem>> fetchPrivacySections() async {
    final payload = await _apiClient.get('/privacy_sections');
    if (payload is! List<dynamic>) {
      return const <PrivacySectionItem>[];
    }

    return payload
        .whereType<Map<String, dynamic>>()
        .map(PrivacySectionItem.fromJson)
        .toList(growable: false);
  }
}
