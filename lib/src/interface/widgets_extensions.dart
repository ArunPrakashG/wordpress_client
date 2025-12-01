import '../../wordpress_client.dart';

final class WidgetsExtensions implements IInterfaceExtensions<Widget, String> {
  WidgetsExtensions(this._iface);
  final WidgetsInterface _iface;

  @override
  Future<WordpressResponse<Widget>> getById(
    String id, {
    RequestContext? context,
  }) {
    return _iface.retrieve(
      RetrieveWidgetRequest(id: id, context: context),
    );
  }
}

final class SidebarsExtensions
    implements IInterfaceExtensions<Sidebar, String> {
  SidebarsExtensions(this._iface);
  final SidebarsInterface _iface;

  @override
  Future<WordpressResponse<Sidebar>> getById(
    String id, {
    RequestContext? context,
  }) {
    return _iface.retrieve(
      RetrieveSidebarRequest(id: id, context: context),
    );
  }
}

final class WidgetTypesExtensions
    implements IInterfaceExtensions<WidgetType, String> {
  WidgetTypesExtensions(this._iface);
  final WidgetTypesInterface _iface;

  @override
  Future<WordpressResponse<WidgetType>> getById(
    String id, {
    RequestContext? context,
  }) {
    return _iface.retrieve(
      RetrieveWidgetTypeRequest(id: id, context: context),
    );
  }
}

extension WidgetsInterfaceExtensions on WidgetsInterface {
  WidgetsExtensions get extensions => WidgetsExtensions(this);
}

extension SidebarsInterfaceExtensions on SidebarsInterface {
  SidebarsExtensions get extensions => SidebarsExtensions(this);
}

extension WidgetTypesInterfaceExtensions on WidgetTypesInterface {
  WidgetTypesExtensions get extensions => WidgetTypesExtensions(this);
}
