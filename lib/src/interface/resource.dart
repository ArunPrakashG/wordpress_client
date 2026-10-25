import 'dart:async';

import 'package:dio/dio.dart';

import '../../wordpress_client.dart';
import '../utilities/rest_root.dart';

/// A typed client for any REST collection: a custom post type, a custom
/// taxonomy or a plugin's own endpoint.
///
/// Get one with `client.resource<T>(...)`:
///
/// ```dart
/// final events = client.resource<Event>(
///   'events',
///   decoder: Event.fromJson,
///   encoder: (e) => e.toJson(),
/// );
///
/// final upcoming = await events.list(query: {'status': 'publish'}, perPage: 20);
/// final all = await events.listAll();
/// final one = await events.retrieve(42);
/// await events.create(Event(title: 'Launch'));
/// await events.update(42, {'title': 'Renamed'});
/// await events.delete(42, force: true);
/// ```
///
/// Custom post types registered with `show_in_rest` live under `wp/v2`
/// (their `rest_base` is the collection name). Plugin endpoints pass their own
/// `namespace`, for example `my-plugin/v1`.
final class ResourceInterface<T> extends IRequestInterface {
  /// Use `client.resource<T>(...)` instead of calling this directly.
  ResourceInterface({
    required this.restBase,
    this.namespace = 'wp/v2',
    this.requireAuthForReads = false,
  });

  /// Collection path, e.g. `events` or `events/categories`.
  final String restBase;

  /// REST namespace, `wp/v2` for core-style routes.
  final String namespace;

  /// Send credentials with reads too (needed for private content).
  final bool requireAuthForReads;

  RequestUrl _url([Object? id, String? action]) {
    final parts = <String>[
      ...restBase.split('/').where((s) => s.isNotEmpty),
      if (id != null) '$id',
      if (action != null) action,
    ];

    if (namespace == 'wp/v2') {
      return RequestUrl.relativeParts(parts);
    }

    final root = restRoot(baseUrl, namespace);
    return RequestUrl.absolute(
      root.replace(pathSegments: [...root.pathSegments, ...parts]),
    );
  }

  WordpressRequest _request(
    HttpMethod method, {
    Object? id,
    Map<String, dynamic>? query,
    Object? body,
    bool requireAuth = true,
    CancelToken? cancelToken,
    WordpressEvents? events,
  }) {
    return WordpressRequest(
      method: method,
      url: _url(id),
      queryParameters: query,
      body: body,
      requireAuth: requireAuth,
      cancelToken: cancelToken,
      events: events,
    );
  }

  /// One page of the collection. [query] holds any filter the endpoint
  /// supports (`status`, `search`, `meta_key`, `_embed`, ...).
  Future<WordpressResponse<List<T>>> list({
    int? page,
    int? perPage,
    Map<String, dynamic>? query,
    CancelToken? cancelToken,
    WordpressEvents? events,
  }) {
    return executor.list<T>(
      _request(
        HttpMethod.get,
        query: {
          ...?query,
          if (page != null) 'page': page,
          if (perPage != null) 'per_page': perPage,
        },
        requireAuth: requireAuthForReads,
        cancelToken: cancelToken,
        events: events,
      ),
    );
  }

  /// Walks every page lazily, like `listPages` on the built-in interfaces.
  Stream<WordpressResponse<List<T>>> listPages({
    Map<String, dynamic>? query,
    int perPage = 100,
    int? maxPages,
    CancelToken? cancelToken,
  }) {
    return walkPages<T>(
      (page, size) => list(
        page: page,
        perPage: size,
        query: query,
        cancelToken: cancelToken,
      ),
      perPage: perPage,
      maxPages: maxPages,
    );
  }

  /// Every item of the collection in one response.
  Future<WordpressResponse<List<T>>> listAll({
    Map<String, dynamic>? query,
    int perPage = 100,
    int? maxPages,
    int? maxItems,
    CancelToken? cancelToken,
  }) {
    return collectPages<T>(
      listPages(
        query: query,
        perPage: perPage,
        maxPages: maxPages,
        cancelToken: cancelToken,
      ),
      maxItems: maxItems,
    );
  }

  /// A single item by [id] (or slug-like path segment).
  Future<WordpressResponse<T>> retrieve(
    Object id, {
    Map<String, dynamic>? query,
    CancelToken? cancelToken,
    WordpressEvents? events,
  }) {
    return executor.retrieve<T>(
      _request(
        HttpMethod.get,
        id: id,
        query: query,
        requireAuth: requireAuthForReads,
        cancelToken: cancelToken,
        events: events,
      ),
    );
  }

  /// Creates an item from a model (encoded with the registered encoder) or a
  /// plain JSON map.
  Future<WordpressResponse<T>> create(
    Object data, {
    CancelToken? cancelToken,
    WordpressEvents? events,
  }) async {
    return executor.create<T>(
      _request(
        HttpMethod.post,
        body: _encode(data),
        cancelToken: cancelToken,
        events: events,
      ),
    );
  }

  /// Updates the item [id] with [data] (a model or a JSON map; send only the
  /// fields that change).
  Future<WordpressResponse<T>> update(
    Object id,
    Object data, {
    CancelToken? cancelToken,
    WordpressEvents? events,
  }) async {
    return executor.update<T>(
      _request(
        HttpMethod.post,
        id: id,
        body: _encode(data),
        cancelToken: cancelToken,
        events: events,
      ),
    );
  }

  /// Deletes the item [id]; [force] skips the trash.
  Future<WordpressResponse<bool>> delete(
    Object id, {
    bool force = false,
    CancelToken? cancelToken,
    WordpressEvents? events,
  }) {
    return executor.delete(
      _request(
        HttpMethod.delete,
        id: id,
        query: force ? const {'force': true} : null,
        cancelToken: cancelToken,
        events: events,
      ),
    );
  }

  /// The same request as [list], but returning the raw response.
  Future<WordpressRawResponse> listRaw({
    Map<String, dynamic>? query,
    CancelToken? cancelToken,
  }) {
    return executor.raw(
      _request(
        HttpMethod.get,
        query: query,
        requireAuth: requireAuthForReads,
        cancelToken: cancelToken,
      ),
    );
  }

  Object _encode(Object data) {
    if (data is Map) {
      return data;
    }

    return executor.codableMap.getEncoder<T>()(data);
  }
}
