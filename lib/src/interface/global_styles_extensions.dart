import '../../wordpress_client.dart';

final class GlobalStylesExtensions
    implements IInterfaceExtensions<GlobalStyles, String> {
  GlobalStylesExtensions(this._iface);
  final GlobalStylesInterface _iface;

  @override
  Future<WordpressResponse<GlobalStyles>> getById(
    String id, {
    RequestContext? context,
  }) {
    return _iface.retrieve(
      RetrieveGlobalStylesRequest(id: id),
    );
  }
}

extension GlobalStylesInterfaceExtensions on GlobalStylesInterface {
  GlobalStylesExtensions get extensions => GlobalStylesExtensions(this);
}
