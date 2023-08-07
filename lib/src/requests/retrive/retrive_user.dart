import '../../enums.dart';
import '../../utilities/helpers.dart';
import '../../utilities/request_url.dart';
import '../request_interface.dart';
import '../wordpress_request.dart';

final class RetriveUserRequest extends IRequest {
  RetriveUserRequest({
    this.context,
    required this.id,
    super.cancelToken,
    super.authorization,
    super.events,
    super.receiveTimeout,
    super.requireAuth = false,
    super.sendTimeout,
    super.validator,
  });

  RequestContext? context;
  int id;

  @override
  WordpressRequest build(Uri baseUrl) {
    final queryParameters = <String, String>{}
      ..addIfNotNull('context', context?.name);

    return WordpressRequest(
      method: HttpMethod.get,
      url: RequestUrl.relativeParts(['users', id]),
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
