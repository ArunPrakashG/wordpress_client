import '../../wordpress_client.dart';

/// Represents the category interface.
final class CategoryInterface extends IRequestInterface
    with
        CreateOperation<Category, CreateCategoryRequest>,
        DeleteOperation<DeleteCategoryRequest>,
        RetrieveOperation<Category, RetrieveCategoryRequest>,
        UpdateOperation<Category, UpdateCategoryRequest>,
        ListOperation<Category, ListCategoryRequest> {}
