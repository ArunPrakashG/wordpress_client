import '../../wordpress_client.dart';

/// Extension adding subscription capabilities to [GraphQLInterface].
///
/// Subscriptions enable real-time updates for GraphQL queries using WebSocket.
/// This extension provides a simple interface to subscribe to GraphQL subscriptions
/// without worrying about the underlying WebSocket implementation.
///
/// Example usage:
/// ```dart
/// final subscription = await client.graphql.subscribe<Post>(
///   document: '''
///     subscription OnPostCreated {
///       postCreated {
///         id
///         title
///         content
///       }
///     }
///   ''',
///   parseData: (data) {
///     final postData = data['postCreated'] as Map<String, dynamic>;
///     return Post.fromJson(postData);
///   },
/// );
///
/// subscription.stream.listen((post) {
///   print('New post: ${post.title}');
/// });
///
/// // When done
/// await subscription.cancel();
/// ```
extension GraphQLSubscriptionsExtension on GraphQLInterface {
  /// Subscribe to a GraphQL subscription.
  ///
  /// Parameters:
  /// - [document]: The GraphQL subscription document as a string.
  /// - [parseData]: A function to parse the subscription data into type [T].
  /// - [variables]: Optional GraphQL variables for the subscription.
  /// - [config]: Optional configuration for the subscription connection.
  /// - [customHeaders]: Optional custom headers to send with the WebSocket connection.
  ///
  /// Returns an [IGraphQLSubscription<T>] which can be used to:
  /// - Listen to real-time updates via `.stream`
  /// - Monitor connection state via `.state`
  /// - Wait for connection establishment via `.waitForConnection()`
  /// - Cancel the subscription via `.cancel()`
  ///
  /// Throws [GraphQLSubscriptionException] if:
  /// - Connection fails to establish
  /// - Invalid response format is received
  /// - Server returns GraphQL errors
  /// - Timeout occurs during operations
  Future<IGraphQLSubscription<T>> subscribe<T>({
    required String document,
    required T Function(Map<String, dynamic> data) parseData,
    Map<String, dynamic>? variables,
    GraphQLSubscriptionConfig? config,
    Map<String, String>? customHeaders,
  }) async {
    // Create the subscription implementation
    final subscription = GraphQLSubscriptionImpl<T>(
      endpoint: graphqlEndpoint,
      document: document,
      variables: variables,
      parseData: parseData,
      config: config ?? const GraphQLSubscriptionConfig(),
      customHeaders: customHeaders,
    );

    // Initialize the connection
    await subscription.initialize();

    return subscription;
  }

  /// Get the GraphQL endpoint being used.
  ///
  /// This is computed from the WordPress REST API base URL.
  /// For most setups, this will be `/graphql` at the site root or subdirectory.
  Uri get graphqlEndpoint => baseUrl.replace(
        pathSegments: _computeGraphQLPathSegments(baseUrl),
        queryParameters: {},
      );

  /// Compute the GraphQL endpoint path segments from REST base.
  static List<String> _computeGraphQLPathSegments(Uri restBase) {
    final segments = List<String>.from(restBase.pathSegments);
    final wpJsonIndex = segments.indexOf('wp-json');

    // Keep everything before 'wp-json' as the site path prefix, if present.
    final sitePrefix =
        wpJsonIndex > 0 ? segments.sublist(0, wpJsonIndex) : <String>[];

    return <String>[...sitePrefix, 'graphql'];
  }
}
