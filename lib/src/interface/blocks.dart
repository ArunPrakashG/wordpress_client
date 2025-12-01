import '../../wordpress_client.dart';

/// Interface for Editor Blocks (/wp/v2/blocks)
final class BlocksInterface extends IRequestInterface
    with
        ListOperation<Block, ListBlockRequest>,
        RetrieveOperation<Block, RetrieveBlockRequest>,
        CreateOperation<Block, CreateBlockRequest>,
        UpdateOperation<Block, UpdateBlockRequest>,
        DeleteOperation<DeleteBlockRequest> {}

/// Interface for Block Types (/wp/v2/block-types)
final class BlockTypesInterface extends IRequestInterface
    with
        ListOperation<BlockType, ListBlockTypeRequest>,
        RetrieveOperation<BlockType, RetrieveBlockTypeRequest> {}

/// Interface for Block Renderer (/wp/v2/block-renderer)
final class BlockRendererInterface extends IRequestInterface
    with CustomOperation<RenderedBlock, RenderBlockRequest> {
  @override
  RenderedBlock decode(dynamic json) {
    return RenderedBlock.fromJson(json as Map<String, dynamic>);
  }
}

/// Interface for Block Directory Items (/wp/v2/block-directory/search)
final class BlockDirectoryInterface extends IRequestInterface
    with ListOperation<BlockDirectoryItem, ListBlockDirectoryItemsRequest> {}

/// Interface for Pattern Directory Items (/wp/v2/pattern-directory/patterns)
final class PatternDirectoryInterface extends IRequestInterface
    with
        ListOperation<PatternDirectoryItem, ListPatternDirectoryItemsRequest> {}
