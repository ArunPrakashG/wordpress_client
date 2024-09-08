import 'package:dio/dio.dart';

import '../../wordpress_client.dart';

abstract base class IQueryBuilder<T extends IQueryBuilder<T>> extends IRequest {
  final Map<String, dynamic> _queryParameters = {};
  final Map<String, dynamic> _body = {};
  final Map<String, String> _headers = {};
  final Map<String, dynamic> _extra = {};
  bool _requireAuth = false;
  CancelToken? _cancelToken;
  IAuthorization? _authorization;
  WordpressEvents? _events;
  Duration _receiveTimeout = const Duration(seconds: 30);
  Duration _sendTimeout = const Duration(seconds: 30);
  ValidatorCallback? _validator;

  IQueryBuilder<T> withQueryParameter(String key, dynamic value) {
    _queryParameters[key] = value;
    return this;
  }

  IQueryBuilder<T> withBodyParameter(String key, dynamic value) {
    _body[key] = value;
    return this;
  }

  IQueryBuilder<T> withHeader(String key, String value) {
    _headers[key] = value;
    return this;
  }

  IQueryBuilder<T> withExtra(String key, dynamic value) {
    _extra[key] = value;
    return this;
  }

  IQueryBuilder<T> withAuthRequired(bool value) {
    _requireAuth = value;
    return this;
  }

  IQueryBuilder<T> withCancelToken(CancelToken token) {
    _cancelToken = token;
    return this;
  }

  IQueryBuilder<T> withAuthorization(IAuthorization auth) {
    _authorization = auth;
    return this;
  }

  IQueryBuilder<T> withEvents(WordpressEvents events) {
    _events = events;
    return this;
  }

  IQueryBuilder<T> withReceiveTimeout(Duration timeout) {
    _receiveTimeout = timeout;
    return this;
  }

  IQueryBuilder<T> withSendTimeout(Duration timeout) {
    _sendTimeout = timeout;
    return this;
  }

  IQueryBuilder<T> withValidator(ValidatorCallback validator) {
    _validator = validator;
    return this;
  }

  WordpressRequest build(Uri baseUrl);
}
