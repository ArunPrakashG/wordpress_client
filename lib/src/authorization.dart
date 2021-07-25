import 'enums.dart';
import 'utilities/helpers.dart';

class Authorization {
  final String userName;
  final String password;
  final String jwtToken;
  final AuthorizationType authType;
  bool isValidatedOnce;

  Authorization({
    this.userName,
    this.password,
    this.jwtToken = null,
    this.authType,
  });

  bool get isDefault => isNullOrEmpty(userName) || isNullOrEmpty(password);
}
