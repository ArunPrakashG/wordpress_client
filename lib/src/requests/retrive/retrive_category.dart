import '../../enums.dart';
import '../../utilities/helpers.dart';
import '../request_content.dart';
import '../request_interface.dart';

class RetriveCategoryRequest implements IRequest {
  RetriveCategoryRequest({
    this.context,
    required this.id,
  });

  RequestContext? context;
  int id;

  @override
  void build(RequestContent requestContent) {
    requestContent.queryParameters.addIfNotNull('context', context?.name);

    requestContent.endpoint = 'categories/$id';
    requestContent.method = HttpMethod.get;
  }
}
