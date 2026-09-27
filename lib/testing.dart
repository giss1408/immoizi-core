/// Test helpers shared by the Immoizi apps. Import from tests only: it uses
/// `dart:io`.
library;

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'immoizi_core.dart';

/// Every literal passed to tr() under [dir], decoded like Dart would.
Set<String> trKeys(String dir) {
  // Single- or double-quoted Dart literal; the text is group 1 or 2.
  const literal = r"""(?:'((?:[^'\\\n]|\\.)*)'|"((?:[^"\\\n]|\\.)*)")""";
  final direct = RegExp(r'(?<![\w.])tr\(\s*' + literal);
  final ternary = RegExp(
      r'(?<![\w.])tr\(\s*[^,()]*?\?\s*' + literal + r'\s*:\s*' + literal);
  String decode(String s) => s
      .replaceAllMapped(RegExp(r'\\u([0-9a-fA-F]{4})'),
          (m) => String.fromCharCode(int.parse(m[1]!, radix: 16)))
      .replaceAll(r"\'", "'")
      .replaceAll(r'\$', r'$');
  final keys = <String>{};
  for (final file in Directory(dir).listSync(recursive: true)) {
    if (file is! File || !file.path.endsWith('.dart')) continue;
    final source = file.readAsStringSync();
    for (final m in direct.allMatches(source)) {
      keys.add(decode(m[1] ?? m[2]!));
    }
    for (final m in ternary.allMatches(source)) {
      keys
        ..add(decode(m[1] ?? m[2]!))
        ..add(decode(m[3] ?? m[4]!));
    }
  }
  return keys;
}

/// tr() strings under [dir] with no registered English translation.
List<String> missingTranslations(String dir) =>
    trKeys(dir).where((key) => !AppStrings.hasTranslation(key)).toList();

/// A 200 response with [body] encoded as JSON.
http.Response jsonResponse(Object body) => http.Response(jsonEncode(body), 200,
    headers: {'content-type': 'application/json; charset=utf-8'});

/// Records requests and answers with [handler].
class FakeBackend {
  FakeBackend(this.handler);

  final http.Response Function(Map<String, dynamic> body, http.Request request)
      handler;
  final requests = <http.Request>[];

  GraphQLClient get client =>
      GraphQLClient(httpClient: MockClient((request) async {
        requests.add(request);
        return handler(
            jsonDecode(request.body) as Map<String, dynamic>, request);
      }));
}
