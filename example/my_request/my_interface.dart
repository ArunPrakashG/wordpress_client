import 'package:wordpress_client/wordpress_client.dart';

import 'my_request.dart';
import 'my_response.dart';

final class MyInterface extends IRequestInterface
    with ListOperation<MyResponse, MyRequest> {}
