import '../../../wordpress_client.dart';
import '../../utilities/helpers.dart';
import '../request_content.dart';
import '../request_interface.dart';

class CreateUserRequest implements IRequest {
  CreateUserRequest({
    required this.username,
    this.displayName,
    this.firstName,
    this.lastName,
    required this.email,
    this.password,
    this.url,
    this.description,
    this.locale,
    this.nickName,
    this.slug,
    this.roles,
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
  void build(RequestContent requestContent) {
    requestContent.body
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

    requestContent.endpoint = 'users';
    requestContent.method = HttpMethod.post;
  }
}
