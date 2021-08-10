import 'package:dio/src/cancel_token.dart';

import '../../authorization.dart';
import '../../enums.dart';
import '../../responses/user_response.dart';
import '../../utilities/callback.dart';
import '../../utilities/helpers.dart';
import '../../utilities/pair.dart';
import '../request.dart';
import '../request_builder_base.dart';

class MeUpdateBuilder implements IQueryBuilder<MeUpdateBuilder, User> {
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
  List<int>? _roles;

  MeUpdateBuilder withUserName(String username) {
    _username = username;
    return this;
  }

  MeUpdateBuilder withDisplayName(String displayName) {
    _displayName = displayName;
    return this;
  }

  MeUpdateBuilder withFirstName(String firstName) {
    _firstName = firstName;
    return this;
  }

  MeUpdateBuilder withLastName(String lastName) {
    _lastName = lastName;
    return this;
  }

  MeUpdateBuilder withEmail(String email) {
    _email = email;
    return this;
  }

  MeUpdateBuilder withPassword(String password) {
    _password = password;
    return this;
  }

  MeUpdateBuilder withUrl(String url) {
    _url = url;
    return this;
  }

  MeUpdateBuilder withDescription(String description) {
    _description = description;
    return this;
  }

  MeUpdateBuilder withLocale(Locale locale) {
    _locale = locale.toString().split('.').last;
    return this;
  }

  MeUpdateBuilder withNickname(String nickname) {
    _nickname = nickname;
    return this;
  }

  MeUpdateBuilder withSlug(String slug) {
    _slug = slug;
    return this;
  }

  MeUpdateBuilder withRoles(Iterable<int> roles) {
    _roles ??= [];
    _roles!.addAll(roles);
    return this;
  }

  @override
  Request<User> build() {
    endpoint = '$endpoint/me';
    return Request<User>(
      endpoint,
      callback: callback,
      httpMethod: HttpMethod.POST,
      validationDelegate: responseValidationDelegate,
      cancelToken: cancelToken,
      authorization: authorization,
      headers: headers,
      formBody: _parseQueryParameters(),
    );
  }

  Map<String, String?> _parseQueryParameters() {
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
  MeUpdateBuilder initializeWithDefaultValues() {
    return this;
  }

  @override
  MeUpdateBuilder withAuthorization(Authorization auth) {
    authorization = auth;
    return this;
  }

  @override
  MeUpdateBuilder withCallback(Callback requestCallback) {
    callback = requestCallback;
    return this;
  }

  @override
  MeUpdateBuilder withCancellationToken(CancelToken token) {
    cancelToken = token;
    return this;
  }

  @override
  MeUpdateBuilder withEndpoint(String newEndpoint) {
    endpoint = newEndpoint;
    return this;
  }

  @override
  MeUpdateBuilder withHeaders(Iterable<Pair<String, String>> customHeaders) {
    headers ??= [];
    headers!.addAll(customHeaders);
    return this;
  }

  @override
  MeUpdateBuilder withQueryParameters(Iterable<Pair<String, String>> extraQueryParameters) {
    queryParameters ??= [];
    queryParameters!.addAll(extraQueryParameters);
    return this;
  }

  @override
  MeUpdateBuilder withResponseValidationOverride(bool Function(User) responseDelegate) {
    responseValidationDelegate = responseDelegate;
    return this;
  }
}
