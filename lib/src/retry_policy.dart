import 'dart:math';

import 'package:meta/meta.dart';

import 'enums.dart';

/// Controls automatic retries of transient failures.
///
/// Retries are off by default ([RetryPolicy.none]). Enable them for a client
/// with `BootstrapBuilder.withRetryPolicy`, or for a single request through
/// `WordpressRequest.retryPolicy`:
///
/// ```dart
/// final client = WordpressClient(
///   baseUrl: Uri.parse('https://example.com/wp-json/wp/v2'),
///   bootstrapper: (b) => b.withRetryPolicy(const RetryPolicy.standard()).build(),
/// );
/// ```
///
/// Only idempotent methods are retried unless [methods] says otherwise, so a
/// failed `POST` is never sent twice by accident.
@immutable
final class RetryPolicy {
  /// Creates a policy. [maxAttempts] counts the first try, so `3` means one
  /// initial request plus up to two retries.
  const RetryPolicy({
    this.maxAttempts = 3,
    this.baseDelay = const Duration(milliseconds: 500),
    this.maxDelay = const Duration(seconds: 10),
    this.jitter = true,
    this.statusCodes = const {429, 502, 503, 504},
    this.methods = const {
      HttpMethod.get,
      HttpMethod.head,
      HttpMethod.options,
      HttpMethod.put,
      HttpMethod.delete,
    },
    this.retryOnNetworkError = true,
    this.honorRetryAfter = true,
    this.maxRetryAfter = const Duration(seconds: 30),
    this.sleep,
  }) : assert(maxAttempts >= 1, 'maxAttempts must be at least 1');

  /// Three attempts, exponential backoff from 500 ms, `Retry-After` honoured.
  const RetryPolicy.standard() : this();

  /// Never retry. This is the default.
  static const RetryPolicy none = RetryPolicy(maxAttempts: 1);

  /// Total number of tries, including the first.
  final int maxAttempts;

  /// Delay before the first retry; doubled for each following retry.
  final Duration baseDelay;

  /// Upper bound for the computed backoff delay.
  final Duration maxDelay;

  /// Randomise each delay between 50% and 100% of its computed value, so
  /// many clients do not retry in lockstep.
  final bool jitter;

  /// HTTP statuses that are worth retrying.
  final Set<int> statusCodes;

  /// HTTP methods that may be retried. `POST` and `PATCH` are not included by
  /// default because repeating them can duplicate side effects.
  final Set<HttpMethod> methods;

  /// Retry timeouts and connection errors (never cancellations).
  final bool retryOnNetworkError;

  /// Wait as long as the `Retry-After` response header asks for.
  final bool honorRetryAfter;

  /// If the server asks to wait longer than this, give up instead of waiting.
  final Duration maxRetryAfter;

  /// Replaces `Future.delayed` for waiting. Intended for tests.
  final Future<void> Function(Duration delay)? sleep;

  /// Whether this policy ever retries.
  bool get enabled => maxAttempts > 1;

  /// How long to wait before retry number [attempt] (1 for the first retry).
  ///
  /// Returns null when the request should not be retried, which happens when
  /// the server's `Retry-After` exceeds [maxRetryAfter].
  Duration? nextDelay(int attempt, {Duration? retryAfter, Random? random}) {
    if (honorRetryAfter && retryAfter != null) {
      return retryAfter > maxRetryAfter ? null : retryAfter;
    }

    final exponent = min(attempt - 1, 20);
    final raw = baseDelay * pow(2, exponent).toInt();
    final capped = raw > maxDelay ? maxDelay : raw;

    if (!jitter) {
      return capped;
    }

    final factor = 0.5 + (random ?? Random()).nextDouble() * 0.5;

    return Duration(microseconds: (capped.inMicroseconds * factor).round());
  }

  /// Parses a `Retry-After` header (delta-seconds or an HTTP date).
  ///
  /// Returns null when the value is missing or unparsable.
  static Duration? parseRetryAfter(String? value, {DateTime? now}) {
    final text = value?.trim();
    if (text == null || text.isEmpty) {
      return null;
    }

    final seconds = int.tryParse(text);
    if (seconds != null) {
      return seconds < 0 ? null : Duration(seconds: seconds);
    }

    try {
      final at = _parseHttpDate(text);
      final delta = at.difference((now ?? DateTime.now()).toUtc());

      return delta.isNegative ? Duration.zero : delta;
    } on FormatException {
      return null;
    }
  }

  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  /// Parses the IMF-fixdate form: `Wed, 21 Oct 2026 07:28:00 GMT`.
  static DateTime _parseHttpDate(String text) {
    final match = RegExp(
      r'^[A-Za-z]{3}, (\d{1,2}) ([A-Za-z]{3}) (\d{4}) (\d{2}):(\d{2}):(\d{2}) GMT$',
    ).firstMatch(text);
    final month = match == null ? -1 : _months.indexOf(match.group(2)!) + 1;

    if (match == null || month == 0) {
      throw FormatException('Invalid HTTP date', text);
    }

    return DateTime.utc(
      int.parse(match.group(3)!),
      month,
      int.parse(match.group(1)!),
      int.parse(match.group(4)!),
      int.parse(match.group(5)!),
      int.parse(match.group(6)!),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is RetryPolicy &&
        other.maxAttempts == maxAttempts &&
        other.baseDelay == baseDelay &&
        other.maxDelay == maxDelay &&
        other.jitter == jitter &&
        other.statusCodes.length == statusCodes.length &&
        other.statusCodes.containsAll(statusCodes) &&
        other.methods.length == methods.length &&
        other.methods.containsAll(methods) &&
        other.retryOnNetworkError == retryOnNetworkError &&
        other.honorRetryAfter == honorRetryAfter &&
        other.maxRetryAfter == maxRetryAfter &&
        other.sleep == sleep;
  }

  @override
  int get hashCode => Object.hash(
        maxAttempts,
        baseDelay,
        maxDelay,
        jitter,
        Object.hashAllUnordered(statusCodes),
        Object.hashAllUnordered(methods),
        retryOnNetworkError,
        honorRetryAfter,
        maxRetryAfter,
        sleep,
      );
}
