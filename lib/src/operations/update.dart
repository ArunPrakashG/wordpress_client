import '../../wordpress_client.dart';

/// Represents the update operation for WordPress API requests.
///
/// This mixin provides methods to perform update operations on WordPress resources.
/// It is designed to be used with classes that implement [IRequestInterface].
base mixin UpdateOperation<T, R extends IRequest> on IRequestInterface {
  /// [WordpressError.code] of the failure [updateIfUnmodified] returns when
  /// the item changed on the server (HTTP status 409).
  static const String conflictErrorCode = 'wp_client_conflict';

  /// [WordpressError.code] of the failure [updateIfUnmodified] returns when
  /// the item has no `modified_gmt` to compare (HTTP status 412).
  static const String noModifiedErrorCode = 'wp_client_no_modified_gmt';

  /// Performs an update operation using the provided [request].
  ///
  /// [T] is the type of the expected response data.
  /// [R] is the type of the request, which must extend [IRequest].
  ///
  /// Returns a [Future] that resolves to a [WordpressResponse<T>] containing
  /// the updated resource data.
  Future<WordpressResponse<T>> update(R request) async {
    final wpRequest = await request.build(baseUrl);

    return executor.update<T>(wpRequest);
  }

  /// Updates only if the item is unchanged on the server since
  /// [lastModifiedGmt], normally the `modifiedGmt` of the copy being edited.
  ///
  /// When someone else saved the item in the meantime nothing is sent, and a
  /// failure with status 409 and error code [conflictErrorCode] is returned
  /// instead of silently overwriting their edit:
  ///
  /// ```dart
  /// final response = await client.posts.updateIfUnmodified(
  ///   UpdatePostRequest(id: post.id, title: 'New title'),
  ///   lastModifiedGmt: post.modifiedGmt!,
  /// );
  /// if (response case WordpressFailureResponse(:final error?)
  ///     when error.code == UpdateOperation.conflictErrorCode) {
  ///   // Reload, merge and try again.
  /// }
  /// ```
  ///
  /// The check reads the item's current `modified_gmt` first (one small GET
  /// that bypasses `CacheMiddleware`). WordPress has no conditional update,
  /// so an edit landing between that read and the update is not detected.
  /// Items without `modified_gmt` (terms, users) fail with
  /// [noModifiedErrorCode].
  Future<WordpressResponse<T>> updateIfUnmodified(
    R request, {
    required DateTime lastModifiedGmt,
  }) async {
    final wpRequest = await request.build(baseUrl);
    final current = await executor.raw(
      WordpressRequest(
        url: wpRequest.url,
        method: HttpMethod.get,
        queryParameters: const {'_fields': 'modified_gmt', 'context': 'edit'},
        headers: wpRequest.headers,
        requireAuth: wpRequest.requireAuth,
        authorization: wpRequest.authorization,
        cancelToken: wpRequest.cancelToken,
        sendTimeout: wpRequest.sendTimeout,
        receiveTimeout: wpRequest.receiveTimeout,
        extra: const {WordpressRequest.metaSkipCache: true},
      ),
    );

    WordpressResponse<T> fail(int status, String code, String message) {
      return WordpressRawResponse(
        data: {
          'code': code,
          'message': message,
          'data': {'status': status},
        },
        code: status,
        headers: current.headers,
        duration: current.duration,
      ).asResponse<T>(decoder: (_) => throw StateError('unreachable'));
    }

    if (current.isFailure) {
      return current.asResponse<T>(
        decoder: (_) => throw StateError('unreachable'),
      );
    }

    final data = current.data;
    final serverModified = data is Map ? data['modified_gmt'] : null;
    if (serverModified is! String ||
        DateTime.tryParse(serverModified) == null) {
      return fail(
        412,
        noModifiedErrorCode,
        'The item has no modified_gmt, so it cannot be checked for changes.',
      );
    }

    if (!_sameWallClock(DateTime.parse(serverModified), lastModifiedGmt)) {
      return fail(
        409,
        conflictErrorCode,
        'The item was modified on the server at $serverModified (GMT).',
      );
    }

    return executor.update<T>(wpRequest);
  }

  /// `modified_gmt` has no zone suffix, so models hold it as a local
  /// [DateTime] with GMT digits. Compare the digits, whatever the zone flag.
  static bool _sameWallClock(DateTime a, DateTime b) {
    DateTime digits(DateTime d) => DateTime.utc(
          d.year,
          d.month,
          d.day,
          d.hour,
          d.minute,
          d.second,
        );

    return digits(a) == digits(b);
  }

  /// Performs an update operation and returns the raw response for the given [request].
  ///
  /// This method is useful when you need access to the full, unprocessed API response.
  ///
  /// Returns a [Future] that resolves to a [WordpressRawResponse] containing
  /// the raw API response data.
  Future<WordpressRawResponse> updateRaw(R request) async {
    final wpRequest = await request.build(baseUrl);

    return executor.raw(wpRequest);
  }
}
