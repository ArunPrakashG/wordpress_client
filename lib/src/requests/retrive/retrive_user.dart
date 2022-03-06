import '../../enums.dart';
import '../../utilities/helpers.dart';
import '../request_content.dart';
import '../request_interface.dart';

class RetriveUserRequest implements IRequest {
  RetriveUserRequest({
    this.context,
    required this.id,
  });

  FilterContext? context;
  int id;

  @override
  void build(RequestContent requestContent) {
    requestContent.queryParameters.addIfNotNull('context', context?.name);

    requestContent.endpoint = 'users/$id';
    requestContent.method = HttpMethod.GET;
  }
}
