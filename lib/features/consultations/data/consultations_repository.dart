import '../../../core/network/api_client.dart';
import '../models/consultation_create_request.dart';
import '../models/consultation_item.dart';
import '../models/consultation_list_response.dart';
import '../models/consultation_status.dart';

class ConsultationsRepository {
  const ConsultationsRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<List<ConsultationItem>> fetchConsultations({
    ConsultationStatus? status,
  }) async {
    if (status != null) {
      return _fetchByStatus(status);
    }

    final groups = await Future.wait(
      ConsultationStatus.values.map(_fetchByStatus),
    );

    final deduplicated = <int, ConsultationItem>{};
    for (final group in groups) {
      for (final item in group) {
        deduplicated[item.id] = item;
      }
    }

    final merged = deduplicated.values.toList(growable: false)
      ..sort((a, b) {
        final left = a.createdAt;
        final right = b.createdAt;
        if (left == null && right == null) {
          return b.id.compareTo(a.id);
        }
        if (left == null) {
          return 1;
        }
        if (right == null) {
          return -1;
        }
        return right.compareTo(left);
      });

    return merged;
  }

  Future<void> createConsultation(ConsultationCreateRequest request) async {
    await _apiClient.post('/api/consultations', data: request.toJson());
  }

  Future<List<ConsultationItem>> _fetchByStatus(
    ConsultationStatus status,
  ) async {
    final payload = await _apiClient.get(
      '/api/consultations',
      queryParameters: {'status': status.apiValue},
    );

    if (payload is! Map<String, dynamic>) {
      return const <ConsultationItem>[];
    }

    final response = ConsultationListResponse.fromJson(payload);
    return response.data;
  }
}
