class AppConfig {
  const AppConfig._();

  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:7777',
  );

  static const adminToken = String.fromEnvironment(                                       
    'ADMIN_TOKEN',
    defaultValue: '',
  );
}
