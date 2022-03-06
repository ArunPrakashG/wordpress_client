import '../builders_import.dart';
import '../operations/create.dart';
import '../operations/delete.dart';
import '../operations/list.dart';
import '../operations/retrieve.dart';
import '../operations/update.dart';
import '../responses/category_response.dart';
import '../responses/response_container.dart';
import 'interface_base.dart';

class CategoryInterface extends IInterface
    implements
        ICreateOperation<Category, CategoryCreateBuilder>,
        IDeleteOperation<Category, CategoryDeleteBuilder>,
        IRetrieveOperation<Category, CategoryRetriveBuilder>,
        IUpdateOperation<Category, CategoryUpdateBuilder>,
        IListOperation<Category, CategoryListBuilder> {
  @override
  Future<ResponseContainer<Category?>> create(
    Request<Category>? Function(CategoryCreateBuilder) builder, {
    bool shouldWaitWhileClientBusy = false,
  }) async {
    return (shouldWaitWhileClientBusy
            ? await getInternalRequesterWhenFree()
            : internalRequester)
        .createRequest<Category>(
      Category(),
      builder(
        CategoryCreateBuilder()
            .withEndpoint('categories')
            .initializeWithDefaultValues(),
      ),
    );
  }

  @override
  Future<ResponseContainer<Category?>> delete(
      Request<Category>? Function(CategoryDeleteBuilder) builder,
      {bool shouldWaitWhileClientBusy = false}) async {
    return (shouldWaitWhileClientBusy
            ? await getInternalRequesterWhenFree()
            : internalRequester)
        .deleteRequest<Category>(
      Category(),
      builder(
        CategoryDeleteBuilder()
            .withEndpoint('categories')
            .initializeWithDefaultValues(),
      ),
    );
  }

  @override
  Future<ResponseContainer<List<Category>?>> list(
      Request<List<Category>>? Function(CategoryListBuilder) builder,
      {bool shouldWaitWhileClientBusy = false}) async {
    return (shouldWaitWhileClientBusy
            ? await getInternalRequesterWhenFree()
            : internalRequester)
        .listRequest<Category>(
      Category(),
      builder(
        CategoryListBuilder()
            .withEndpoint('categories')
            .initializeWithDefaultValues(),
      ),
    );
  }

  @override
  Future<ResponseContainer<Category?>> retrive(
      Request<Category>? Function(CategoryRetriveBuilder) builder,
      {bool shouldWaitWhileClientBusy = false}) async {
    return (shouldWaitWhileClientBusy
            ? await getInternalRequesterWhenFree()
            : internalRequester)
        .retriveRequest<Category>(
      Category(),
      builder(
        CategoryRetriveBuilder()
            .withEndpoint('categories')
            .initializeWithDefaultValues(),
      ),
    );
  }

  @override
  Future<ResponseContainer<Category?>> update(
      Request<Category>? Function(CategoryUpdateBuilder) builder,
      {bool shouldWaitWhileClientBusy = false}) async {
    return (shouldWaitWhileClientBusy
            ? await getInternalRequesterWhenFree()
            : internalRequester)
        .updateRequest<Category>(
      Category(),
      builder(
        CategoryUpdateBuilder()
            .withEndpoint('categories')
            .initializeWithDefaultValues(),
      ),
    );
  }
}
