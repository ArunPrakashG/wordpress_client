import '../../wordpress_client.dart';

/// Represents the media interface.
final class MediaInterface extends IRequestInterface
    with
        CreateOperation<Media, CreateMediaRequest>,
        DeleteOperation<DeleteMediaRequest>,
        RetriveOperation<Media, RetriveMediaRequest>,
        UpdateOperation<Media, UpdateMediaRequest>,
        ListOperation<Media, ListMediaRequest> {}
