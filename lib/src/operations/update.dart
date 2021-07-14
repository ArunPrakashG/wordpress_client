import 'package:wordpress_client/src/requests/request.dart';
import 'package:wordpress_client/src/responses/response_container.dart';

import '../internal_requester.dart';

abstract class IUpdateOperation<T> {
  Future<ResponseContainer<T>> update<T>({Request request, InternalRequester requesterClient});
}
