import 'package:dio/dio.dart';

import '../../wordpress_client.dart';

/// Base class shared by all fluent builders; stores per-request overrides and composes an
/// existing IRequest using a provided factory.
abstract base class BaseQueryBuilder<TSelf extends BaseQueryBuilder<TSelf, R>,
    R extends IRequest> implements IQueryBuilder<TSelf> {
  BaseQueryBuilder({
    required this.interface,
    required this.seed,
  });

  final IRequestInterface interface;
  final R seed;

  /// Advanced: access to the underlying seed request instance.
  /// You can mutate fields directly if you need parameters not covered by
  /// the fluent helpers. Prefer [configureSeed] for scoped mutation when possible.
  R get seedRequest => seed;

  final Map<String, String> _headers = <String, String>{};
  final Map<String, dynamic> _query = <String, dynamic>{};
  final Map<String, dynamic> _extra = <String, dynamic>{};
  Object? _body;
  CancelToken? _cancelToken;
  IAuthorization? _authorization;
  bool? _requireAuth;
  Duration? _sendTimeout;
  Duration? _receiveTimeout;
  WordpressEvents? _events;
  ValidatorCallback? _validator;

  @override
  TSelf header(String key, Object value) {
    _headers[key] = value.toString();
    return this as TSelf;
  }

  @override
  TSelf headers(Map<String, Object?> headers) {
    headers.forEach((k, v) {
      if (v != null) _headers[k] = v.toString();
    });
    return this as TSelf;
  }

  @override
  TSelf query(String key, Object? value) {
    if (value != null) _query[key] = value;
    return this as TSelf;
  }

  @override
  TSelf queries(Map<String, Object?> params) {
    params.forEach((k, v) {
      if (v != null) _query[k] = v;
    });
    return this as TSelf;
  }

  @override
  TSelf extra(String key, Object? value) {
    _extra[key] = value;
    return this as TSelf;
  }

  @override
  TSelf extras(Map<String, Object?> values) {
    values.forEach((k, v) => _extra[k] = v);
    return this as TSelf;
  }

  @override
  TSelf body(Object? body) {
    _body = body;
    return this as TSelf;
  }

  @override
  TSelf cancelToken(CancelToken token) {
    _cancelToken = token;
    return this as TSelf;
  }

  @override
  TSelf authorization(IAuthorization auth) {
    _authorization = auth;
    return this as TSelf;
  }

  @override
  TSelf requireAuth(bool value) {
    _requireAuth = value;
    return this as TSelf;
  }

  @override
  TSelf timeouts({Duration? send, Duration? receive}) {
    _sendTimeout = send;
    _receiveTimeout = receive;
    return this as TSelf;
  }

  @override
  TSelf onEvents(WordpressEvents events) {
    _events = events;
    return this as TSelf;
  }

  @override
  TSelf validator(ValidatorCallback validator) {
    _validator = validator;
    return this as TSelf;
  }

  /// Allows typed, request-specific configuration by mutating the seed instance.
  /// Useful for setting fields that don't have generic helpers.
  TSelf configureSeed(void Function(R seed) configure) {
    configure(seed);
    return this as TSelf;
  }

  // Common helpers
  @override
  TSelf withPage(int page) => query('page', page);

  @override
  TSelf withPerPage(int perPage) => query('per_page', perPage);

  @override
  TSelf withSearch(String term) => query('search', term);

  @override
  TSelf withOrder(Order order) => query('order', order.name);

  @override
  TSelf withOrderBy(String field) => query('orderby', field);

  @override
  TSelf withContext(RequestContext context) => query('context', context.name);

  @override
  TSelf withPassword(String password) => query('password', password);

  @override
  TSelf withAfter(DateTime date) => query('after', date.toIso8601String());

  @override
  TSelf withBefore(DateTime date) => query('before', date.toIso8601String());

  @override
  TSelf withModifiedAfter(DateTime date) =>
      query('modified_after', date.toIso8601String());

  @override
  TSelf withModifiedBefore(DateTime date) =>
      query('modified_before', date.toIso8601String());

  @override
  TSelf withInclude(List<int> ids) => query('include', ids.join(','));

  @override
  TSelf withExclude(List<int> ids) => query('exclude', ids.join(','));

  @override
  TSelf withAuthor(List<int> authorIds) => query('author', authorIds.join(','));

  @override
  TSelf withAuthorExclude(List<int> authorIds) =>
      query('author_exclude', authorIds.join(','));

  @override
  TSelf withOffset(int offset) => query('offset', offset);

  @override
  TSelf withTaxRelation(String relation) => query('tax_relation', relation);

  @override
  TSelf withCategories(List<int> ids) => query('categories', ids.join(','));

  @override
  TSelf withCategoriesExclude(List<int> ids) =>
      query('categories_exclude', ids.join(','));

  @override
  TSelf withTags(List<int> ids) => query('tags', ids.join(','));

  @override
  TSelf withTagsExclude(List<int> ids) => query('tags_exclude', ids.join(','));

  @override
  TSelf withSticky(bool sticky) => query('sticky', sticky);

  @override
  TSelf withSlug(List<String> slugs) => query('slug', slugs.join(','));

  @override
  TSelf withStatus(List<ContentStatus> statuses) =>
      query('status', statuses.map((e) => e.name).join(','));

  @override
  TSelf withSearchColumns(List<String> columns) =>
      query('search_columns', columns.join(','));

  Future<WordpressRequest> _buildWordpressRequest() async {
    // Build from seed, then overlay fluent overrides using copyWith
    final base = await seed.build(interface.baseUrl);

    final mergedHeaders = <String, dynamic>{}
      ..addAll(base.headers ?? const {})
      ..addAll(_headers);
    final mergedQuery = <String, dynamic>{}
      ..addAll(base.queryParameters ?? const {})
      ..addAll(_query);
    var mergedBody = _body ?? base.body;

    // Apply extras: if body is a Map, merge into body; otherwise merge into query.
    if (_extra.isNotEmpty) {
      if (mergedBody is Map<String, dynamic>) {
        mergedBody = <String, dynamic>{}
          ..addAll(mergedBody)
          ..addAll(_extra);
      } else {
        // Merge extras into the effective query params
        mergedQuery.addAll(_extra);
      }
    }

    return base.copyWith(
      headers: mergedHeaders.isEmpty ? null : mergedHeaders,
      queryParameters: mergedQuery.isEmpty ? null : mergedQuery,
      body: mergedBody,
      cancelToken: _cancelToken ?? base.cancelToken,
      authorization: _authorization ?? base.authorization,
      requireAuth: _requireAuth ?? base.requireAuth,
      sendTimeout: _sendTimeout ?? base.sendTimeout,
      receiveTimeout: _receiveTimeout ?? base.receiveTimeout,
      events: _events ?? base.events,
      validator: _validator ?? base.validator,
    );
  }
}

