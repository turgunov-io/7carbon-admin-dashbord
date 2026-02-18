import '../../../core/network/api_client.dart';
import '../models/service_offering_item.dart';

class ServiceOfferingsRepository {
  const ServiceOfferingsRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<List<ServiceOfferingItem>> fetchServiceOfferings() async {
    final payload = await _apiClient.get('/service_offerings');
    if (payload is! List<dynamic>) {
      return const <ServiceOfferingItem>[];
    }

    return payload
        .whereType<Map<String, dynamic>>()
        .map(ServiceOfferingItem.fromJson)
        .toList(growable: false);
  }
}
