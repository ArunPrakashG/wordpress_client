import '../../wordpress_client.dart';
import 'tags.dart';

final class TagsExtensions implements IInterfaceExtensions<Tag, int> {
  TagsExtensions(this._iface);
  final TagInterface _iface;

  @override
  Future<WordpressResponse<Tag>> getById(int id, {RequestContext? context}) {
    return _iface.retrieve(
      RetrieveTagRequest(id: id, context: context),
    );
  }

  Future<Tag?> findBySlug(String slug, {RequestContext? context}) async {
    final s = await _iface
        .list(ListTagRequest(perPage: 1, slug: [slug], context: context))
        .then((r) => r.asSuccess());
    return s.data.isNotEmpty ? s.data.first : null;
  }

  Future<List<Tag>> listAll({
    int perPage = 100,
    RequestContext? context,
  }) async {
    final first = await _iface
        .list(ListTagRequest(perPage: perPage, context: context))
        .then((r) => r.asSuccess());
    final totalPages = first.totalPagesCount;
    final all = <Tag>[...first.data];
    for (var p = 2; p <= totalPages; p++) {
      final next = await _iface
          .list(
            ListTagRequest(page: p, perPage: perPage, context: context),
          )
          .then((r) => r.asSuccess());
      all.addAll(next.data);
    }
    return all;
  }
}

extension TagInterfaceExtensions on TagInterface {
  TagsExtensions get extensions => TagsExtensions(this);
}
