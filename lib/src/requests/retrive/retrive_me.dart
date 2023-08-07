import '../../enums.dart';
import '../../utilities/helpers.dart';
import '../../utilities/request_url.dart';
import '../request_interface.dart';
import '../wordpress_request.dart';

final class RetriveMeRequest extends IRequest {
  RetriveMeRequest({
    this.context = RequestContext.view,
    super.cancelToken,
    super.authorization,
    super.events,
    super.receiveTimeout,
    super.requireAuth = true,
    super.sendTimeout,
    super.validator,
  });

  RequestContext? context;

  @override
  WordpressRequest build(Uri baseUrl) {
    final queryParameters = <String, String>{}
      ..addIfNotNull('context', context?.name);

    return WordpressRequest(
      method: HttpMethod.get,
      url: RequestUrl.relativeParts(const ['users', 'me']),
      queryParameters: queryParameters,
      requireAuth: requireAuth || context == RequestContext.edit,
      cancelToken: cancelToken,
      authorization: authorization,
      events: events,
      receiveTimeout: receiveTimeout,
      sendTimeout: sendTimeout,
      validator: validator,
    );
  }
}
