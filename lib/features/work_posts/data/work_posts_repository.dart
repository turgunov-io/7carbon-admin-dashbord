import '../../../core/network/api_client.dart';
import '../models/work_post_item.dart';

class WorkPostsRepository {
  const WorkPostsRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<List<WorkPostItem>> fetchWorkPosts() async {
    final payload = await _apiClient.get('/work_post');
    if (payload is! List<dynamic>) {
      return const <WorkPostItem>[];
    }

    return payload
        .whereType<Map<String, dynamic>>()
        .map(WorkPostItem.fromJson)
        .toList(growable: false);
  }
}
