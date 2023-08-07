import 'dart:async';

import 'package:dio/dio.dart';

import '../../utilities/helpers.dart';
import '../authorization_base.dart';

/// The most basic authentication system using username and password.
///
/// Implemented on basis of https://github.com/WP-API/Basic-Auth wordpress plugin.
///
/// Make sure to only use this method for testing purposes as this isn't secure.
final class BasicAuth extends IAuthorization {
  BasicAuth({
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
  bool get isValidAuth => true;

  @override
  Future<bool> validate() async {
    return true;
  }

  @override
  void clientFactoryProvider(Dio client) {}

  @override
  String get scheme => 'Basic';
}
