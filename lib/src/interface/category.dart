part of '../wordpress_client_base.dart';

class CategoryInterface
    implements
        ICreateOperation<Category, CategoryCreateBuilder>,
        IDeleteOperation<Category, CategoryDeleteBuilder>,
        IRetriveOperation<Category, CategoryRetriveBuilder>,
        IUpdateOperation<Category, CategoryUpdateBuilder>,
        IListOperation<Category, CategoryListBuilder> {
  @override
  Future<ResponseContainer<Category?>> create(
      {required Request<Category>? Function(CategoryCreateBuilder) builder, bool shouldWaitWhileClientBusy = false}) async {
    return (await _getInternalRequesterClient(shouldWaitIfBusy: shouldWaitWhileClientBusy)).createRequest<Category>(
      Category(),
      builder(
        CategoryCreateBuilder().withEndpoint('categories').initializeWithDefaultValues(),
      ),
    );
  }

  @override
  Future<ResponseContainer<Category?>> delete(
      {required Request<Category>? Function(CategoryDeleteBuilder) builder, bool shouldWaitWhileClientBusy = false}) async {
    return (await _getInternalRequesterClient(shouldWaitIfBusy: shouldWaitWhileClientBusy)).deleteRequest<Category>(
      Category(),
      builder(
        CategoryDeleteBuilder().withEndpoint('categories').initializeWithDefaultValues(),
      ),
    );
  }

  @override
  Future<ResponseContainer<List<Category?>?>> list(
      {required Request<List<Category>>? Function(CategoryListBuilder) builder, bool shouldWaitWhileClientBusy = false}) async {
    return (await _getInternalRequesterClient(shouldWaitIfBusy: shouldWaitWhileClientBusy)).listRequest<Category>(
      Category(),
      builder(
        CategoryListBuilder().withEndpoint('categories').initializeWithDefaultValues(),
      ),
    );
  }

  @override
  Future<ResponseContainer<Category?>> retrive(
      {required Request<Category>? Function(CategoryRetriveBuilder) builder, bool shouldWaitWhileClientBusy = false}) async {
    return (await _getInternalRequesterClient(shouldWaitIfBusy: shouldWaitWhileClientBusy)).retriveRequest<Category>(
      Category(),
      builder(
        CategoryRetriveBuilder().withEndpoint('categories').initializeWithDefaultValues(),
      ),
    );
  }

  @override
  Future<ResponseContainer<Category?>> update(
      {required Request<Category>? Function(CategoryUpdateBuilder) builder, bool shouldWaitWhileClientBusy = false}) async {
    return (await _getInternalRequesterClient(shouldWaitIfBusy: shouldWaitWhileClientBusy)).updateRequest<Category>(
      Category(),
      builder(
        CategoryUpdateBuilder().withEndpoint('categories').initializeWithDefaultValues(),
      ),
    );
  }
}
