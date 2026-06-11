class AppConfig {
  /// Base URL API. Untuk emulator Android default `10.0.2.2` (loopback ke host).
  /// Override saat build/run:
  ///   flutter run --dart-define=API_BASE_URL=https://api-bengkel.up.railway.app/api
  static const String apiBase = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000/api',
  );

  static const String appName = 'BengkelKu';
}
