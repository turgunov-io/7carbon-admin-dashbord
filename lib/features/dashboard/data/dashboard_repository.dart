import '../../../core/network/api_client.dart';
import '../domain/dashboard_stats.dart';
import '../domain/health_status.dart';

class DashboardRepository {
  const DashboardRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<DashboardStats> fetchStats() async {
    final responses = await Future.wait<dynamic>([
      _apiClient.get('/healthz'),
      _apiClient.get('/banners'),
      _apiClient.get('/contact'),
      _apiClient.get('/about'),
      _apiClient.get('/partners'),
      _apiClient.get('/tuning'),
      _apiClient.get('/service_offerings'),
      _apiClient.get('/privacy_sections'),
      _apiClient.get('/portfolio_items'),
      _apiClient.get('/work_post'),
      _apiClient.get('/api/consultations', queryParameters: {'status': 'new'}),
      _apiClient.get(
        '/api/consultations',
        queryParameters: {'status': 'in_progress'},
      ),
      _apiClient.get(
        '/api/consultations',
        queryParameters: {'status': 'completed'},
      ),
    ]);

    final health = HealthStatus.fromJson(_asMap(responses[0]));
    final aboutMap = _asMap(responses[3]);
    final aboutMetrics = _asList(aboutMap['metrics']).length;
    final aboutSections = _asList(aboutMap['sections']).length;

    return DashboardStats(
      health: health,
      banners: _asList(responses[1]).length,
      contacts: _asList(responses[2]).length,
      aboutMetrics: aboutMetrics,
      aboutSections: aboutSections,
      partners: _asList(responses[4]).length,
      tuning: _asList(responses[5]).length,
      serviceOfferings: _asList(responses[6]).length,
      privacySections: _asList(responses[7]).length,
      portfolioItems: _asList(responses[8]).length,
      workPosts: _asList(responses[9]).length,
      consultationsNew: _extractConsultationsCount(responses[10]),
      consultationsInProgress: _extractConsultationsCount(responses[11]),
      consultationsCompleted: _extractConsultationsCount(responses[12]),
    );
  }

  Map<String, dynamic> _asMap(dynamic value) {
    return value is Map<String, dynamic> ? value : <String, dynamic>{};
  }

  List<dynamic> _asList(dynamic value) {
    return value is List<dynamic> ? value : <dynamic>[];
  }

  int _extractConsultationsCount(dynamic payload) {
    final map = _asMap(payload);
    return _asList(map['data']).length;
  }
}
