import '../../wordpress_client.dart';
import 'posts.dart';

final class PostsExtensions implements IInterfaceExtensions<Post, int> {
  PostsExtensions(this._iface);
  final PostsInterface _iface;

  @override
  Future<WordpressResponse<Post>> getById(int id, {RequestContext? context}) {
    return _iface.retrieve(
      RetrievePostRequest(id: id, context: context),
    );
  }

  /// Convenience: find a post by slug. Returns the first match if any.
  /// Throws if the underlying list request fails.
  Future<Post?> findBySlug(
    String slug, {
    RequestContext? context,
  }) async {
    final s = await _iface
        .list(ListPostRequest(perPage: 1, slug: [slug], context: context))
        .then((r) => r.asSuccess());
    return s.data.isNotEmpty ? s.data.first : null;
  }

  /// Convenience: fetch all posts across pages using auto-pagination.
  /// Throws on the first failure encountered.
  Future<List<Post>> listAll({
    int perPage = 100,
    RequestContext? context,
  }) async {
    final first = await _iface
        .list(ListPostRequest(perPage: perPage, context: context))
        .then((r) => r.asSuccess());
    final totalPages = first.totalPagesCount;
    final all = <Post>[...first.data];
    for (var p = 2; p <= totalPages; p++) {
      final next = await _iface
          .list(ListPostRequest(page: p, perPage: perPage, context: context))
          .then((r) => r.asSuccess());
      all.addAll(next.data);
    }
    return all;
  }
}

extension PostsInterfaceExtensions on PostsInterface {
  PostsExtensions get extensions => PostsExtensions(this);
}
