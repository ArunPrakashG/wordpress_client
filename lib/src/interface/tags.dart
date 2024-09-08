import '../../wordpress_client.dart';

/// Represents the tag interface for interacting with WordPress tags.
///
/// This interface provides CRUD (Create, Read, Update, Delete) operations for tags.
/// It extends [IRequestInterface] and mixes in various operations to handle tag-related tasks.
///
/// Example usage:
/// ```dart
/// final wordpress = WordpressClient(baseUrl: 'https://your-wordpress-site.com/wp-json');
/// final tagInterface = wordpress.tags;
///
/// // Create a new tag
/// final newTag = await tagInterface.create(CreateTagRequest(name: 'New Tag'));
///
/// // Retrieve a tag
/// final tag = await tagInterface.retrieve(RetrieveTagRequest(id: 123));
///
/// // Update a tag
/// final updatedTag = await tagInterface.update(UpdateTagRequest(id: 123, name: 'Updated Tag'));
///
/// // Delete a tag
/// await tagInterface.delete(DeleteTagRequest(id: 123));
///
/// // List tags
/// final tags = await tagInterface.list(ListTagRequest());
/// ```
final class TagInterface extends IRequestInterface
    with
        CreateOperation<Tag, CreateTagRequest>,
        DeleteOperation<DeleteTagRequest>,
        RetrieveOperation<Tag, RetrieveTagRequest>,
        UpdateOperation<Tag, UpdateTagRequest>,
        ListOperation<Tag, ListTagRequest> {}
