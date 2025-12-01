import '../../wordpress_client.dart';

/// Categories (wp/v2/categories)
///
/// CRUD operations for WordPress categories via the REST API.
///
/// Reference: https://developer.wordpress.org/rest-api/reference/categories/
///
/// Example usage:
/// ```dart
/// final wp = WordpressClient(baseUrl: 'https://example.com/wp-json');
/// final cats = await wp.categories.list(ListCategoryRequest(orderBy: OrderBy.name));
/// ```
final class CategoryInterface extends IRequestInterface
    with
        CreateOperation<Category, CreateCategoryRequest>,
        DeleteOperation<DeleteCategoryRequest>,
        RetrieveOperation<Category, RetrieveCategoryRequest>,
        UpdateOperation<Category, UpdateCategoryRequest>,
        ListOperation<Category, ListCategoryRequest> {}
