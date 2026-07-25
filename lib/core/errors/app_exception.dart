/// Typed application errors. The [kind] drives localized, actionable messaging
/// in the UI while the (never-shown-to-user) [debugDetail] aids logging.
enum AppErrorKind {
  noConnection,
  timeout,
  permissionDenied,
  permissionPermanentlyDenied,
  locationServicesDisabled,
  authExpired,
  unauthenticated,
  invalidCredentials,
  rateLimited,
  invalidInput,
  imageTooLarge,
  contentBlocked,
  modelUnavailable,
  malformedResponse,
  providerUnavailable,
  notFound,
  unknown,
}

class AppException implements Exception {
  const AppException(
    this.kind, {
    this.debugDetail,
    this.retryAfter,
    this.cause,
  });

  final AppErrorKind kind;

  /// Internal detail for logs only — never surfaced verbatim to end users.
  final String? debugDetail;

  /// For rate-limited errors, when the caller may retry.
  final Duration? retryAfter;

  final Object? cause;

  bool get isRetryable => const {
        AppErrorKind.noConnection,
        AppErrorKind.timeout,
        AppErrorKind.rateLimited,
        AppErrorKind.providerUnavailable,
      }.contains(kind);

  @override
  String toString() => 'AppException($kind, detail=$debugDetail)';
}
