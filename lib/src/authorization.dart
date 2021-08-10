import 'enums.dart';
import 'utilities/helpers.dart';

class Authorization {
  final String? userName;
  final String? password;
  String? encryptedToken;
  final AuthorizationType? authType;
  bool isValidatedOnce = false;
  String? authString;

  Authorization({
    this.userName,
    this.password,
    this.encryptedToken = null,
    this.authType,
  });

  bool get isDefault => isNullOrEmpty(userName) || isNullOrEmpty(password);
}
