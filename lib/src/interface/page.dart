import '../../wordpress_client.dart';

/// Interface for interacting with WordPress Pages (wp/v2/pages).
///
/// Supported operations:
/// - List: `GET /wp/v2/pages`
/// - Retrieve: `GET /wp/v2/pages/<id>`
/// - Create: `POST /wp/v2/pages` (requires authorization)
/// - Update: `POST /wp/v2/pages/<id>` (requires authorization)
/// - Delete: `DELETE /wp/v2/pages/<id>` (requires authorization)
///
/// Reference: https://developer.wordpress.org/rest-api/reference/pages/
final class PagesInterface extends IRequestInterface
    with
        CreateOperation<Page, CreatePageRequest>,
        DeleteOperation<DeletePageRequest>,
        RetrieveOperation<Page, RetrievePageRequest>,
        UpdateOperation<Page, UpdatePageRequest>,
        ListOperation<Page, ListPageRequest> {}
