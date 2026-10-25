import 'dart:async';

import '../../wordpress_client.dart';

/// Represents the list operation for WordPress API requests.
///
/// This mixin provides methods to retrieve lists of resources using the WordPress API.
/// It is generic over the type [T] of the response data and [R] which extends [IRequest].
base mixin ListOperation<T, R extends IRequest> on IRequestInterface {
  /// Retrieves a list of resources using the provided [request].
  ///
  /// This method sends a list request to the WordPress API and returns
  /// a [WordpressResponse] containing a list of resources of type [T].
  ///
  /// [request] is an instance of [R] that contains the necessary parameters for the list operation,
  /// such as pagination, filtering, or sorting options.
  ///
  /// Returns a [Future] that resolves to a [WordpressResponse<List<T>>].
  Future<WordpressResponse<List<T>>> list(
    R request,
  ) async {
    final wpRequest = await request.build(baseUrl);

    return executor.list<T>(wpRequest);
  }

  /// Walks every page of [request] and emits one response per page.
  ///
  /// Pages are fetched lazily, one at a time, as the stream is listened to, so
  /// cancelling the subscription stops further requests. The page and page size
  /// of [request] are replaced: iteration starts at [startPage] and asks for
  /// [perPage] items (WordPress caps this at 100).
  ///
  /// The stream ends after the last page, which is read from the
  /// `X-WP-TotalPages` header (or, when the server omits it, the first page
  /// that comes back shorter than [perPage]). At most [maxPages] pages are
  /// fetched. A failed page is emitted as a failure response and ends the
  /// stream.
  ///
  /// ```dart
  /// await for (final page in client.posts.listPages(ListPostRequest())) {
  ///   if (page is WordpressSuccessResponse<List<Post>>) {
  ///     print(page.data.length);
  ///   }
  /// }
  /// ```
  Stream<WordpressResponse<List<T>>> listPages(
    R request, {
    int startPage = 1,
    int perPage = 100,
    int? maxPages,
  }) async* {
    final base = await request.build(baseUrl);

    yield* walkPages<T>(
      (page, size) => executor.list<T>(
        base.copyWith(
          queryParameters: <String, dynamic>{
            ...?base.queryParameters,
            'page': page,
            'per_page': size,
          },
        ),
      ),
      startPage: startPage,
      perPage: perPage,
      maxPages: maxPages,
    );
  }

  /// Fetches every page of [request] and returns all items in one list.
  ///
  /// This is [listPages] collected into a single response. The result keeps
  /// the headers of the first page (so [WordpressSuccessResponse.totalCount]
  /// is the full result size) and the summed duration. Its raw data is null. The first failed page
  /// aborts and is returned as is; items already fetched are discarded.
  ///
  /// [maxItems] stops fetching once that many items were collected and trims
  /// the result to it. Use it as a safety valve on large sites.
  Future<WordpressResponse<List<T>>> listAll(
    R request, {
    int perPage = 100,
    int? maxPages,
    int? maxItems,
  }) async {
    return collectPages<T>(
      listPages(request, perPage: perPage, maxPages: maxPages),
      maxItems: maxItems,
    );
  }

  /// Retrieves a list of resources and returns the raw response for the given [request].
  ///
  /// This method is similar to [list], but instead of parsing the response,
  /// it returns the raw response from the WordPress API.
  ///
  /// [request] is an instance of [R] that contains the necessary parameters for the list operation.
  ///
  /// Returns a [Future] that resolves to a [WordpressRawResponse].
  /// This can be useful for debugging or when you need access to the full, unprocessed API response.
  Future<WordpressRawResponse> listRaw(
    R request,
  ) async {
    final wpRequest = await request.build(baseUrl);

    return executor.raw(wpRequest);
  }
}

/// Fetches pages through [fetch] until the last one, lazily.
///
/// Stops at the first failure (after yielding it), at `X-WP-TotalPages`, when
/// a page comes back shorter than [perPage], or after [maxPages] pages.
Stream<WordpressResponse<List<T>>> walkPages<T>(
  Future<WordpressResponse<List<T>>> Function(int page, int perPage) fetch, {
  int startPage = 1,
  int perPage = 100,
  int? maxPages,
}) async* {
  assert(startPage >= 1, 'startPage must be at least 1');
  assert(perPage >= 1, 'perPage must be at least 1');
  assert(maxPages == null || maxPages >= 1, 'maxPages must be at least 1');

  var fetched = 0;

  for (var page = startPage;; page++) {
    final response = await fetch(page, perPage);

    yield response;
    fetched++;

    if (response is! WordpressSuccessResponse<List<T>>) {
      return;
    }

    final totalPages = response.totalPagesCount;
    final isLast =
        totalPages > 0 ? page >= totalPages : response.data.length < perPage;

    if (isLast || (maxPages != null && fetched >= maxPages)) {
      return;
    }
  }
}

/// Collects the [pages] of [walkPages] into one response (see
/// `ListOperation.listAll`).
Future<WordpressResponse<List<T>>> collectPages<T>(
  Stream<WordpressResponse<List<T>>> pages, {
  int? maxItems,
}) async {
  assert(maxItems == null || maxItems >= 1, 'maxItems must be at least 1');

  final items = <T>[];
  WordpressSuccessResponse<List<T>>? first;
  var duration = Duration.zero;

  await for (final page in pages) {
    if (page is! WordpressSuccessResponse<List<T>>) {
      return page;
    }

    first ??= page;
    duration += page.duration;
    items.addAll(page.data);

    if (maxItems != null && items.length >= maxItems) {
      break;
    }
  }

  final head = first!;
  final data = maxItems != null && items.length > maxItems
      ? items.sublist(0, maxItems)
      : items;

  return WordpressSuccessResponse<List<T>>(
    headers: head.headers,
    duration: duration,
    data: data,
    rawData: null,
    requestHeaders: head.requestHeaders,
    code: head.code,
    extra: head.extra,
    message: head.message,
  );
}
