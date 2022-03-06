import '../../../wordpress_client.dart';
import '../../utilities/helpers.dart';
import '../request_content.dart';
import '../request_interface.dart';

class UpdateUserRequest implements IRequest {
  UpdateUserRequest({
    required this.username,
    this.name,
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
    required this.id,
  });

  String username;
  String? name;
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
  int id;

  @override
  void build(RequestContent requestContent) {
    requestContent.body
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
      ..addIfNotNull('roles', roles?.join(','));

    requestContent.endpoint = 'users/$id';
    requestContent.method = HttpMethod.POST;
  }
}
