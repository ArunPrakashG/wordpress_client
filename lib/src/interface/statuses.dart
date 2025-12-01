import '../../wordpress_client.dart';

/// Interface for Post Statuses (/wp/v2/statuses)
/// Note: The list endpoint returns an object map keyed by slug.
final class StatusesInterface extends IRequestInterface
    with
        CustomOperation<List<PostStatus>, ListStatusRequest>,
        RetrieveOperation<PostStatus, RetrieveStatusRequest> {
  @override
  List<PostStatus> decode(dynamic json) {
    if (json is Map<String, dynamic>) {
      return json.values
          .map<PostStatus>(
            (e) => PostStatus.fromJson(e as Map<String, dynamic>),
          )
          .toList(growable: false);
    }
    if (json is Iterable) {
      return json
          .map((e) => PostStatus.fromJson(e as Map<String, dynamic>))
          .toList(growable: false);
    }
    return const <PostStatus>[];
  }
}
