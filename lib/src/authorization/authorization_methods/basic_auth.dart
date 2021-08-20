import 'dart:async';

import 'package:dio/src/dio.dart';

import '../../utilities/callback.dart';
import '../../utilities/helpers.dart';
import '../authorization_base.dart';

class BasicAuth extends IAuthorization {
  BasicAuth(String? username, String? password, {Callback? callback}) : super(username, password, callback: callback);

  bool _hasInit = false;

  static final String scheme = 'Basic';

  @override
  FutureOr<bool> authorize() {
    return true;
  }

  @override
  FutureOr<String?> generateAuthUrl() {
    return '$scheme ${base64Encode('$userName:$password')}';
  }

  @override
  FutureOr<bool> init(Dio? client) {
    if (_hasInit) {
      return true;
    }

    return _hasInit = true;
  }

  @override
  FutureOr<bool> isAuthenticated() {
    return true;
  }

  @override
  bool get isValidAuth => true;

  @override
  FutureOr<bool> validate() {
    return true;
  }
}
