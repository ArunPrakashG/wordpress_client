import 'package:dio/dio.dart';

import '../../wordpress_client.dart';

/// Generic contract for fluent request builders layered on top of existing IRequest implementations.
///
/// This interface is operation-agnostic; concrete builders expose `execute()` returning
/// the appropriate response type.
abstract interface class IQueryBuilder<TSelf extends IQueryBuilder<TSelf>> {
  /// Add or override a single header.
  TSelf header(String key, Object value);

  /// Add or override multiple headers.
  TSelf headers(Map<String, Object?> headers);

  /// Add or override a single query parameter.
  TSelf query(String key, Object? value);

  /// Add or override multiple query parameters.
  TSelf queries(Map<String, Object?> params);

  /// Add or override custom extras to be merged into the body/query (request-specific semantics).
  TSelf extra(String key, Object? value);

  /// Add or override multiple extras.
  TSelf extras(Map<String, Object?> values);

  /// Override request body (for create/update/custom scenarios).
  TSelf body(Object? body);

  /// Override cancel token.
  TSelf cancelToken(CancelToken token);

  /// Override per-request authorization.
  TSelf authorization(IAuthorization auth);

  /// Force requireAuth flag (true/false).
  TSelf requireAuth(bool value);

  /// Override timeouts.
  TSelf timeouts({Duration? send, Duration? receive});

  /// Attach events hook.
  TSelf onEvents(WordpressEvents events);

  /// Attach or override a custom response validator.
  TSelf validator(ValidatorCallback validator);

  // --- Common list/query helpers ---

  /// Shortcut for `page` query parameter.
  TSelf withPage(int page);

  /// Shortcut for `per_page` query parameter.
  TSelf withPerPage(int perPage);

  /// Shortcut for `search` query parameter.
  TSelf withSearch(String term);

  /// Shortcut for `order` query parameter (asc/desc).
  TSelf withOrder(Order order);

  /// Shortcut for `orderby` query parameter.
  TSelf withOrderBy(String field);

  /// Shortcut for `context` parameter where applicable.
  TSelf withContext(RequestContext context);

  /// Shortcut for `password` parameter where applicable.
  TSelf withPassword(String password);

  /// Date filters
  TSelf withAfter(DateTime date);
  TSelf withBefore(DateTime date);
  TSelf withModifiedAfter(DateTime date);
  TSelf withModifiedBefore(DateTime date);

  /// Include/Exclude by ids
  TSelf withInclude(List<int> ids);
  TSelf withExclude(List<int> ids);

  /// Authors
  TSelf withAuthor(List<int> authorIds);
  TSelf withAuthorExclude(List<int> authorIds);

  /// Offset
  TSelf withOffset(int offset);

  /// Tax relation
  TSelf withTaxRelation(String relation);

  /// Category/Tag filters
  TSelf withCategories(List<int> ids);
  TSelf withCategoriesExclude(List<int> ids);
  TSelf withTags(List<int> ids);
  TSelf withTagsExclude(List<int> ids);

  /// Sticky flag (posts)
  TSelf withSticky(bool sticky);

  /// Slugs
  TSelf withSlug(List<String> slugs);

  /// Post/Page/Media/User status filters
  TSelf withStatus(List<ContentStatus> statuses);

  /// Search in specific columns (where supported)
  TSelf withSearchColumns(List<String> columns);
}