/// Builder for list operations: returns List<T>.
final class ListQueryBuilder<T, R extends IRequest>
    extends BaseQueryBuilder<ListQueryBuilder<T, R>, R> {
  ListQueryBuilder({
    required super.interface,
    required super.seed,
    required Future<WordpressResponse<List<T>>> Function(WordpressRequest)
        executor,
  }) : _executor = executor;

  final Future<WordpressResponse<List<T>>> Function(WordpressRequest) _executor;

  Future<WordpressResponse<List<T>>> execute() async {
    final req = await _buildWordpressRequest();
    return _executor(req);
  }
}

/// Builder for retrieve operations: returns T.
final class RetrieveQueryBuilder<T, R extends IRequest>
    extends BaseQueryBuilder<RetrieveQueryBuilder<T, R>, R> {
  RetrieveQueryBuilder({
    required super.interface,
    required super.seed,
    required Future<WordpressResponse<T>> Function(WordpressRequest) executor,
  }) : _executor = executor;

  final Future<WordpressResponse<T>> Function(WordpressRequest) _executor;

  Future<WordpressResponse<T>> execute() async {
    final req = await _buildWordpressRequest();
    return _executor(req);
  }
}

/// Builder for create/update operations: returns T.
final class MutateQueryBuilder<T, R extends IRequest>
    extends BaseQueryBuilder<MutateQueryBuilder<T, R>, R> {
  MutateQueryBuilder({
    required super.interface,
    required super.seed,
    required Future<WordpressResponse<T>> Function(WordpressRequest) executor,
  }) : _executor = executor;

  final Future<WordpressResponse<T>> Function(WordpressRequest) _executor;

  Future<WordpressResponse<T>> execute() async {
    final req = await _buildWordpressRequest();
    return _executor(req);
  }
}

/// Builder for delete operations: returns bool.
final class DeleteQueryBuilder<R extends IRequest>
    extends BaseQueryBuilder<DeleteQueryBuilder<R>, R> {
  DeleteQueryBuilder({
    required super.interface,
    required super.seed,
    required Future<WordpressResponse<bool>> Function(WordpressRequest)
        executor,
  }) : _executor = executor;

  final Future<WordpressResponse<bool>> Function(WordpressRequest) _executor;

  Future<WordpressResponse<bool>> execute() async {
    final req = await _buildWordpressRequest();
    return _executor(req);
  }
}

// Top-level factory helpers (no methods added to interface)
ListQueryBuilder<T, R> listQuery<T, R extends IRequest>({
  required IRequestInterface interface,
  required R seed,
}) {
  return ListQueryBuilder<T, R>(
    interface: interface,
    seed: seed,
    executor: (wp) => interface.executor.list<T>(wp),
  );
}

RetrieveQueryBuilder<T, R> retrieveQuery<T, R extends IRequest>({
  required IRequestInterface interface,
  required R seed,
}) {
  return RetrieveQueryBuilder<T, R>(
    interface: interface,
    seed: seed,
    executor: (wp) => interface.executor.retrive<T>(wp),
  );
}

MutateQueryBuilder<T, R> createQuery<T, R extends IRequest>({
  required IRequestInterface interface,
  required R seed,
}) {
  return MutateQueryBuilder<T, R>(
    interface: interface,
    seed: seed,
    executor: (wp) => interface.executor.create<T>(wp),
  );
}

MutateQueryBuilder<T, R> updateQuery<T, R extends IRequest>({
  required IRequestInterface interface,
  required R seed,
}) {
  return MutateQueryBuilder<T, R>(
    interface: interface,
    seed: seed,
    executor: (wp) => interface.executor.update<T>(wp),
  );
}

DeleteQueryBuilder<R> deleteQuery<R extends IRequest>({
  required IRequestInterface interface,
  required R seed,
}) {
  return DeleteQueryBuilder<R>(
    interface: interface,
    seed: seed,
    executor: (wp) => interface.executor.delete(wp),
  );
}
