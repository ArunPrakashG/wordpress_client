import '../../wordpress_client.dart';
import 'templates.dart';

final class TemplatesExtensions
    implements IInterfaceExtensions<Template, String> {
  TemplatesExtensions(this._iface);
  final TemplatesInterface _iface;

  @override
  Future<WordpressResponse<Template>> getById(
    String id, {
    RequestContext? context,
  }) {
    return _iface.retrieve(
      RetrieveTemplateRequest(id: id, context: context),
    );
  }
}

final class TemplatePartsExtensions
    implements IInterfaceExtensions<TemplatePart, String> {
  TemplatePartsExtensions(this._iface);
  final TemplatePartsInterface _iface;

  @override
  Future<WordpressResponse<TemplatePart>> getById(
    String id, {
    RequestContext? context,
  }) {
    return _iface.retrieve(
      RetrieveTemplatePartRequest(id: id, context: context),
    );
  }
}

final class TemplateRevisionsExtensions
    implements IInterfaceExtensions<Revision, (int parent, int id)> {
  TemplateRevisionsExtensions(this._iface);
  final TemplateRevisionsInterface _iface;

  @override
  Future<WordpressResponse<Revision>> getById(
    (int parent, int id) ids, {
    RequestContext? context,
  }) {
    return _iface.retrieve(
      RetrieveTemplateRevisionRequest(
        parent: ids.$1,
        id: ids.$2,
        context: context,
      ),
    );
  }
}

final class TemplatePartRevisionsExtensions
    implements IInterfaceExtensions<Revision, (int parent, int id)> {
  TemplatePartRevisionsExtensions(this._iface);
  final TemplatePartRevisionsInterface _iface;

  @override
  Future<WordpressResponse<Revision>> getById(
    (int parent, int id) ids, {
    RequestContext? context,
  }) {
    return _iface.retrieve(
      RetrieveTemplatePartRevisionRequest(
        parent: ids.$1,
        id: ids.$2,
        context: context,
      ),
    );
  }
}

extension TemplatesInterfaceExtensions on TemplatesInterface {
  TemplatesExtensions get extensions => TemplatesExtensions(this);
}

extension TemplatePartsInterfaceExtensions on TemplatePartsInterface {
  TemplatePartsExtensions get extensions => TemplatePartsExtensions(this);
}

extension TemplateRevisionsInterfaceExtensions on TemplateRevisionsInterface {
  TemplateRevisionsExtensions get extensions =>
      TemplateRevisionsExtensions(this);
}

extension TemplatePartRevisionsInterfaceExtensions
    on TemplatePartRevisionsInterface {
  TemplatePartRevisionsExtensions get extensions =>
      TemplatePartRevisionsExtensions(this);
}
