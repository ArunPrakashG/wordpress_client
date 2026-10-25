import '../../wordpress_client.dart';

final class ThemesExtensions implements IInterfaceExtensions<Theme, String> {
  ThemesExtensions(this._iface);
  final ThemesInterface _iface;

  @override
  Future<WordpressResponse<Theme>> getById(
    String stylesheet, {
    RequestContext? context,
  }) {
    return _iface.retrieve(
      RetrieveThemeRequest(stylesheet: stylesheet),
    );
  }
}

extension ThemesInterfaceExtensions on ThemesInterface {
  ThemesExtensions get extensions => ThemesExtensions(this);
}
