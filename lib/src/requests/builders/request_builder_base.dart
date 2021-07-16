import 'package:dio/dio.dart';
import 'package:wordpress_client/src/utilities/callback.dart';

import '../../utilities/pair.dart';
import '../../wordpress_authorization.dart';
import '../request.dart';

abstract class IRequestBuilder<TRequestType, XResponseType> {
  bool Function(XResponseType) responseValidationDelegate;
  WordpressAuthorization authorization;
  List<Pair<String, String>> headers;
  List<Pair<String, String>> queryParameters;
  CancelToken cancelToken;
  Callback callback;
  String endpoint;

  TRequestType initializeWithDefaultValues();

  TRequestType withAuthorization(WordpressAuthorization auth);

  TRequestType withHeaders(Iterable<Pair<String, String>> customHeaders);

  TRequestType withQueryParameters(Iterable<Pair<String, String>> extraQueryParameters);

  TRequestType withCancellationToken(CancelToken token);

  TRequestType withEndpoint(String newEndpoint);

  TRequestType withCallback(Callback requestCallback);

  TRequestType withResponseValidationOverride(bool Function(XResponseType) responseDelegate);

  Request<XResponseType> build();
}
