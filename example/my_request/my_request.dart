import 'package:wordpress_client/wordpress_client.dart';

class MyRequest extends IRequest {
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
  void build(RequestContent requestContent) {
    // addIfNotNull is an extension on Map class.
    // It helps to easily add a value to a map if it is not null.
    requestContent.queryParameters
      ..addIfNotNull('context', context?.name)
      ..addIfNotNull('page', page)
      ..addIfNotNull('per_page', perPage);

    requestContent.endpoint = 'my_endpoint';

    // Path can be left at default. It will use the path passed in the constructor of [WordpressClient]
    requestContent.path = 'wp-json/custom_path/my_path/';
    requestContent.method = HttpMethod.get;
  }
}
