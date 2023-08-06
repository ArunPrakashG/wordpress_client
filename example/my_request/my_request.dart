import 'dart:async';

import 'package:wordpress_client/src/utilities/request_url.dart';
import 'package:wordpress_client/wordpress_client.dart';

final class MyRequest extends IRequest {
  MyRequest({
    this.context,
    this.page = 1,
    this.perPage = 10,
  });

  RequestContext? context;
  int page = 1;
  int perPage = 10;
  String? search;

  @override
  FutureOr<WordpressRequest> build(Uri baseUrl) {
    // addIfNotNull is an extension on Map class.
    // It helps to easily add a value to a map if it is not null.
    final queryParameters = <String, String>{}
      ..addIfNotNull('context', context?.name)
      ..addIfNotNull('page', page)
      ..addIfNotNull('per_page', perPage);

    return WordpressRequest(
      url: RequestUrl.absoluteMerge(
        Uri(path: 'wp-json/custom_path/my_path/my_endpoint'),
        baseUrl,
      ),
      queryParams: queryParameters,
      method: HttpMethod.get,
    );
  }
}
