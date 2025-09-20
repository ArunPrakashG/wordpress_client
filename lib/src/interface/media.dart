import '../../wordpress_client.dart';

/// Interface for interacting with Media (wp/v2/media).
///
/// Supported operations:
/// - List: `GET /wp/v2/media`
/// - Retrieve: `GET /wp/v2/media/<id>`
/// - Create: `POST /wp/v2/media` (requires authorization)
/// - Update: `POST /wp/v2/media/<id>` (requires authorization)
/// - Delete: `DELETE /wp/v2/media/<id>` (requires authorization)
///
/// Reference: https://developer.wordpress.org/rest-api/reference/media/
final class MediaInterface extends IRequestInterface
    with
        CreateOperation<Media, CreateMediaRequest>,
        DeleteOperation<DeleteMediaRequest>,
        RetrieveOperation<Media, RetrieveMediaRequest>,
        UpdateOperation<Media, UpdateMediaRequest>,
        ListOperation<Media, ListMediaRequest> {}
