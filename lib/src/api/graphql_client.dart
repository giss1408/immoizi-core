import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

/// Base class for failures talking to the Immoizi backend. [userMessage] is
/// safe to show in the UI.
sealed class ApiException implements Exception {
  const ApiException(this.userMessage);

  final String userMessage;

  @override
  String toString() => userMessage;
}

/// The backend could not be reached (offline, timeout, DNS, refused).
class NetworkException extends ApiException {
  const NetworkException()
      : super('Serveur injoignable — vérifiez votre connexion.');
}

/// The token is missing, invalid or expired, or the credentials are wrong.
class AuthException extends ApiException {
  const AuthException([String? message])
      : super(message ?? 'Session expirée — veuillez vous reconnecter.');
}

/// The backend answered, but with an error (GraphQL errors, HTTP 4xx/5xx, or
/// a body that is not JSON).
class ServerException extends ApiException {
  const ServerException(super.userMessage, {this.statusCode});

  final int? statusCode;
}

/// Turns any error into a message fit for the UI.
String describeError(Object error) => error is ApiException
    ? error.userMessage
    : 'Une erreur inattendue est survenue.';

class GraphQLClient {
  GraphQLClient({http.Client? httpClient, this.timeout = _defaultTimeout})
      : _http = httpClient ?? http.Client();

  static const _defaultTimeout = Duration(seconds: 20);

  final http.Client _http;
  final Duration timeout;

  Future<Map<String, dynamic>> query(
    String endpoint,
    String token,
    String query, {
    Map<String, dynamic> variables = const {},
  }) async {
    final uri = Uri.tryParse(endpoint);
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
      throw const ServerException('Adresse du serveur invalide.');
    }

    final http.Response response;
    try {
      response = await _http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Accept-Language': 'fr',
              if (token.isNotEmpty) 'Authorization': 'Bearer $token',
            },
            body: jsonEncode({'query': query, 'variables': variables}),
          )
          .timeout(timeout);
    } on TimeoutException {
      throw const NetworkException();
    } on http.ClientException {
      // http >= 1.0 wraps socket and TLS failures in ClientException.
      throw const NetworkException();
    }

    if (response.statusCode == 401 || response.statusCode == 403) {
      throw const AuthException();
    }

    final Object? payload;
    try {
      payload = jsonDecode(utf8.decode(response.bodyBytes));
    } on FormatException {
      throw ServerException(
          'Réponse inattendue du serveur (HTTP ${response.statusCode}).',
          statusCode: response.statusCode);
    }
    if (payload is! Map<String, dynamic>) {
      throw ServerException('Réponse inattendue du serveur.',
          statusCode: response.statusCode);
    }

    final errors = payload['errors'];
    if (errors is List && errors.isNotEmpty) {
      final messages = errors
          .map((error) =>
              error is Map ? '${error['message'] ?? ''}'.trim() : '$error')
          .where((message) => message.isNotEmpty)
          .toList();
      final message =
          messages.isEmpty ? 'Erreur du serveur.' : messages.join('\n');
      if (_isAuthError(message)) {
        throw AuthException(token.isEmpty
            ? 'Connectez-vous pour accéder à ces informations.'
            : null);
      }
      throw ServerException(message, statusCode: response.statusCode);
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ServerException('Erreur du serveur (HTTP ${response.statusCode}).',
          statusCode: response.statusCode);
    }

    final data = payload['data'];
    if (data is! Map<String, dynamic>) {
      throw const ServerException('Réponse vide du serveur.');
    }
    return data;
  }

  Future<String> login(
      String endpoint, String username, String password) async {
    try {
      final data = await query(
        endpoint,
        '',
        loginMutation,
        variables: {'username': username, 'password': password},
      );
      final token = (data['tokenAuth'] as Map<String, dynamic>?)?['token'];
      if (token is! String || token.isEmpty) {
        throw const ServerException('Connexion refusée par le serveur.');
      }
      return token;
    } on ServerException catch (error) {
      // tokenAuth reports bad credentials as a plain GraphQL error.
      final lower = error.userMessage.toLowerCase();
      if (lower.contains('mot de passe') || lower.contains('password')) {
        throw const AuthException('Identifiant ou mot de passe incorrect.');
      }
      rethrow;
    }
  }

  void close() => _http.close();

  static bool _isAuthError(String message) {
    final lower = message.toLowerCase();
    return lower.contains('authentif') || lower.contains('authentication');
  }
}

const loginMutation = r'''
mutation Login($username: String!, $password: String!) {
  tokenAuth(username: $username, password: $password) { token }
}
''';
