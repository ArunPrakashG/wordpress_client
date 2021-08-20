import 'package:dio/dio.dart';
import 'package:dio/src/cancel_token.dart';

import '../../authorization/authorization_base.dart';
import '../../enums.dart';
import '../../responses/user_response.dart';
import '../../utilities/callback.dart';
import '../../utilities/helpers.dart';
import '../../utilities/pair.dart';
import '../request.dart';
import '../request_builder_base.dart';

class UserCreateBuilder implements IQueryBuilder<UserCreateBuilder, User> {
  @override
  IAuthorization? authorization;

  @override
  Callback? callback;

  @override
  CancelToken? cancelToken;

  @override
  String? endpoint;

  @override
  List<Pair<String, String>>? headers;

  @override
  List<Pair<String, String>>? queryParameters;

  @override
  bool Function(User)? responseValidationDelegate;

  String? _username;
  String? _displayName;
  String? _firstName;
  String? _lastName;
  String? _email;
  String? _password;
  String? _url;
  String? _description;
  String? _locale;
  String? _nickname;
  String? _slug;
  List<String>? _roles;

  UserCreateBuilder withUserName(String username) {
    _username = username;
    return this;
  }

  UserCreateBuilder withDisplayName(String displayName) {
    _displayName = displayName;
    return this;
  }

  UserCreateBuilder withFirstName(String firstName) {
    _firstName = firstName;
    return this;
  }

  UserCreateBuilder withLastName(String lastName) {
    _lastName = lastName;
    return this;
  }

  UserCreateBuilder withEmail(String email) {
    _email = email;
    return this;
  }

  UserCreateBuilder withPassword(String password) {
    _password = password;
    return this;
  }

  UserCreateBuilder withUrl(String url) {
    _url = url;
    return this;
  }

  UserCreateBuilder withDescription(String description) {
    _description = description;
    return this;
  }

  UserCreateBuilder withLocale(Locale locale) {
    _locale = locale.toString().split('.').last;
    return this;
  }

  UserCreateBuilder withNickname(String nickname) {
    _nickname = nickname;
    return this;
  }

  UserCreateBuilder withSlug(String slug) {
    _slug = slug;
    return this;
  }

  UserCreateBuilder withRoles(Iterable<String> roles) {
    _roles ??= [];
    _roles!.addAll(roles);
    return this;
  }

  @override
  Request<User> build() {
    return Request<User>(
      endpoint,
      callback: callback,
      httpMethod: HttpMethod.POST,
      validationDelegate: responseValidationDelegate,
      cancelToken: cancelToken,
      authorization: authorization,
      headers: headers,
      formBody: FormData.fromMap(_parseParameters()),
    );
  }

  Map<String, String?> _parseParameters() {
    return {
      'username': _username,
      'email': _email,
      if (!isNullOrEmpty(_displayName)) 'name': _displayName,
      if (!isNullOrEmpty(_firstName)) 'first_name': _firstName,
      if (!isNullOrEmpty(_lastName)) 'last_name': _lastName,
      if (!isNullOrEmpty(_url)) 'url': _url,
      if (!isNullOrEmpty(_description)) 'description': _description,
      if (!isNullOrEmpty(_locale)) 'locale': _locale,
      if (!isNullOrEmpty(_nickname)) 'nickname': _nickname,
      if (!isNullOrEmpty(_slug)) 'slug': _slug,
      if (!isNullOrEmpty(_password)) 'password': _password,
      if (_roles != null && _roles!.isNotEmpty) 'roles': _roles!.join(','),
    };
  }

  @override
  UserCreateBuilder initializeWithDefaultValues() {
    return this;
  }

  @override
  UserCreateBuilder withAuthorization(IAuthorization auth) {
    authorization = auth;
    return this;
  }

  @override
  UserCreateBuilder withCallback(Callback requestCallback) {
    callback = requestCallback;
    return this;
  }

  @override
  UserCreateBuilder withCancellationToken(CancelToken token) {
    cancelToken = token;
    return this;
  }

  @override
  UserCreateBuilder withEndpoint(String newEndpoint) {
    endpoint = newEndpoint;
    return this;
  }

  @override
  UserCreateBuilder withHeaders(Iterable<Pair<String, String>> customHeaders) {
    headers ??= [];
    headers!.addAll(customHeaders);
    return this;
  }

  @override
  UserCreateBuilder withQueryParameters(Iterable<Pair<String, String>> extraQueryParameters) {
    queryParameters ??= [];
    queryParameters!.addAll(extraQueryParameters);
    return this;
  }

  @override
  UserCreateBuilder withResponseValidationOverride(bool Function(User) responseDelegate) {
    responseValidationDelegate = responseDelegate;
    return this;
  }
}
