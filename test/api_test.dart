import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:immoizi_core/immoizi_core.dart';

const _endpoint = 'http://backend.test/graphql';

GraphQLClient _clientReturning(int status, Object body) =>
    GraphQLClient(httpClient: MockClient((request) async {
      return http.Response(body is String ? body : jsonEncode(body), status,
          headers: {'content-type': 'application/json; charset=utf-8'});
    }));

void main() {
  group('GraphQLClient', () {
    test('returns data and sends the bearer token', () async {
      late http.Request sent;
      final client = GraphQLClient(httpClient: MockClient((request) async {
        sent = request;
        return http.Response(
            jsonEncode({
              'data': {'ok': true}
            }),
            200);
      }));
      final data = await client.query(_endpoint, 'abc', '{ ok }');
      expect(data, {'ok': true});
      expect(sent.headers['Authorization'], 'Bearer abc');
    });

    test('maps GraphQL errors to ServerException with their message', () async {
      final client = _clientReturning(200, {
        'errors': [
          {'message': 'Bien introuvable.'}
        ]
      });
      expect(
          () => client.query(_endpoint, 'abc', '{ x }'),
          throwsA(isA<ServerException>()
              .having((e) => e.userMessage, 'message', 'Bien introuvable.')));
    });

    test('maps authentication errors to AuthException', () async {
      final client = _clientReturning(200, {
        'errors': [
          {'message': "L'authentification est obligatoire."}
        ]
      });
      expect(() => client.query(_endpoint, 'expired', '{ x }'),
          throwsA(isA<AuthException>()));
    });

    test('maps HTTP 401 to AuthException', () async {
      final client = _clientReturning(401, {'error': 'nope'});
      expect(() => client.query(_endpoint, 'abc', '{ x }'),
          throwsA(isA<AuthException>()));
    });

    test('reports a non-JSON body instead of crashing', () async {
      final client = _clientReturning(502, '<html>Bad gateway</html>');
      expect(
          () => client.query(_endpoint, '', '{ x }'),
          throwsA(isA<ServerException>()
              .having((e) => e.statusCode, 'statusCode', 502)));
    });

    test('maps connection failures to NetworkException', () async {
      final client = GraphQLClient(
          httpClient:
              MockClient((_) async => throw http.ClientException('refused')));
      expect(() => client.query(_endpoint, '', '{ x }'),
          throwsA(isA<NetworkException>()));
    });

    test('rejects an invalid endpoint', () async {
      final client = _clientReturning(200, {'data': {}});
      expect(() => client.query('not a url', '', '{ x }'),
          throwsA(isA<ServerException>()));
    });

    test('login maps bad credentials to AuthException', () async {
      final client = _clientReturning(200, {
        'errors': [
          {'message': 'Identifiant ou mot de passe invalide.'}
        ]
      });
      expect(() => client.login(_endpoint, 'user', 'wrong'),
          throwsA(isA<AuthException>()));
    });

    test('login returns the token', () async {
      final client = _clientReturning(200, {
        'data': {
          'tokenAuth': {'token': 'signed-token'}
        }
      });
      expect(await client.login(_endpoint, 'user', 'pass'), 'signed-token');
    });
  });

  test('describeError hides unexpected exception details', () {
    expect(describeError(const NetworkException()),
        const NetworkException().userMessage);
    expect(describeError(StateError('internal')),
        'Une erreur inattendue est survenue.');
  });

  test('notificationsSignature ignores order and tracks read state', () {
    final a = notificationsSignature(
        [(id: '1', isRead: false), (id: '2', isRead: true)]);
    final b = notificationsSignature(
        [(id: '2', isRead: true), (id: '1', isRead: false)]);
    final c = notificationsSignature(
        [(id: '1', isRead: true), (id: '2', isRead: true)]);
    expect(a, b);
    expect(a, isNot(c));
  });

  group('SessionStore', () {
    test('saves, restores and clears the token', () async {
      FlutterSecureStorage.setMockInitialValues({});
      final store = SessionStore('test');
      expect(await store.restore(), isNull);

      await store.save(const StoredSession(
          endpoint: _endpoint, token: 'tok', username: 'nadia'));
      final restored = await store.restore();
      expect(restored?.token, 'tok');
      expect(restored?.username, 'nadia');

      await store.clear();
      expect(await store.restore(), isNull);
    });
  });
}
