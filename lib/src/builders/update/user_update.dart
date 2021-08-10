import 'package:dio/dio.dart';
import 'package:dio/src/cancel_token.dart';

import '../../authorization.dart';
import '../../enums.dart';
import '../../responses/user_response.dart';
import '../../utilities/callback.dart';
import '../../utilities/helpers.dart';
import '../../utilities/pair.dart';
import '../request.dart';
import '../request_builder_base.dart';

class UserUpdateBuilder implements IQueryBuilder<UserUpdateBuilder, User> {
  @override
  Authorization? authorization;

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

  UserUpdateBuilder withId(int? id) {
    endpoint = '$endpoint/$id';
    return this;
  }

  UserUpdateBuilder withUserName(String username) {
    _username = username;
    return this;
  }

  UserUpdateBuilder withDisplayName(String displayName) {
    _displayName = displayName;
    return this;
  }

  UserUpdateBuilder withFirstName(String firstName) {
    _firstName = firstName;
    return this;
  }

  UserUpdateBuilder withLastName(String lastName) {
    _lastName = lastName;
    return this;
  }

  UserUpdateBuilder withEmail(String email) {
    _email = email;
    return this;
  }

  UserUpdateBuilder withPassword(String password) {
    _password = password;
    return this;
  }

  UserUpdateBuilder withUrl(String url) {
    _url = url;
    return this;
  }

  UserUpdateBuilder withDescription(String description) {
    _description = description;
    return this;
  }

  UserUpdateBuilder withLocale(Locale locale) {
    _locale = locale.toString().split('.').last;
    return this;
  }

  UserUpdateBuilder withNickname(String nickname) {
    _nickname = nickname;
    return this;
  }

  UserUpdateBuilder withSlug(String slug) {
    _slug = slug;
    return this;
  }

  UserUpdateBuilder withRoles(Iterable<String> roles) {
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
  UserUpdateBuilder initializeWithDefaultValues() {
    return this;
  }

  @override
  UserUpdateBuilder withAuthorization(Authorization auth) {
    authorization = auth;
    return this;
  }

  @override
  UserUpdateBuilder withCallback(Callback requestCallback) {
    callback = requestCallback;
    return this;
  }

  @override
  UserUpdateBuilder withCancellationToken(CancelToken token) {
    cancelToken = token;
    return this;
  }

  @override
  UserUpdateBuilder withEndpoint(String newEndpoint) {
    endpoint = newEndpoint;
    return this;
  }

  @override
  UserUpdateBuilder withHeaders(Iterable<Pair<String, String>> customHeaders) {
    headers ??= [];
    headers!.addAll(customHeaders);
    return this;
  }

  @override
  UserUpdateBuilder withQueryParameters(Iterable<Pair<String, String>> extraQueryParameters) {
    queryParameters ??= [];
    queryParameters!.addAll(extraQueryParameters);
    return this;
  }

  @override
  UserUpdateBuilder withResponseValidationOverride(bool Function(User) responseDelegate) {
    responseValidationDelegate = responseDelegate;
    return this;
  }
}
