import '../../library_exports.dart';

extension WordpressClientExtensions on WordpressClient {
  /// Returns a `ParallelWordpress` instance which allows fetching iterable data, such as list of posts etc, in parallel.
  ///
  /// Example usage:
  ///
  /// ```dart
  /// final Iterable<ParallelResult<Post>> responses = await client.parallel.list(
  ///   interface: client.posts,
  ///   requestBuilder: () {
  ///     return List.generate(
  ///       {MAX_PAGES},
  ///       (index) => ParallelRequest(
  ///         page: index + 1,
  ///         request: ListPostRequest(
  ///           perPage: {MAX_PER_PAGE},
  ///           page: index + 1,
  ///         ),
  ///       ),
  ///     );
  ///   },
  /// );
  /// ```
  ///
  /// Optionally, call `merge()` on the `responses` to merge the results into a single iterable.
  ParallelWordpress get parallel => ParallelWordpress(client: this);

  Future<bool> isAuthenticated([IAuthorization? auth]) async {
    final response = await me.retrieve(RetrieveMeRequest(authorization: auth));
    return response.isSuccessful;
  }
}
