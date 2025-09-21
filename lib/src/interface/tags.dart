import '../../wordpress_client.dart';

/// Tags (wp/v2/tags)
///
/// CRUD operations for WordPress tags via the REST API.
///
/// Reference: https://developer.wordpress.org/rest-api/reference/tags/
///
/// Example usage:
/// ```dart
/// final wp = WordpressClient(baseUrl: 'https://example.com/wp-json');
/// final tags = await wp.tags.list(ListTagRequest(search: 'news'));
/// ```
final class TagInterface extends IRequestInterface
    with
        CreateOperation<Tag, CreateTagRequest>,
        DeleteOperation<DeleteTagRequest>,
        RetrieveOperation<Tag, RetrieveTagRequest>,
        UpdateOperation<Tag, UpdateTagRequest>,
        ListOperation<Tag, ListTagRequest> {}
