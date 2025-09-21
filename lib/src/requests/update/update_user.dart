import '../../../wordpress_client.dart';

final class UpdateUserRequest extends IRequest {
  UpdateUserRequest({
    required this.id,
    this.username,
    this.email,
    this.name,
    this.firstName,
    this.lastName,
    this.password,
    this.url,
    this.description,
    this.locale,
    this.nickName,
    this.slug,
    this.roles,
    this.rolesList,
    this.meta,
    super.cancelToken,
    super.authorization,
    super.events,
    super.receiveTimeout,
    super.requireAuth,
    super.sendTimeout,
    super.validator,
    super.extra,
    super.headers,
    super.queryParameters,
  });

  /// Login name for the user.
  String? username;

  /// Display name for the user.
  String? name;

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

  /// Roles assigned to the user (CSV string).
  List<String>? roles;

  /// Alternative to roles: provide array instead of CSV
  List<String>? rolesList;

  /// Meta fields per Handbook
  Map<String, dynamic>? meta;

  /// Unique identifier for the user.
  int id;

  @override
  WordpressRequest build(Uri baseUrl) {
    final body = <String, dynamic>{}
      ..addIfNotNull('username', username)
      ..addIfNotNull('name', name)
      ..addIfNotNull('email', email)
      ..addIfNotNull('first_name', firstName)
      ..addIfNotNull('last_name', lastName)
      ..addIfNotNull('url', url)
      ..addIfNotNull('description', description)
      ..addIfNotNull('locale', locale)
      ..addIfNotNull('nickname', nickName)
      ..addIfNotNull('slug', slug)
      ..addIfNotNull('password', password)
      ..addIfNotNull('roles', rolesList ?? roles)
      ..addIfNotNull('meta', meta)
      ..addAllIfNotNull(extra);

    return WordpressRequest(
      body: body,
      method: HttpMethod.post,
      headers: headers,
      queryParameters: queryParameters,
      url: RequestUrl.relativeParts(['users', id]),
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
