import '../../wordpress_client.dart';
import 'media.dart';

final class MediaExtensions implements IInterfaceExtensions<Media, int> {
  MediaExtensions(this._iface);
  final MediaInterface _iface;

  @override
  Future<WordpressResponse<Media>> getById(int id, {RequestContext? context}) {
    return _iface.retrieve(
      RetrieveMediaRequest(id: id, context: context),
    );
  }

  Future<List<Media>> listAll({
    int perPage = 100,
    RequestContext? context,
  }) async {
    final first = await _iface
        .list(ListMediaRequest(perPage: perPage, context: context))
        .then((r) => r.asSuccess());
    final totalPages = first.totalPagesCount;
    final all = <Media>[...first.data];
    for (var p = 2; p <= totalPages; p++) {
      final next = await _iface
          .list(
            ListMediaRequest(page: p, perPage: perPage, context: context),
          )
          .then((r) => r.asSuccess());
      all.addAll(next.data);
    }
    return all;
  }
}

extension MediaInterfaceExtensions on MediaInterface {
  MediaExtensions get extensions => MediaExtensions(this);
}
