import '../../../core/network/api_client.dart';
import '../models/portfolio_item.dart';

class PortfolioItemsRepository {
  const PortfolioItemsRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<List<PortfolioItem>> fetchPortfolioItems() async {
    final payload = await _apiClient.get('/portfolio_items');
    if (payload is! List<dynamic>) {
      return const <PortfolioItem>[];
    }

    return payload
        .whereType<Map<String, dynamic>>()
        .map(PortfolioItem.fromJson)
        .toList(growable: false);
  }
}
