import '../operations/create.dart';
import '../operations/delete.dart';
import '../operations/list.dart';
import '../operations/retrieve.dart';
import '../operations/update.dart';
import '../requests/create/create_category.dart';
import '../requests/delete/delete_category.dart';
import '../requests/list/list_category.dart';
import '../requests/retrive/retrive_category.dart';
import '../requests/update/update_category.dart';
import '../requests/wordpress_request.dart';
import '../responses/category_response.dart';
import '../responses/wordpress_response.dart';
import '../wordpress_client_base.dart';

class CategoryInterface extends IInterface
    with
        ICreate<Category, CreateCategoryRequest>,
        IDelete<Category, DeleteCategoryRequest>,
        IRetrive<Category, RetriveCategoryRequest>,
        IUpdate<Category, UpdateCategoryRequest>,
        IList<Category, ListCategoryRequest> {
  @override
  Future<WordpressResponse<Category?>> create(
    WordpressRequest<CreateCategoryRequest> request,
  ) {
    return internalRequester.createRequest<Category>(request);
  }

  @override
  Future<WordpressResponse<Category?>> delete(
    WordpressRequest<DeleteCategoryRequest> request,
  ) {
    return internalRequester.deleteRequest<Category>(request);
  }

  @override
  Future<WordpressResponse<List<Category>?>> list(
    WordpressRequest<ListCategoryRequest> request,
  ) async {
    return internalRequester.listRequest<Category>(request);
  }

  @override
  Future<WordpressResponse<Category?>> retrive(
    WordpressRequest<RetriveCategoryRequest> request,
  ) async {
    return internalRequester.retriveRequest<Category>(request);
  }

  @override
  Future<WordpressResponse<Category?>> update(
    WordpressRequest<UpdateCategoryRequest> request,
  ) async {
    return internalRequester.updateRequest<Category>(request);
  }
}
