import 'package:wordpress_client/src/builders/request.dart';
import 'package:wordpress_client/src/responses/response_container.dart';
import 'package:wordpress_client/src/utilities/serializable_instance.dart';

import '../internal_requester.dart';

abstract class IDeleteOperation<T> {
  Future<ResponseContainer<T>> delete<T extends ISerializable<T>>({T typeResolver, Request<T> request, InternalRequester requesterClient});
}
