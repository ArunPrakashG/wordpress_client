import 'package:dio/dio.dart';

import '../../wordpress_client.dart';
import '../utilities/rest_root.dart';

/// How WordPress validates a batch before running it.
enum BatchValidation {
  /// Run every request; failures are reported per request.
  normal('normal'),

  /// Validate all requests first and run none if any would fail validation.
  requireAllValidate('require-all-validate');

  const BatchValidation(this.value);

  /// The value sent in the `validation` field.
  final String value;
}

/// One write inside a batch.
///
/// WordPress batches only accept writes (`POST`, `PUT`, `PATCH`, `DELETE`) on
/// routes that opted in (posts, pages, media, comments, ... in core).
final class BatchOperation {
  /// A request with an explicit [method] and [path].
  ///
  /// A [path] starting with `/` is used as is (`/wp/v2/posts`); any other is
  /// relative to `/wp/v2/`.
  const BatchOperation(this.method, this.path, {this.body, this.headers});

  /// Creates an item: `POST /wp/v2/<resource>`.
  const BatchOperation.create(String resource, {Map<String, dynamic>? body})
      : this(HttpMethod.post, resource, body: body);

  /// Updates an item: `POST /wp/v2/<resource>/<id>`.
  BatchOperation.update(
    String resource,
    Object id, {
    Map<String, dynamic>? body,
  }) : this(HttpMethod.post, '$resource/$id', body: body);

  /// Deletes an item: `DELETE /wp/v2/<resource>/<id>`.
  BatchOperation.delete(String resource, Object id, {bool force = false})
      : this(
          HttpMethod.delete,
          '$resource/$id',
          body: force ? const {'force': true} : null,
        );

  /// HTTP method of the inner request.
  final HttpMethod method;

  /// Route of the inner request.
  final String path;

  /// JSON body of the inner request.
  final Map<String, dynamic>? body;

  /// Extra headers of the inner request.
  final Map<String, String>? headers;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'method': method.name.toUpperCase(),
      'path': path.startsWith('/') ? path : '/wp/v2/$path',
      if (body != null) 'body': body,
      if (headers != null) 'headers': headers,
    };
  }
}

/// The answer to one [BatchOperation].
final class BatchItemResult {
  /// Creates a result.
  const BatchItemResult({
    required this.status,
    required this.body,
    this.headers = const {},
  });

  /// Reads one entry of the `responses` array.
  factory BatchItemResult.fromJson(Map<String, dynamic> json) {
    final headers = json['headers'];

    return BatchItemResult(
      status: json['status'] is int ? json['status'] as int : 0,
      body: json['body'],
      headers: headers is Map
          ? {for (final e in headers.entries) '${e.key}': e.value}
          : const <String, dynamic>{},
    );
  }

  /// HTTP status of the inner response.
  final int status;

  /// Decoded JSON body (a map for an item, or a WordPress error object).
  final dynamic body;

  /// Headers of the inner response.
  final Map<String, dynamic> headers;

  /// `true` for a 2xx status.
  bool get isSuccessful => status >= 200 && status < 300;

  /// The WordPress error of a failed item, if the body is one.
  WordpressError? get error {
    final value = body;
    if (isSuccessful || value is! Map<String, dynamic>) {
      return null;
    }

    return mapGuarded(mapper: WordpressError.fromMap, json: value);
  }

  /// Decodes a successful body with [decoder], or returns `null`.
  T? decode<T>(T Function(Map<String, dynamic> json) decoder) {
    final value = body;
    return isSuccessful && value is Map<String, dynamic>
        ? decoder(value)
        : null;
  }
}

/// The answer to a whole batch.
final class BatchResult {
  /// Creates a result.
  const BatchResult({required this.failed, required this.responses});

  /// `true` when any inner request failed (or validation rejected the batch).
  final bool failed;

  /// One entry per operation, in order.
  final List<BatchItemResult> responses;

  /// The successful entries.
  Iterable<BatchItemResult> get succeeded =>
      responses.where((r) => r.isSuccessful);

  /// The failed entries.
  Iterable<BatchItemResult> get failures =>
      responses.where((r) => !r.isSuccessful);
}

/// Runs many writes in one HTTP request (`/wp-json/batch/v1`, WordPress 5.6+).
///
/// ```dart
/// final result = await client.batch.run([
///   BatchOperation.create('posts', body: {'title': 'A', 'status': 'draft'}),
///   BatchOperation.update('posts', 12, body: {'title': 'B'}),
///   BatchOperation.delete('posts', 13, force: true),
/// ]);
/// print(result.failed);
/// ```
final class BatchInterface extends IRequestInterface {
  /// WordPress rejects batches larger than this (25 unless a plugin raises it).
  static const defaultMaxBatchSize = 25;

  Uri get _endpoint => restRoot(baseUrl, 'batch/v1');

  /// Sends [operations], splitting them into requests of at most [chunkSize]
  /// (WordPress' default limit is 25). Chunks run one after another; the
  /// results are concatenated in order.
  ///
  /// With [BatchValidation.requireAllValidate] a validation problem rejects
  /// the whole chunk it is in, not the whole list.
  ///
  /// A transport or authorization failure is returned as a failure response.
  Future<WordpressResponse<BatchResult>> run(
    List<BatchOperation> operations, {
    BatchValidation validation = BatchValidation.normal,
    int chunkSize = defaultMaxBatchSize,
    CancelToken? cancelToken,
  }) async {
    if (operations.isEmpty) {
      throw ArgumentError.value(operations, 'operations', 'Must not be empty.');
    }
    if (chunkSize < 1) {
      throw ArgumentError.value(chunkSize, 'chunkSize', 'Must be at least 1.');
    }

    final all = <BatchItemResult>[];
    var failed = false;
    WordpressRawResponse? last;

    for (var i = 0; i < operations.length; i += chunkSize) {
      final chunk = operations.skip(i).take(chunkSize).toList();

      final raw = await executor.raw(
        WordpressRequest(
          method: HttpMethod.post,
          url: RequestUrl.absolute(_endpoint),
          body: {
            'validation': validation.value,
            'requests': chunk.map((o) => o.toJson()).toList(),
          },
          requireAuth: true,
          cancelToken: cancelToken,
        ),
      );
      last = raw;

      final data = raw.data;
      if (raw.isFailure || data is! Map<String, dynamic>) {
        return raw.asResponse<BatchResult>(
          decoder: (_) => const BatchResult(failed: true, responses: []),
        );
      }

      failed = failed || data['failed'] == true;
      final responses = data['responses'];
      if (responses is List) {
        all.addAll(
          responses.whereType<Map<String, dynamic>>().map(
                BatchItemResult.fromJson,
              ),
        );
      }
    }

    return last!.asResponse<BatchResult>(
      decoder: (_) => BatchResult(failed: failed, responses: all),
    );
  }
}
