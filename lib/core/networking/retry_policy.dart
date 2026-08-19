import 'dart:async';
import 'dart:math';

import '../errors/app_exception.dart';
import '../errors/error_mapper.dart';

/// Exponential backoff with full jitter. Only retryable failures are retried;
/// invalid credentials, invalid payloads and blocked content are surfaced
/// immediately and never retried.
class RetryPolicy {
  RetryPolicy({
    this.maxAttempts = 3,
    this.baseDelay = const Duration(milliseconds: 400),
    this.maxDelay = const Duration(seconds: 8),
    Random? random,
  }) : _random = random ?? Random();

  final int maxAttempts;
  final Duration baseDelay;
  final Duration maxDelay;
  final Random _random;

  Future<T> run<T>(Future<T> Function() action) async {
    var attempt = 0;
    while (true) {
      attempt++;
      try {
        return await action();
      } catch (raw) {
        final AppException e = ErrorMapper.fromException(raw);
        final bool canRetry = e.isRetryable && attempt < maxAttempts;
        if (!canRetry) rethrow;
        await Future<void>.delayed(_backoff(attempt, e.retryAfter));
      }
    }
  }

  Duration _backoff(int attempt, Duration? retryAfter) {
    if (retryAfter != null) return retryAfter;
    final int expMs = (baseDelay.inMilliseconds * pow(2, attempt - 1)).toInt();
    final int cappedMs = min(expMs, maxDelay.inMilliseconds);
    // Full jitter.
    return Duration(milliseconds: _random.nextInt(cappedMs + 1));
  }
}
