import '../../wordpress_client.dart';

final class MediaInterface extends IRequestInterface
    with
        CreateOperation<Media, CreateMediaRequest>,
        DeleteOperation<DeleteMediaRequest>,
        RetriveOperation<Media, RetriveMediaRequest>,
        UpdateOperation<Media, UpdateMediaRequest>,
        ListOperation<Media, ListMediaRequest> {}
