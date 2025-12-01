import '../../wordpress_client.dart';
import 'types.dart';

final class TypesExtensions implements IInterfaceExtensions<PostType, String> {
  TypesExtensions(this._iface);
  final TypesInterface _iface;

  @override
  Future<WordpressResponse<PostType>> getById(
    String slug, {
    RequestContext? context,
  }) {
    return _iface.retrieve(
      RetrieveTypeRequest(slug: slug, context: context),
    );
  }
}

extension TypesInterfaceExtensions on TypesInterface {
  TypesExtensions get extensions => TypesExtensions(this);
}
