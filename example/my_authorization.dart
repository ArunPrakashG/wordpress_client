import 'package:wordpress_client/wordpress_client.dart';

class CustomAuth extends IAuthorization {
  CustomAuth(
    String userName,
    String password, {
    WordpressCallback? callback,
  }) : super(userName, password, callback: callback);

  @override
  Future<bool> authorize() {
    throw UnimplementedError();
  }

  @override
  Future<String?> generateAuthUrl() {
    throw UnimplementedError();
  }

  @override
  Future<bool> isAuthenticated() {
    throw UnimplementedError();
  }

  @override
  bool get isValidAuth => throw UnimplementedError();

  @override
  Future<bool> validate() {
    throw UnimplementedError();
  }
}
