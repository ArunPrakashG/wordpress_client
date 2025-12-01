import '../../wordpress_client.dart';
import 'page.dart';

final class PagesExtensions implements IInterfaceExtensions<Page, int> {
  PagesExtensions(this._iface);
  final PagesInterface _iface;

  @override
  Future<WordpressResponse<Page>> getById(int id, {RequestContext? context}) {
    return _iface.retrieve(
      RetrievePageRequest(id: id, context: context),
    );
  }

  Future<Page?> findBySlug(String slug, {RequestContext? context}) async {
    final s = await _iface
        .list(ListPageRequest(perPage: 1, slug: [slug], context: context))
        .then((r) => r.asSuccess());
    return s.data.isNotEmpty ? s.data.first : null;
  }

  Future<List<Page>> listAll({
    int perPage = 100,
    RequestContext? context,
  }) async {
    final first = await _iface
        .list(ListPageRequest(perPage: perPage, context: context))
        .then((r) => r.asSuccess());
    final totalPages = first.totalPagesCount;
    final all = <Page>[...first.data];
    for (var p = 2; p <= totalPages; p++) {
      final next = await _iface
          .list(
            ListPageRequest(page: p, perPage: perPage, context: context),
          )
          .then((r) => r.asSuccess());
      all.addAll(next.data);
    }
    return all;
  }
}

extension PagesInterfaceExtensions on PagesInterface {
  PagesExtensions get extensions => PagesExtensions(this);
}
