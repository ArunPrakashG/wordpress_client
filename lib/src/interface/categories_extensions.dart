import '../../wordpress_client.dart';
import 'category.dart';

final class CategoriesExtensions
    implements IInterfaceExtensions<Category, int> {
  CategoriesExtensions(this._iface);
  final CategoryInterface _iface;

  @override
  Future<WordpressResponse<Category>> getById(
    int id, {
    RequestContext? context,
  }) {
    return _iface.retrieve(
      RetrieveCategoryRequest(id: id, context: context),
    );
  }

  Future<Category?> findBySlug(String slug, {RequestContext? context}) async {
    final s = await _iface
        .list(ListCategoryRequest(perPage: 1, slug: [slug], context: context))
        .then((r) => r.asSuccess());
    return s.data.isNotEmpty ? s.data.first : null;
  }

  Future<List<Category>> listAll({
    int perPage = 100,
    RequestContext? context,
  }) async {
    final first = await _iface
        .list(ListCategoryRequest(perPage: perPage, context: context))
        .then((r) => r.asSuccess());
    final totalPages = first.totalPagesCount;
    final all = <Category>[...first.data];
    for (var p = 2; p <= totalPages; p++) {
      final next = await _iface
          .list(
            ListCategoryRequest(page: p, perPage: perPage, context: context),
          )
          .then((r) => r.asSuccess());
      all.addAll(next.data);
    }
    return all;
  }
}

extension CategoryInterfaceExtensions on CategoryInterface {
  CategoriesExtensions get extensions => CategoriesExtensions(this);
}
