import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../errors/app_exception.dart';
import '../errors/error_mapper.dart';
import 'retry_policy.dart';

/// Thin HTTP wrapper adding timeouts, retry with backoff, JSON decoding and
/// normalized error mapping. It never logs request bodies, headers, tokens or
/// image bytes.
class ApiClient {
  ApiClient({http.Client? client, RetryPolicy? retryPolicy})
    : _client = client ?? http.Client(),
      _retry =
          retryPolicy ?? RetryPolicy(maxAttempts: AppConfig.httpMaxRetries);

  final http.Client _client;
  final RetryPolicy _retry;

  Future<Map<String, dynamic>> getJson(
    Uri uri, {
    Map<String, String>? headers,
    Duration? timeout,
  }) {
    return _retry.run(() async {
      final http.Response res = await _client
          .get(uri, headers: headers)
          .timeout(timeout ?? AppConfig.httpTimeout);
      return _decode(res);
    });
  }

  Future<Map<String, dynamic>> postJson(
    Uri uri, {
    Map<String, String>? headers,
    Object? body,
    Duration? timeout,
  }) {
    return _retry.run(() async {
      final http.Response res = await _client
          .post(
            uri,
            headers: {'Content-Type': 'application/json', ...?headers},
            body: body is String ? body : jsonEncode(body),
          )
          .timeout(timeout ?? AppConfig.httpTimeout);
      return _decode(res);
    });
  }

  Map<String, dynamic> _decode(http.Response res) {
    if (res.statusCode >= 200 && res.statusCode < 300) {
      if (res.body.isEmpty) return <String, dynamic>{};
      try {
        final decoded = jsonDecode(res.body);
        if (decoded is Map<String, dynamic>) return decoded;
        return <String, dynamic>{'data': decoded};
      } catch (_) {
        throw const AppException(AppErrorKind.malformedResponse);
      }
    }
    throw ErrorMapper.fromHttpStatus(res.statusCode, body: res.body);
  }

  void dispose() => _client.close();
}
