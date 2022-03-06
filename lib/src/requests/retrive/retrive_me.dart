import '../../enums.dart';
import '../../utilities/helpers.dart';
import '../request_content.dart';
import '../request_interface.dart';

class RetriveMeRequest implements IRequest {
  RetriveMeRequest({
    this.context = FilterContext.VIEW,
  });

  FilterContext? context;

  @override
  void build(RequestContent requestContent) {
    requestContent.queryParameters.addIfNotNull('context', context?.name);
    requestContent.endpoint = 'users/me';
    requestContent.method = HttpMethod.GET;
  }
}
