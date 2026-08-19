import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

import '../../l10n/app_localizations.dart';
import 'app_exception.dart';

/// Maps raw exceptions (HTTP status, socket, platform, timeout) into typed
/// [AppException]s, and typed errors into localized, actionable strings.
class ErrorMapper {
  const ErrorMapper._();

  static AppException fromHttpStatus(int status, {String? body}) {
    switch (status) {
      case 400:
        return const AppException(
          AppErrorKind.invalidInput,
          debugDetail: 'HTTP 400',
        );
      case 401:
        return const AppException(
          AppErrorKind.unauthenticated,
          debugDetail: 'HTTP 401',
        );
      case 403:
        return const AppException(
          AppErrorKind.unauthenticated,
          debugDetail: 'HTTP 403',
        );
      case 404:
        return const AppException(
          AppErrorKind.modelUnavailable,
          debugDetail: 'HTTP 404',
        );
      case 408:
        return const AppException(
          AppErrorKind.timeout,
          debugDetail: 'HTTP 408',
        );
      case 413:
        return const AppException(
          AppErrorKind.imageTooLarge,
          debugDetail: 'HTTP 413',
        );
      case 429:
        return const AppException(
          AppErrorKind.rateLimited,
          debugDetail: 'HTTP 429',
          retryAfter: Duration(seconds: 30),
        );
      default:
        if (status >= 500) {
          return AppException(
            AppErrorKind.providerUnavailable,
            debugDetail: 'HTTP $status',
          );
        }
        return AppException(AppErrorKind.unknown, debugDetail: 'HTTP $status');
    }
  }

  static AppException fromException(Object error) {
    if (error is AppException) return error;
    if (error is TimeoutException) {
      return const AppException(AppErrorKind.timeout);
    }
    if (error is SocketException) {
      return const AppException(AppErrorKind.noConnection);
    }
    if (error is HttpException) {
      return const AppException(AppErrorKind.providerUnavailable);
    }
    if (error is PlatformException) {
      return AppException(AppErrorKind.unknown, debugDetail: error.code);
    }
    return AppException(AppErrorKind.unknown, cause: error);
  }

  /// Localized, user-safe message. Raw exception text is never included.
  static String message(AppLocalizations l10n, AppException e) {
    switch (e.kind) {
      case AppErrorKind.noConnection:
        return l10n.errorNoConnection;
      case AppErrorKind.timeout:
        return l10n.errorTimeout;
      case AppErrorKind.permissionDenied:
        return l10n.errorPermissionDenied;
      case AppErrorKind.permissionPermanentlyDenied:
        return l10n.errorPermissionPermanentlyDenied;
      case AppErrorKind.locationServicesDisabled:
        return l10n.errorLocationServicesDisabled;
      case AppErrorKind.authExpired:
        return l10n.errorAuthExpired;
      case AppErrorKind.unauthenticated:
        return l10n.errorUnauthenticated;
      case AppErrorKind.invalidCredentials:
        return l10n.errorInvalidCredentials;
      case AppErrorKind.rateLimited:
        return l10n.errorRateLimited;
      case AppErrorKind.invalidInput:
        return l10n.errorInvalidInput;
      case AppErrorKind.imageTooLarge:
        return l10n.errorImageTooLarge;
      case AppErrorKind.contentBlocked:
        return l10n.errorContentBlocked;
      case AppErrorKind.modelUnavailable:
        return l10n.errorModelUnavailable;
      case AppErrorKind.malformedResponse:
        return l10n.errorMalformedResponse;
      case AppErrorKind.providerUnavailable:
        return l10n.errorProviderUnavailable;
      case AppErrorKind.notFound:
        return l10n.errorNotFound;
      case AppErrorKind.unknown:
        return l10n.errorUnknown;
    }
  }
}
