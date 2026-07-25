import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:plantsense_ai/core/errors/app_exception.dart';
import 'package:plantsense_ai/core/networking/retry_policy.dart';

void main() {
  group('RetryPolicy', () {
    test('retries retryable errors up to maxAttempts then rethrows', () async {
      var calls = 0;
      final policy = RetryPolicy(
        maxAttempts: 3,
        baseDelay: Duration.zero,
        random: Random(1),
      );
      await expectLater(
        () => policy.run(() async {
          calls++;
          throw const AppException(AppErrorKind.timeout);
        }),
        throwsA(isA<AppException>()),
      );
      expect(calls, 3);
    });

    test('does not retry non-retryable errors', () async {
      var calls = 0;
      final policy = RetryPolicy(maxAttempts: 3, baseDelay: Duration.zero);
      await expectLater(
        () => policy.run(() async {
          calls++;
          throw const AppException(AppErrorKind.invalidCredentials);
        }),
        throwsA(isA<AppException>()),
      );
      expect(calls, 1);
    });

    test('returns value on eventual success', () async {
      var calls = 0;
      final policy = RetryPolicy(maxAttempts: 3, baseDelay: Duration.zero);
      final result = await policy.run(() async {
        calls++;
        if (calls < 2) throw const AppException(AppErrorKind.noConnection);
        return 'ok';
      });
      expect(result, 'ok');
      expect(calls, 2);
    });
  });
}
