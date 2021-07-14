import 'package:wordpress_client/src/requests/request.dart';
import 'package:wordpress_client/src/responses/response_container.dart';

import '../internal_requester.dart';

abstract class IRetriveOperation<T> {
  Future<ResponseContainer<T>> retrive<T>({Request request, InternalRequester requesterClient});
}
