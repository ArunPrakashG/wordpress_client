import 'enums.dart';
import 'utilities/helpers.dart';

class AuthorizationContainer {
  final String userName;
  final String password;
  final String jwtToken;
  final AuthorizationType authType;

  AuthorizationContainer({
    this.userName,
    this.password,
    this.jwtToken,
    this.authType,
  });

  bool get isDefault => isNullOrEmpty(userName) || isNullOrEmpty(password);
}
