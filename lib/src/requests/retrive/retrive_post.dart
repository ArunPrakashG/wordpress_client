import '../../enums.dart';
import '../../utilities/helpers.dart';
import '../request_content.dart';
import '../request_interface.dart';

class RetrivePostRequest implements IRequest {
  RetrivePostRequest({
    this.context,
    this.password,
    required this.id,
  });

  RequestContext? context;
  String? password;
  int id;

  @override
  void build(RequestContent requestContent) {
    requestContent.queryParameters
      ..addIfNotNull('context', context?.name)
      ..addIfNotNull('password', password);

    requestContent.endpoint = 'posts/$id';
    requestContent.method = HttpMethod.get;
  }
}
