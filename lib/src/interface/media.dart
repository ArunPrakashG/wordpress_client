import '../../wordpress_client.dart';

/// Represents the media interface for interacting with WordPress media items.
///
/// This interface provides operations to manage media files such as images,
/// videos, and documents in a WordPress site.
///
/// Example usage:
/// ```dart
/// final wp = WordPressClient('https://example.com/wp-json');
/// final mediaInterface = wp.media;
///
/// // Create a new media item
/// final newMedia = await mediaInterface.create(CreateMediaRequest(
///   file: File('image.jpg'),
///   title: 'My Image',
/// ));
///
/// // Retrieve a media item
/// final media = await mediaInterface.retrieve(RetrieveMediaRequest(id: 123));
///
/// // Update a media item
/// final updatedMedia = await mediaInterface.update(UpdateMediaRequest(
///   id: 123,
///   title: 'Updated Image Title',
/// ));
///
/// // Delete a media item
/// await mediaInterface.delete(DeleteMediaRequest(id: 123));
///
/// // List media items
/// final mediaList = await mediaInterface.list(ListMediaRequest(
///   perPage: 10,
///   page: 1,
/// ));
/// ```
final class MediaInterface extends IRequestInterface
    with
        CreateOperation<Media, CreateMediaRequest>,
        DeleteOperation<DeleteMediaRequest>,
        RetrieveOperation<Media, RetrieveMediaRequest>,
        UpdateOperation<Media, UpdateMediaRequest>,
        ListOperation<Media, ListMediaRequest> {}
