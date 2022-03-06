import '../../enums.dart';
import '../../utilities/helpers.dart';
import '../request_content.dart';
import '../request_interface.dart';

class RetriveTagRequest implements IRequest {
  RetriveTagRequest({
    this.context,
    required this.id,
  });

  FilterContext? context;
  int id;

  @override
  void build(RequestContent requestContent) {
    requestContent.queryParameters.addIfNotNull('context', context?.name);

    requestContent.endpoint = 'tags/$id';
    requestContent.method = HttpMethod.get;
  }
}
