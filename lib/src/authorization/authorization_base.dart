import 'package:dio/dio.dart';
import 'package:meta/meta.dart';

import '../../wordpress_client.dart';
import '../utilities/helpers.dart';

/// Base class for all authorization types in the WordPress client.
///
/// To implement a custom authorization system, you must extend this class.
///
/// Note: There is no built-in storage system to store and retrieve credentials.
/// You need to implement your own storage mechanism if required.
///
/// Example of a custom authorization implementation:
/// ```dart
/// class CustomAuth extends IAuthorization {
///   CustomAuth({required String userName, required String password})
///     : super(userName: userName, password: password);
///
///   @override
///   String get scheme => 'Custom';
///
///   @override
///   Future<bool> authorize() async {
///     // Implement your custom authorization logic here
///     return true;
///   }
///
///   // Implement other required methods...
/// }
/// ```
abstract base class IAuthorization {
  /// Creates a new instance of [IAuthorization] with the given username and password.
  ///
  /// [userName]: The username for authentication.
  /// [password]: The password for authentication.
  /// [headerKey]: The HTTP header key to use for authorization (default is 'Authorization').
  /// [events]: Optional [WordpressEvents] to listen to during the authorization process.
  IAuthorization({
    required this.userName,
    required this.password,
    this.headerKey = 'Authorization',
    this.events,
  });

  /// The base URL of the WordPress site.
  late final Uri baseUrl;

  /// The username for authentication.
  final String userName;

  /// The password for authentication.
  final String password;

  /// The HTTP header key to use for authorization.
  final String headerKey;

  /// Optional events to listen to during the authorization process.
  WordpressEvents? events;

  /// Indicates if this authorization instance has a valid authentication nonce (token/encryptedToken).
  bool get isValidAuth;

  /// Indicates if this is an invalid or default authorization instance without username or password fields.
  bool get isDefault => isNullOrEmpty(userName) || isNullOrEmpty(password);

  /// Gets the authorization scheme (e.g., 'Bearer' for JWT, 'Basic' for Basic Auth).
  String get scheme;

  /// Initializes the authorization instance with the internal requesting client.
  ///
  /// This method is called only if there is no valid nonce available (i.e., when [isAuthenticated] returns false).
  /// [authorize] and [validate] methods will not be called before calling [initialize].
  ///
  /// [baseUrl]: The base URL of the WordPress site.
  ///
  /// Returns a [Future<bool>] indicating whether initialization was successful.
  @mustCallSuper
  Future<bool> initialize({
    required Uri baseUrl,
  }) async {
    this.baseUrl = baseUrl;
    return true;
  }

  /// Provides this instance of [IAuthorization] with the Dio client instance for requests.
  ///
  /// [client]: The Dio client instance to use for making HTTP requests.
  void clientFactoryProvider(Dio client);

  /// Validates the authentication token (e.g., JWT token).
  ///
  /// This method is not called outside of this instance by default, but it may be used in the future.
  /// Implement this method with valid logic for the validation process.
  ///
  /// Example for JWT:
  /// ```dart
  /// @override
  /// Future<bool> validate() async {
  ///   try {
  ///     final response = await _client.post('/validate-token', data: {'token': _token});
  ///     return response.statusCode == 200;
  ///   } catch (e) {
  ///     return false;
  ///   }
  /// }
  /// ```
  Future<bool> validate();

  /// Checks if this instance has a valid authentication nonce and [generateAuthUrl] won't return null.
  ///
  /// This method is called before [initialize], so if you need to use the client instance,
  /// you should implement custom logic to handle potential null references.
  ///
  /// Returns a [Future<bool>] indicating whether the instance is authenticated.
  Future<bool> isAuthenticated();

  /// Authorizes a request if authentication is required.
  ///
  /// Returns a [Future<bool>] indicating whether authorization was successful (true) or failed (false).
  Future<bool> authorize();

  /// Generates the authorization header string after [authorize] is called.
  ///
  /// The returned string format must always be: "{scheme} {token}"
  ///
  /// Examples:
  /// - JWT: "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  /// - Basic Auth: "Basic dXNlcm5hbWU6cGFzc3dvcmQ="
  ///
  /// Returns a [Future<String?>] containing the authorization header string, or null if not authorized.
  Future<String?> generateAuthUrl();
}
