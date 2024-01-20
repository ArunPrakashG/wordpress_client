import '../../wordpress_client.dart';

/// Represents the media interface.
final class MediaInterface extends IRequestInterface
    with
        CreateOperation<Media, CreateMediaRequest>,
        DeleteOperation<DeleteMediaRequest>,
        RetrieveOperation<Media, RetrieveMediaRequest>,
        UpdateOperation<Media, UpdateMediaRequest>,
        ListOperation<Media, ListMediaRequest> {}
