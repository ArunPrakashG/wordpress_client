import '../../wordpress_client.dart';
import 'settings.dart';

/// Settings is effectively a singleton resource; getById ignores the id.
final class SettingsExtensions implements IInterfaceExtensions<Settings, void> {
  SettingsExtensions(this._iface);
  final SettingsInterface _iface;

  @override
  Future<WordpressResponse<Settings>> getById(
    void _, {
    RequestContext? context,
  }) {
    return _iface.retrieve(RetrieveSettingsRequest());
  }

  /// Explicit convenience to retrieve settings.
  Future<WordpressResponse<Settings>> get() =>
      _iface.retrieve(RetrieveSettingsRequest());
}

extension SettingsInterfaceExtensions on SettingsInterface {
  SettingsExtensions get extensions => SettingsExtensions(this);
}
