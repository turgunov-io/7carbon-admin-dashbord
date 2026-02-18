import '../../../core/network/api_client.dart';
import '../models/tuning_item.dart';

class TuningRepository {
  const TuningRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<List<TuningItem>> fetchTuning() async {
    final payload = await _apiClient.get('/tuning');
    if (payload is! List<dynamic>) {
      return const <TuningItem>[];
    }

    return payload
        .whereType<Map<String, dynamic>>()
        .map(TuningItem.fromJson)
        .toList(growable: false);
  }
}
