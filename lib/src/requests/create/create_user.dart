import '../../../wordpress_client.dart';

final class CreateUserRequest extends IRequest {
  CreateUserRequest({
    required this.username,
    required this.email,
    this.displayName,
    this.firstName,
    this.lastName,
    this.password,
    this.url,
    this.description,
    this.locale,
    this.nickName,
    this.slug,
    this.roles,
    super.cancelToken,
    super.authorization,
    super.events,
    super.receiveTimeout,
    super.requireAuth,
    super.sendTimeout,
    super.validator,
  });

  String username;
  String? displayName;
  String? firstName;
  String? lastName;
  String email;
  String? password;
  String? url;
  String? description;
  String? locale;
  String? nickName;
  String? slug;
  List<String>? roles;

  @override
  WordpressRequest build(Uri baseUrl) {
    final body = <String, dynamic>{}
      ..addIfNotNull('username', username)
      ..addIfNotNull('email', email)
      ..addIfNotNull('name', displayName)
      ..addIfNotNull('first_name', firstName)
      ..addIfNotNull('last_name', lastName)
      ..addIfNotNull('password', password)
      ..addIfNotNull('url', url)
      ..addIfNotNull('description', description)
      ..addIfNotNull('locale', locale)
      ..addIfNotNull('nickname', nickName)
      ..addIfNotNull('slug', slug)
      ..addIfNotNull('roles', roles?.join(','));

    return WordpressRequest(
      body: body,
      method: HttpMethod.post,
      url: RequestUrl.relative('users'),
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
