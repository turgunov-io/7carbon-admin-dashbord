import '../../../core/network/api_client.dart';
import '../models/about_response.dart';

class AboutRepository {
  const AboutRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<AboutResponse> fetchAbout() async {
    final payload = await _apiClient.get('/about');
    if (payload is! Map<String, dynamic>) {
      return const AboutResponse(page: null);
    }

    return AboutResponse.fromJson(payload);
  }
}
