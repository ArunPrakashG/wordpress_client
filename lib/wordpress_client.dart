/// A library for interacting with Wordpress REST API with support for Authorization using JWT and Basic Auth.
///
/// All requests are created using a RequestBuilder class which is designed to generate requests in a fluent manner.
/// Responses can contain statistical data such as Time taken for the request to finish as [Duration], Any errors that might have occured, and the raw response from the server.
library wordpress_client;

export 'src/authorization/authorization_base.dart' show IAuthorization;
// Authorization
export 'src/authorization/authorization_builder.dart' show AuthorizationBuilder;
export 'src/authorization/authorization_methods/basic_auth.dart' show BasicAuth;
export 'src/authorization/authorization_methods/basic_jwt.dart' show BasicJwtAuth;
export 'src/authorization/authorization_methods/useful_jwt.dart' show UsefulJwtAuth;

// Requests
export 'src/builders/request.dart';
export 'src/builders/request_builder_base.dart';

// Enums
export 'src/enums.dart';

// Responses
export 'src/responses_import.dart';

// Callback
export 'src/utilities/callback.dart';
export 'src/utilities/serializable_instance.dart';

// Core files
export 'src/wordpress_client_base.dart' show WordpressClient;
