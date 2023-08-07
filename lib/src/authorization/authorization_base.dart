import 'package:meta/meta.dart';

import '../../wordpress_client.dart';
import '../utilities/helpers.dart';

/// Base class for all authorization types.
///
/// To implement a custom authorization system, You _must_ extend this class.
///
/// Note that, there is no storage system internally to store and retrive
abstract base class IAuthorization {
  /// Creates a new instance of [IAuthorization] with the given username and password.
  IAuthorization({
    required this.userName,
    required this.password,
    this.headerKey = 'Authorization',
    this.events,
  });

  /// The base url of the wordpress site.
  late final Uri baseUrl;

  /// The username
  final String userName;

  /// The password
  final String password;

  /// The header key to use for authorization.
  final String headerKey;

  /// The events to listen to.
  WordpressEvents? events;

  /// Gets if this authorization instance has valid authentication nounce. (token/encryptedToken)
  bool get isValidAuth;

  /// Gets if this is an invalid or default authorization instance without username or password fields.
  bool get isDefault => isNullOrEmpty(userName) || isNullOrEmpty(password);

  /// Gets the authorization scheme.
  String get scheme;

  /// Helps to initialize authorization instance with internal requesting client passed as a parameter.
  ///
  /// This function is called only if there is no valid nounce available i.e., when isAuthenticated() returns false.
  ///
  /// `authorize()` / `validate()` functions will not be called before calling `initialize()` function.
  @mustCallSuper
  Future<bool> initialize({
    required Uri baseUrl,
  }) async {
    this.baseUrl = baseUrl;
    return true;
  }

  /// Provides this instance of [IAuthorization] with the Dio client instance for requests.
  void clientFactoryProvider(Dio client);

  /// Called to validate token. (such as in JWT auth)
  ///
  /// As of right now, this function is not called outside of this instance. This can change in the future if there is a requirement to validate the nounce from the core client itself.
  /// Therefore, be sure to implement this with valid logic for the validation process.
  ///
  /// Example 1: JWT authentication token can be validated through an endpoint, you can implement that validation logic inside this.
  ///
  /// Example 2: Basic Auth does not require any validation, therefore you can simply return true or if still require some custom logic, you can implement that as well!
  Future<bool> validate();

  /// Called to check if this instance has a valid authentication nounce and generateAuthUrl() won't return null.
  ///
  /// This function will be called before init() function, therefore if you are using client instance passed through init() then there will be NullReferenceException.
  ///
  /// If you require HTTP requests in this method, then you need to implement custom logic.
  Future<bool> isAuthenticated();

  /// Called to authorize a request if the request requires authentication.
  ///
  /// Returning true means the request should be authorized, false means authorization failed.
  Future<bool> authorize();

  /// After `authorize()` is called, to get the authorization header string, (ie, '{scheme} {token}') the client calls this method to generate the raw string.
  ///
  /// The returning string formate must always be like
  ///
  /// {scheme} {token}
  ///
  /// - Example 1: In case of JWT, `Bearer {jwt_token}`
  ///
  /// - Example 2: In case of Basic Auth, `Basic {Base64UsernamePassword}`
  ///
  Future<String?> generateAuthUrl();
}
