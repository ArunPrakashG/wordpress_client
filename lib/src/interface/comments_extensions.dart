import '../../wordpress_client.dart';
import 'comments.dart';

final class CommentsExtensions implements IInterfaceExtensions<Comment, int> {
  CommentsExtensions(this._iface);
  final CommentInterface _iface;

  @override
  Future<WordpressResponse<Comment>> getById(
    int id, {
    RequestContext? context,
  }) {
    return _iface.retrieve(
      RetrieveCommentRequest(id: id, context: context),
    );
  }
}

extension CommentInterfaceExtensions on CommentInterface {
  CommentsExtensions get extensions => CommentsExtensions(this);
}
