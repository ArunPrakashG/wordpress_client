import '../../enums.dart';
import '../../utilities/helpers.dart';
import '../request_content.dart';
import '../request_interface.dart';

class RetriveMediaRequest implements IRequest {
  RetriveMediaRequest({
    this.context = FilterContext.VIEW,
    required this.id,
  });

  FilterContext? context;
  int id;

  @override
  void build(RequestContent requestContent) {
    requestContent.queryParameters.addIfNotNull('context', context?.name);
    requestContent.endpoint = 'media/$id';
    requestContent.method = HttpMethod.GET;
  }
}
