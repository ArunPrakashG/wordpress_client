import '../../wordpress_client.dart';

/// Interface for Post Types (/wp/v2/types)
/// Note: The list endpoint returns an object map keyed by slug; use CustomOperation to decode.
final class TypesInterface extends IRequestInterface
    with
        CustomOperation<List<PostType>, ListTypeRequest>,
        RetrieveOperation<PostType, RetrieveTypeRequest> {
  @override
  List<PostType> decode(dynamic json) {
    if (json is Map<String, dynamic>) {
      return json.values
          .map<PostType>((e) => PostType.fromJson(e as Map<String, dynamic>))
          .toList(growable: false);
    }
    if (json is Iterable) {
      // Fallback if some sites return an array
      return json
          .map((e) => PostType.fromJson(e as Map<String, dynamic>))
          .toList(growable: false);
    }
    return const <PostType>[];
  }
}
