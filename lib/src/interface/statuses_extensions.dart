import '../../wordpress_client.dart';
import 'statuses.dart';

final class StatusesExtensions
    implements IInterfaceExtensions<PostStatus, String> {
  StatusesExtensions(this._iface);
  final StatusesInterface _iface;

  @override
  Future<WordpressResponse<PostStatus>> getById(
    String slug, {
    RequestContext? context,
  }) {
    return _iface.retrieve(
      RetrieveStatusRequest(slug: slug, context: context),
    );
  }
}

extension StatusesInterfaceExtensions on StatusesInterface {
  StatusesExtensions get extensions => StatusesExtensions(this);
}
