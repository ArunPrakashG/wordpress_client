import 'dart:async';

import 'package:dio/dio.dart';

import '../utilities/callback.dart';
import '../utilities/helpers.dart';

/// Base class for all authorization types.
///
/// To create a custom authorization system, simply extend from this abstract class, then implement its functions
/// then pass base class to Authorization builder function!
///
/// There is no storage system to store the nounce inside the client, therefore the base class has the responsibility to handle this mechanism.
abstract class IAuthorization {
  /// Default constructor, used to pass username and password.
  IAuthorization(this.userName, this.password, {this.callback});

  /// The username
  String? userName;

  /// The password
  String? password;

  // A Callback, if assigned, will help with logging of data of requests send and received on this instance.
  Callback? callback;

  /// Gets if this authorization instance has valid authentication nounce. (token/encryptedToken)
  bool get isValidAuth;

  /// Gets if this is an invalid or default authorization instance without username or password fields.
  bool get isDefault => isNullOrEmpty(userName) || isNullOrEmpty(password);

  /// Helps to initialize authorization instance with internal requesting client passed as a parameter.
  ///
  /// This function is called only if there is no valid nounce available ie., when isAuthenticated() returns false.
  /// Internal client will be passed as a parameter to this function which you can store inside the instance for internal authorization requests.
  ///
  /// authorize() / validate() functions will not be called before calling init() function.
  ///
  /// If you require Http request calls inside isAuthenticated() / generateAuthUrl() calls, then you will need to implement your own requesting mechanism  ///
  Future<bool> init(Dio? client);

  /// Called to validate token. (such as in JWT auth)
  ///
  /// As of right now, this function is not called outside of this instance. This can change in the future if there is a requirement to validate the nounce from the core client itself.
  /// Therefore, be sure to implement this with valid logic for the validation process.
  ///
  /// Example 1: JWT authentication token can be validated through an endpoint, you can implement that validation logic inside this.
  ///
  /// Example 2: Basic Auth does not require any validation, therefore you can simply return true or if still require some custom logic, you can implement that as well!
  Future<bool> validate();

  /// Called to check if this instance has a valid authentication nounce and generateAuthUrl() won't return false.
  ///
  /// This function will be called before init() function, therefore if you are using client instance passed through init() then there will be NullReferenceException.
  ///
  /// If you require HTTP requests in this method, then you need to implement custom logic.
  Future<bool> isAuthenticated();

  /// Called to authorize a request if the request requires authentication.
  ///
  /// Returning true means the request should be authorized, false means authorization failed.
  Future<bool> authorize();

  /// After authorize() is called, to get the authorization header string, (ie, '{scheme} {token}') the client calls this method to generate the raw string.
  ///
  /// The returning string formate must always be like
  ///
  /// {scheme} {token}
  ///
  /// Example 1: In case of JWT
  /// Bearer {jwt_token}
  ///
  /// Example 2: In case of Basic Auth
  /// Basic {base64 encoded username and password}
  Future<String?> generateAuthUrl();
}
