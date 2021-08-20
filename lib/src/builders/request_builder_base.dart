import 'package:dio/dio.dart';

import '../authorization/authorization_base.dart';
import '../utilities/callback.dart';
import '../utilities/pair.dart';
import 'request.dart';

abstract class IQueryBuilder<TRequestType, YResponseType> {
  bool Function(YResponseType)? responseValidationDelegate;
  IAuthorization? authorization;
  List<Pair<String, String>>? headers;
  List<Pair<String, String>>? queryParameters;
  CancelToken? cancelToken;
  Callback? callback;
  String? endpoint;

  TRequestType initializeWithDefaultValues();

  TRequestType withAuthorization(IAuthorization auth);

  TRequestType withHeaders(Iterable<Pair<String, String>> customHeaders);

  TRequestType withQueryParameters(Iterable<Pair<String, String>> extraQueryParameters);

  TRequestType withCancellationToken(CancelToken token);

  TRequestType withEndpoint(String newEndpoint);

  TRequestType withCallback(Callback requestCallback);

  TRequestType withResponseValidationOverride(bool Function(YResponseType) responseDelegate);

  Request<YResponseType> build();
}
