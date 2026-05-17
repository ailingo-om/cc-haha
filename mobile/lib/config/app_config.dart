import 'dart:io' show Platform;

/// Application configuration and constants.
class AppConfig {
  // macOS connects to local server; mobile connects to remote via nginx
  static String serverUrl = Platform.isMacOS
      ? 'http://127.0.0.1:3456'
      : 'https://p.v.ailingo.net';
  static String apiKey = '';

  /// Whether this is running on a desktop OS (macOS).
  static bool get isDesktop => Platform.isMacOS;

  /// JPush AppKey — from 极光控制台 → 应用设置.
  /// This is NOT a secret; it's embedded in the app.
  static const String jpushAppKey = 'YOUR_JPUSH_APP_KEY';

  static const String appName = 'haha';
  static const Duration requestTimeout = Duration(seconds: 30);
  static const Duration wsPingInterval = Duration(seconds: 30);
  static const Duration wsReconnectCap = Duration(seconds: 30);
  static const int wsReconnectBaseMs = 1000;

  /// Returns the WebSocket URL derived from the server URL.
  static String get wsUrl {
    final uri = Uri.parse(serverUrl);
    final scheme = uri.scheme == 'https' ? 'wss' : 'ws';
    return '$scheme://${uri.host}:${uri.port}';
  }
}
