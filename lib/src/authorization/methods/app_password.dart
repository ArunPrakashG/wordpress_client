import 'package:dio/dio.dart';

import '../../../wordpress_client.dart';
import '../../utilities/helpers.dart';

/// Authentication using Application Passwords which are supported on all Wordpress installations version 5.6 or higher.
final class AppPasswordAuth extends IAuthorization {
  AppPasswordAuth({
    required super.userName,
    required super.password,
    super.events,
  });

  @override
  Future<bool> authorize() async {
    return true;
  }

  @override
  Future<String?> generateAuthUrl() async {
    return '$scheme ${base64Encode('$userName:$password')}';
  }

  @override
  Future<bool> isAuthenticated() async {
    return true;
  }

  @override
  bool get isValidAuth =>
      super.password.isNotEmpty && super.userName.isNotEmpty;

  @override
  Future<bool> validate() async {
    return true;
  }

  @override
  void clientFactoryProvider(Dio client) {}

  @override
  String get scheme => 'Basic';
}
