class AppConfig {
  const AppConfig._();

  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.7carbon.uz',
  );

  static const adminToken = String.fromEnvironment(                                       
    'ADMIN_TOKEN',
    defaultValue: '',
  );
}
