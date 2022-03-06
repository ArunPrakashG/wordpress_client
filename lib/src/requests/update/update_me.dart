import '../../../wordpress_client.dart';
import '../../utilities/helpers.dart';

class UpdateMeRequest implements IRequest {
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
  });

  String? username;
  String? displayName;
  String? firstName;
  String? lastName;
  String? email;
  String? password;
  String? url;
  String? description;
  String? locale;
  String? nickName;
  String? slug;
  List<int>? roles;

  @override
  void build(RequestContent requestContent) {
    requestContent.body
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
      ..addIfNotNull('roles', roles?.join(','));

    requestContent.endpoint = 'users/me';
    requestContent.method = HttpMethod.post;
  }
}
