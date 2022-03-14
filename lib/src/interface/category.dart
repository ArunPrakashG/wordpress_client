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
import '../wordpress_client_base.dart';

class CategoryInterface extends IInterface
    with
        CreateMixin<Category, CreateCategoryRequest>,
        DeleteMixin<Category, DeleteCategoryRequest>,
        RetriveMixin<Category, RetriveCategoryRequest>,
        UpdateMixin<Category, UpdateCategoryRequest>,
        ListMixin<Category, ListCategoryRequest> {}
