class AppConfig {
  const AppConfig._();

  /// Production API host. Always used, unless overridden with
  /// `--dart-define=API_BASE_URL=...`.
  static const productionApiBaseUrl = 'https://api.7carbon.uz';
  // static const productionApiBaseUrl = 'http://localhost:7777';

  static const _apiBaseUrlOverride = String.fromEnvironment('API_BASE_URL');

  /// Resolution order: `--dart-define` override, then the production host.
  /// Every build (debug or release) targets the production API.
  static String get apiBaseUrl {
    final override = _apiBaseUrlOverride.trim();
    if (override.isNotEmpty) {
      return override;
    }
    return productionApiBaseUrl;
  }

  static const adminToken = String.fromEnvironment(
    'ADMIN_TOKEN',
    defaultValue: '',
  );
}
