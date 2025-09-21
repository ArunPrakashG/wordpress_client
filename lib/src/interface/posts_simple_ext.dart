import '../../wordpress_client.dart';
import 'posts.dart';

/// Lightweight helpers for common Posts operations without constructing request classes.
extension PostsSimple on PostsInterface {
  /// List posts with a few common parameters.
  Future<WordpressResponse<List<Post>>> listSimple({
    int page = 1,
    int perPage = 10,
    String? search,
    Order? order,
    OrderBy? orderBy,
    List<int>? categories,
    List<int>? tags,
  }) {
    return list(
      ListPostRequest(
        page: page,
        perPage: perPage,
        search: search,
        order: order,
        orderBy: orderBy,
        categories: categories,
        tags: tags,
      ),
    );
  }

  /// Retrieve a single post by id.
  Future<WordpressResponse<Post>> getById(int id, {RequestContext? context}) {
    return retrieve(
      RetrievePostRequest(
        id: id,
        context: context,
      ),
    );
  }

  /// Create a new post with minimal fields. Use the full request for advanced fields.
  Future<WordpressResponse<Post>> createSimple({
    required String title,
    String? content,
    String status = 'draft',
    List<int>? categories,
    List<int>? tags,
  }) {
    return create(
      CreatePostRequest(
        title: title,
        content: content,
        status: status,
        categories: categories,
        tags: tags,
      ),
    );
  }
}
