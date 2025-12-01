import '../../wordpress_client.dart';
import 'users.dart';

final class UsersExtensions implements IInterfaceExtensions<User, int> {
  UsersExtensions(this._iface);
  final UsersInterface _iface;

  @override
  Future<WordpressResponse<User>> getById(int id, {RequestContext? context}) {
    return _iface.retrieve(
      RetrieveUserRequest(id: id, context: context),
    );
  }

  Future<User?> findBySlug(String slug, {RequestContext? context}) async {
    final s = await _iface
        .list(ListUserRequest(perPage: 1, slug: [slug], context: context))
        .then((r) => r.asSuccess());
    return s.data.isNotEmpty ? s.data.first : null;
  }

  Future<List<User>> listAll({
    int perPage = 100,
    RequestContext? context,
  }) async {
    final first = await _iface
        .list(ListUserRequest(perPage: perPage, context: context))
        .then((r) => r.asSuccess());
    final totalPages = first.totalPagesCount;
    final all = <User>[...first.data];
    for (var p = 2; p <= totalPages; p++) {
      final next = await _iface
          .list(
            ListUserRequest(page: p, perPage: perPage, context: context),
          )
          .then((r) => r.asSuccess());
      all.addAll(next.data);
    }
    return all;
  }
}

extension UsersInterfaceExtensions on UsersInterface {
  UsersExtensions get extensions => UsersExtensions(this);
}
