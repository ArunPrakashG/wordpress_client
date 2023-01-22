import 'package:wordpress_client/operations.dart';
import 'package:wordpress_client/wordpress_client.dart';

import 'my_request.dart';
import 'my_response.dart';

class MyInterface extends IWordpressService
    with ListMixin<MyResponse, MyRequest> {}
