import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:plantsense_ai/core/errors/app_exception.dart';
import 'package:plantsense_ai/core/errors/error_mapper.dart';

void main() {
  group('ErrorMapper.fromHttpStatus', () {
    test('429 -> rateLimited with retryAfter', () {
      final e = ErrorMapper.fromHttpStatus(429);
      expect(e.kind, AppErrorKind.rateLimited);
      expect(e.retryAfter, isNotNull);
    });
    test('413 -> imageTooLarge',
        () => expect(ErrorMapper.fromHttpStatus(413).kind, AppErrorKind.imageTooLarge));
    test('401 -> unauthenticated',
        () => expect(ErrorMapper.fromHttpStatus(401).kind, AppErrorKind.unauthenticated));
    test('500 -> providerUnavailable',
        () => expect(ErrorMapper.fromHttpStatus(500).kind, AppErrorKind.providerUnavailable));
  });

  group('ErrorMapper.fromException', () {
    test('SocketException -> noConnection', () {
      expect(ErrorMapper.fromException(const SocketException('x')).kind,
          AppErrorKind.noConnection);
    });
    test('TimeoutException -> timeout', () {
      expect(ErrorMapper.fromException(TimeoutException('x')).kind,
          AppErrorKind.timeout);
    });
    test('passes through AppException', () {
      const original = AppException(AppErrorKind.contentBlocked);
      expect(ErrorMapper.fromException(original), same(original));
    });
  });

  group('retryability', () {
    test('timeout is retryable',
        () => expect(const AppException(AppErrorKind.timeout).isRetryable, isTrue));
    test('invalidCredentials is not retryable',
        () => expect(const AppException(AppErrorKind.invalidCredentials).isRetryable, isFalse));
  });
}
