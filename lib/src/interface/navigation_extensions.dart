import '../../wordpress_client.dart';

final class NavigationsExtensions
    implements IInterfaceExtensions<Navigation, int> {
  NavigationsExtensions(this._iface);
  final NavigationsInterface _iface;

  @override
  Future<WordpressResponse<Navigation>> getById(
    int id, {
    RequestContext? context,
  }) {
    return _iface.retrieve(
      RetrieveNavigationRequest(id: id, context: context),
    );
  }
}

final class NavigationRevisionsExtensions
    implements IInterfaceExtensions<Revision, (int parent, int id)> {
  NavigationRevisionsExtensions(this._iface);
  final NavigationRevisionsInterface _iface;

  @override
  Future<WordpressResponse<Revision>> getById(
    (int parent, int id) ids, {
    RequestContext? context,
  }) {
    return _iface.retrieve(
      RetrieveNavigationRevisionRequest(
        parent: ids.$1,
        id: ids.$2,
        context: context,
      ),
    );
  }
}

final class NavigationAutosavesExtensions
    implements IInterfaceExtensions<Revision, (int parent, int id)> {
  NavigationAutosavesExtensions(this._iface);
  final NavigationAutosavesInterface _iface;

  @override
  Future<WordpressResponse<Revision>> getById(
    (int parent, int id) ids, {
    RequestContext? context,
  }) {
    return _iface.retrieve(
      RetrieveNavigationAutosaveRequest(
        parent: ids.$1,
        id: ids.$2,
        context: context,
      ),
    );
  }
}

extension NavigationsInterfaceExtensions on NavigationsInterface {
  NavigationsExtensions get extensions => NavigationsExtensions(this);
}

extension NavigationRevisionsInterfaceExtensions
    on NavigationRevisionsInterface {
  NavigationRevisionsExtensions get extensions =>
      NavigationRevisionsExtensions(this);
}

extension NavigationAutosavesInterfaceExtensions
    on NavigationAutosavesInterface {
  NavigationAutosavesExtensions get extensions =>
      NavigationAutosavesExtensions(this);
}
