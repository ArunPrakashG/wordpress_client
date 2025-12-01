import 'dart:async';

import 'package:wordpress_client/wordpress_client.dart';

final class MyRequest extends IRequest {
  MyRequest({
    this.context,
    this.page = 1,
    this.perPage = 10,
    super.cancelToken,
  });

  RequestContext? context;
  int page = 1;
  int perPage = 10;
  String? search;

  @override
  FutureOr<WordpressRequest> build(Uri baseUrl) {
    // addIfNotNull is an extension on Map class.
    // It helps to easily add a value to a map if it is not null.
    final queryParameters = <String, dynamic>{}
      ..addIfNotNull('context', context?.name)
      ..addIfNotNull('page', page)
      ..addIfNotNull('per_page', perPage);

    return WordpressRequest(
      // Note that we can provide a full url to the request by using RequestUrl.absolute factory constructor.
      // Note that you cannot change the host of the URL. In case if there is a change in host,
      // the new host is replaced by using the Base Url provided on the WordpressClient instance.
      url: RequestUrl.absoluteMerge(
        Uri(path: 'wp-json/custom_path/my_path/my_endpoint'),
        baseUrl,
      ),
      queryParameters: queryParameters,
      method: HttpMethod.get,
      cancelToken: cancelToken,
      events: events,
      requireAuth: requireAuth,
      authorization: authorization,
      validator: validator,
      sendTimeout: sendTimeout,
      receiveTimeout: receiveTimeout,
    );
  }
}
