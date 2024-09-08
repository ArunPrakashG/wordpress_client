import '../../wordpress_client.dart';

/// Represents the category interface for interacting with WordPress categories.
///
/// This interface provides CRUD (Create, Read, Update, Delete) operations for categories.
/// It extends [IRequestInterface] and mixes in various operations to handle different
/// category-related tasks.
///
/// Example usage:
/// ```dart
/// final wordpress = WordPressClient('https://your-wordpress-site.com/wp-json');
/// final categoryInterface = wordpress.categories;
///
/// // Create a new category
/// final newCategory = await categoryInterface.create(
///   CreateCategoryRequest(name: 'New Category'),
/// );
///
/// // Retrieve a category
/// final category = await categoryInterface.retrieve(
///   RetrieveCategoryRequest(id: 123),
/// );
///
/// // Update a category
/// final updatedCategory = await categoryInterface.update(
///   UpdateCategoryRequest(id: 123, name: 'Updated Category Name'),
/// );
///
/// // Delete a category
/// await categoryInterface.delete(DeleteCategoryRequest(id: 123));
///
/// // List categories
/// final categories = await categoryInterface.list(
///   ListCategoryRequest(perPage: 10, page: 1),
/// );
/// ```
final class CategoryInterface extends IRequestInterface
    with
        CreateOperation<Category, CreateCategoryRequest>,
        DeleteOperation<DeleteCategoryRequest>,
        RetrieveOperation<Category, RetrieveCategoryRequest>,
        UpdateOperation<Category, UpdateCategoryRequest>,
        ListOperation<Category, ListCategoryRequest> {}
