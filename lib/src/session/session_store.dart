import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// A signed-in session restored from [SessionStore].
class StoredSession {
  const StoredSession(
      {required this.endpoint, required this.token, required this.username});

  final String endpoint;
  final String token;
  final String username;
}

/// Keeps the bearer token in the platform keystore (Keychain / Android
/// Keystore) so users stay signed in across restarts.
class SessionStore {
  SessionStore(String namespace, {FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
                aOptions: AndroidOptions(encryptedSharedPreferences: true)),
        _endpointKey = '${namespace}_endpoint',
        _tokenKey = '${namespace}_token',
        _usernameKey = '${namespace}_username';

  final FlutterSecureStorage _storage;
  final String _endpointKey;
  final String _tokenKey;
  final String _usernameKey;

  /// Returns null when nobody is signed in or the keystore is unavailable.
  Future<StoredSession?> restore() async {
    try {
      final token = await _storage.read(key: _tokenKey);
      if (token == null || token.isEmpty) return null;
      return StoredSession(
        endpoint: await _storage.read(key: _endpointKey) ?? '',
        token: token,
        username: await _storage.read(key: _usernameKey) ?? '',
      );
    } catch (_) {
      // A corrupted keystore entry must not block startup; sign in again.
      return null;
    }
  }

  Future<void> save(StoredSession session) async {
    try {
      await _storage.write(key: _endpointKey, value: session.endpoint);
      await _storage.write(key: _tokenKey, value: session.token);
      await _storage.write(key: _usernameKey, value: session.username);
    } catch (_) {
      // Not persisting only means signing in again next launch.
    }
  }

  Future<void> clear() async {
    try {
      await _storage.delete(key: _tokenKey);
    } catch (_) {
      // Nothing more we can do; the token is dropped from memory anyway.
    }
  }
}
