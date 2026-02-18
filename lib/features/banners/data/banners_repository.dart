import '../../../core/network/api_client.dart';
import '../models/banner_item.dart';

class BannersRepository {
  const BannersRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<List<BannerItem>> fetchBanners() async {
    final payload = await _apiClient.get('/banners');
    if (payload is! List<dynamic>) {
      return const <BannerItem>[];
    }

    return payload
        .whereType<Map<String, dynamic>>()
        .map(BannerItem.fromJson)
        .toList(growable: false);
  }
}
