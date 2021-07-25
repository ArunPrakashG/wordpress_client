import 'enums.dart';
import 'utilities/helpers.dart';

class Authorization {
  final String userName;
  final String password;
  String jwtToken;
  final AuthorizationType authType;
  bool isValidatedOnce;
  String authString;

  Authorization({
    this.userName,
    this.password,
    this.jwtToken = null,
    this.authType,
  });

  bool get isDefault => isNullOrEmpty(userName) || isNullOrEmpty(password);
}
