import '../../../wordpress_client.dart';

class DeleteMeRequest implements IRequest {
  DeleteMeRequest({
    this.force,
    required this.reassign,
  });

  bool? force;
  int reassign;

  @override
  void build(RequestContent requestContent) {
    requestContent.body
      ..addIfNotNull('force', force)
      ..addIfNotNull('reassign', reassign);

    requestContent.endpoint = 'users/me';
    requestContent.method = HttpMethod.delete;
  }
}
