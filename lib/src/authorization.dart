import 'enums.dart';
import 'utilities/helpers.dart';

class Authorization {
  final String userName;
  final String password;
  final String jwtToken;
  final AuthorizationType authType;

  Authorization({
    this.userName,
    this.password,
    this.jwtToken,
    this.authType,
  });

  bool get isDefault => isNullOrEmpty(userName) || isNullOrEmpty(password);
}
