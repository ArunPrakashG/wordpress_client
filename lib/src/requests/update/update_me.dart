import '../../../wordpress_client.dart';

final class UpdateMeRequest extends IRequest {
  UpdateMeRequest({
    this.username,
    this.displayName,
    this.firstName,
    this.lastName,
    this.email,
    this.password,
    this.url,
    this.description,
    this.locale,
    this.nickName,
    this.slug,
    this.roles,
    this.rolesNames,
    super.cancelToken,
    super.authorization,
    super.events,
    super.receiveTimeout,
    super.requireAuth = true,
    super.sendTimeout,
    super.validator,
    super.extra,
    super.headers,
    super.queryParameters,
  });

  /// Login name for the user.
  String? username;
  /// Display name for the user.
  String? displayName;
  /// First name for the user.
  String? firstName;
  /// Last name for the user.
  String? lastName;
  /// The email address for the user.
  String? email;
  /// The user's password.
  String? password;
  /// URL of the user.
  String? url;
  /// Description of the user.
  String? description;
  /// Locale for the user.
  String? locale;
  /// The nickname for the user.
  String? nickName;
  /// An alphanumeric identifier for the user.
  String? slug;
  /// Legacy list of role IDs (discouraged). Prefer rolesNames.
  List<int>? roles;
  /// Role slugs to assign to the current user.
  List<String>? rolesNames;

  @override
  WordpressRequest build(Uri baseUrl) {
    final body = <String, dynamic>{}
      ..addIfNotNull('username', username)
      ..addIfNotNull('email', email)
      ..addIfNotNull('name', displayName)
      ..addIfNotNull('first_name', firstName)
      ..addIfNotNull('last_name', lastName)
      ..addIfNotNull('url', url)
      ..addIfNotNull('description', description)
      ..addIfNotNull('locale', locale)
      ..addIfNotNull('nickname', nickName)
      ..addIfNotNull('slug', slug)
      ..addIfNotNull('password', password)
      // Prefer role names array per REST docs; fallback to legacy comma string if provided.
      ..addIfNotNull('roles', rolesNames ?? roles?.join(','))
      ..addAllIfNotNull(extra);

    return WordpressRequest(
      body: body,
      method: HttpMethod.post,
      headers: headers,
      queryParameters: queryParameters,
      url: RequestUrl.relativeParts(const ['users', 'me']),
      requireAuth: requireAuth,
      cancelToken: cancelToken,
      authorization: authorization,
      events: events,
      receiveTimeout: receiveTimeout,
      sendTimeout: sendTimeout,
      validator: validator,
    );
  }
}
