import '../../wordpress_client.dart';

/// Represents the interface for interacting with WordPress pages.
///
/// This class provides methods for creating, retrieving, updating, deleting,
/// and listing pages in a WordPress site.
///
/// Example usage:
///
/// ```dart
/// final wordpress = WordpressClient(baseUrl: 'https://your-site.com/wp-json');
/// final pagesInterface = wordpress.pages;
///
/// // Create a new page
/// final newPage = await pagesInterface.create(CreatePageRequest(
///   title: 'My New Page',
///   content: 'This is the content of my new page.',
///   status: 'publish',
/// ));
///
/// // Retrieve a page
/// final page = await pagesInterface.retrieve(RetrievePageRequest(id: 123));
///
/// // Update a page
/// final updatedPage = await pagesInterface.update(UpdatePageRequest(
///   id: 123,
///   title: 'Updated Page Title',
/// ));
///
/// // Delete a page
/// await pagesInterface.delete(DeletePageRequest(id: 123));
///
/// // List pages
/// final pages = await pagesInterface.list(ListPageRequest(
///   perPage: 10,
///   page: 1,
/// ));
/// ```
final class PagesInterface extends IRequestInterface
    with
        CreateOperation<Page, CreatePageRequest>,
        DeleteOperation<DeletePageRequest>,
        RetrieveOperation<Page, RetrievePageRequest>,
        UpdateOperation<Page, UpdatePageRequest>,
        ListOperation<Page, ListPageRequest> {}
