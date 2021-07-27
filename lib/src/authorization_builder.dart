import 'authorization.dart';
import 'enums.dart';

class AuthorizationBuilder {
  String _userName;
  String _password;
  String _jwtToken;
  AuthorizationType _type;

  AuthorizationBuilder withUserName(String userName) {
    _userName = userName;
    return this;
  }

  AuthorizationBuilder withPassword(String password) {
    _password = password;
    return this;
  }

  AuthorizationBuilder withJwtToken(String jwtToken) {
    _jwtToken = jwtToken;
    return this;
  }

  AuthorizationBuilder withType(AuthorizationType type) {
    _type = type;
    return this;
  }

  Authorization build() => Authorization(userName: _userName, password: _password, encryptedToken: _jwtToken, authType: _type);
}
