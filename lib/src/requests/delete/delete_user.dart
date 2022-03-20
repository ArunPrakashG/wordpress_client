import '../../../wordpress_client.dart';

class DeleteUserRequest implements IRequest {
  DeleteUserRequest({
    this.force,
    required this.reassign,
    required this.id,
  });

  bool? force;
  int reassign;
  int id;

  @override
  void build(RequestContent requestContent) {
    requestContent.body
      ..addIfNotNull('force', force)
      ..addIfNotNull('reassign', reassign);

    requestContent.endpoint = 'users/$id';
    requestContent.method = HttpMethod.delete;
  }
}
