import '../../wordpress_client.dart';
import 'revisions.dart';

final class PostRevisionsExtensions
    implements IInterfaceExtensions<Revision, (int postId, int revisionId)> {
  PostRevisionsExtensions(this._iface);
  final PostRevisionsInterface _iface;

  @override
  Future<WordpressResponse<Revision>> getById(
    (int postId, int revisionId) ids, {
    RequestContext? context,
  }) {
    return _iface.retrieve(
      RetrievePostRevisionRequest(
        postId: ids.$1,
        revisionId: ids.$2,
        context: context,
      ),
    );
  }
}

final class PageRevisionsExtensions
    implements IInterfaceExtensions<Revision, (int pageId, int revisionId)> {
  PageRevisionsExtensions(this._iface);
  final PageRevisionsInterface _iface;

  @override
  Future<WordpressResponse<Revision>> getById(
    (int pageId, int revisionId) ids, {
    RequestContext? context,
  }) {
    return _iface.retrieve(
      RetrievePageRevisionRequest(
        pageId: ids.$1,
        revisionId: ids.$2,
        context: context,
      ),
    );
  }
}

extension PostRevisionsInterfaceExtensions on PostRevisionsInterface {
  PostRevisionsExtensions get extensions => PostRevisionsExtensions(this);
}

extension PageRevisionsInterfaceExtensions on PageRevisionsInterface {
  PageRevisionsExtensions get extensions => PageRevisionsExtensions(this);
}
