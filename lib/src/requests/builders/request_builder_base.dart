import 'package:dio/dio.dart';
import 'package:wordpress_client/src/utilities/callback.dart';
import 'package:wordpress_client/src/utilities/pair.dart';
import 'package:wordpress_client/src/wordpress_authorization.dart';

abstract class IRequestBuilder<TRequestType, YReturnType> {
  bool Function(Map<String, dynamic>) responseValidationDelegate;
  WordpressAuthorization authorization;
  List<Pair<String, String>> headers;
  List<Pair<String, String>> queryParameters;
  CancelToken cancelToken;
  String endpoint;

  TRequestType initializeWithDefaultValues();

  TRequestType withAuthorization(WordpressAuthorization auth);

  TRequestType withHeaders(Iterable<Pair<String, String>> customHeaders);

  TRequestType withQueryParameters(Iterable<Pair<String, String>> extraQueryParameters);

  TRequestType withCancellationToken(CancelToken token);

  TRequestType withEndpoint(String newEndpoint);

  TRequestType withResponseValidationOverride(bool Function(Map<String, dynamic>) responseDelegate);

  YReturnType build();
}
