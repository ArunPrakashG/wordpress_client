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
import '../responses/category_response.dart';
import '../responses/wordpress_response.dart';
import '../wordpress_client_base.dart';
import 'interface_base.dart';

class CategoryInterface extends IInterface
    with
        ICreate<Category, CreateCategoryRequest>,
        IDelete<Category, DeleteCategoryRequest>,
        IRetrive<Category, RetriveCategoryRequest>,
        IUpdate<Category, UpdateCategoryRequest>,
        IList<Category, ListCategoryRequest> {
  @override
  Future<WordpressResponse<Category?>> create(
    GenericRequest<CreateCategoryRequest> request,
  ) {
    return internalRequester.createRequest<Category>(request);
  }

  @override
  Future<WordpressResponse<Category?>> delete(
    GenericRequest<DeleteCategoryRequest> request,
  ) {
    return internalRequester.deleteRequest<Category>(request);
  }

  @override
  Future<WordpressResponse<List<Category>?>> list(
    GenericRequest<ListCategoryRequest> request,
  ) async {
    return internalRequester.listRequest<Category>(request);
  }

  @override
  Future<WordpressResponse<Category?>> retrive(
    GenericRequest<RetriveCategoryRequest> request,
  ) async {
    return internalRequester.retriveRequest<Category>(request);
  }

  @override
  Future<WordpressResponse<Category?>> update(
    GenericRequest<UpdateCategoryRequest> request,
  ) async {
    return internalRequester.updateRequest<Category>(request);
  }
}
