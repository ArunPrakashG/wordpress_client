import '../../requests.dart';
import '../operations/create.dart';
import '../operations/delete.dart';
import '../operations/list.dart';
import '../operations/retrieve.dart';
import '../operations/update.dart';
import '../responses/category_response.dart';
import '../wordpress_client_base.dart';

final class CategoryInterface extends IRequestInterface
    with
        CreateOperation<Category, CreateCategoryRequest>,
        DeleteOperation<DeleteCategoryRequest>,
        RetriveOperation<Category, RetriveCategoryRequest>,
        UpdateOperation<Category, UpdateCategoryRequest>,
        ListOperation<Category, ListCategoryRequest> {}
