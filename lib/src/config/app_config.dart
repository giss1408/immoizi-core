/// Build-time configuration, set with `--dart-define`:
///
/// ```bash
/// flutter run \
///   --dart-define=IMMOIZI_ENDPOINT=https://api.example.com/graphql \
///   --dart-define=IMMOIZI_DEMO_USERNAME=tenant_demo \
///   --dart-define=IMMOIZI_DEMO_PASSWORD=...
/// ```
///
/// Demo credentials are empty unless provided, so none ship in release builds.
class AppConfig {
  static const endpoint = String.fromEnvironment(
    'IMMOIZI_ENDPOINT',
    defaultValue: 'http://127.0.0.1:8000/graphql',
  );

  static const demoUsername = String.fromEnvironment('IMMOIZI_DEMO_USERNAME');
  static const demoPassword = String.fromEnvironment('IMMOIZI_DEMO_PASSWORD');
}
