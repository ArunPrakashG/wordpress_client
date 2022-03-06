import 'dart:async';

import 'package:dio/dio.dart';

import '../../utilities/callback.dart';
import '../../utilities/helpers.dart';
import '../authorization_base.dart';

/// The most basic authentication system using username and password.
///
/// Implemented on basis of https://github.com/WP-API/Basic-Auth wordpress plugin.
///
/// Make sure to only use this method for testing purposes as this isn't secure.
class BasicAuth extends IAuthorization {
  BasicAuth(String? username, String? password, {Callback? callback})
      : super(username, password, callback: callback);

  bool _hasInit = false;

  static const String scheme = 'Basic';

  @override
  Future<bool> authorize() async {
    return true;
  }

  @override
  Future<String?> generateAuthUrl() async {
    return '$scheme ${base64Encode('$userName:$password')}';
  }

  @override
  Future<bool> init(Dio? client) async {
    if (_hasInit) {
      return true;
    }

    return _hasInit = true;
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
}
