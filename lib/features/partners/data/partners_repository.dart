import '../../../core/network/api_client.dart';
import '../models/partner_item.dart';

class PartnersRepository {
  const PartnersRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<List<PartnerItem>> fetchPartners() async {
    final payload = await _apiClient.get('/partners');
    if (payload is! List<dynamic>) {
      return const <PartnerItem>[];
    }

    return payload
        .whereType<Map<String, dynamic>>()
        .map(PartnerItem.fromJson)
        .toList(growable: false);
  }
}
