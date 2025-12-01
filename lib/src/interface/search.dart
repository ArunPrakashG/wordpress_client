import '../library_exports.dart';

/// Represents the search interface for interacting with WordPress search functionality.
///
/// This interface provides methods for searching content across a WordPress site.
///
/// Example usage:
///
/// ```dart
/// final wordpress = WordpressClient(baseUrl: 'https://your-wordpress-site.com/wp-json');
/// final searchInterface = wordpress.search;
///
/// // Perform a search
/// final searchResults = await searchInterface.list(ListSearchRequest(
///   search: 'example query',
///   perPage: 10,
///   page: 1,
/// ));
///
/// // Process search results
/// for (var result in searchResults) {
///   print('Title: ${result.title}');
///   print('Type: ${result.type}');
///   print('URL: ${result.url}');
/// }
/// ```
///
/// The SearchInterface uses the ListOperation to perform searches, returning
/// a list of Search objects that match the given criteria.
final class SearchInterface extends IRequestInterface
    with ListOperation<Search, ListSearchRequest> {}
