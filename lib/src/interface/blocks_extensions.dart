import '../../wordpress_client.dart';
import 'blocks.dart';

final class BlocksExtensions implements IInterfaceExtensions<Block, int> {
  BlocksExtensions(this._iface);
  final BlocksInterface _iface;

  @override
  Future<WordpressResponse<Block>> getById(int id, {RequestContext? context}) {
    return _iface.retrieve(
      RetrieveBlockRequest(id: id, context: context),
    );
  }
}

final class BlockTypesExtensions
    implements
        IInterfaceExtensions<BlockType, (String namespace, String name)> {
  BlockTypesExtensions(this._iface);
  final BlockTypesInterface _iface;

  @override
  Future<WordpressResponse<BlockType>> getById(
    (String namespace, String name) id, {
    RequestContext? context,
  }) {
    return _iface.retrieve(
      RetrieveBlockTypeRequest(
        namespace: id.$1,
        name: id.$2,
        context: context,
      ),
    );
  }
}

extension BlocksInterfaceExtensions on BlocksInterface {
  BlocksExtensions get extensions => BlocksExtensions(this);
}

extension BlockTypesInterfaceExtensions on BlockTypesInterface {
  BlockTypesExtensions get extensions => BlockTypesExtensions(this);
}
