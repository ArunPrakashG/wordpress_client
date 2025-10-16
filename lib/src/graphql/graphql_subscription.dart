/// Represents a GraphQL subscription stream.
///
/// This interface provides a stream-based API for GraphQL subscriptions,
/// allowing clients to subscribe to real-time updates from WordPress
/// via WPGraphQL.
///
/// Example usage:
/// ```dart
/// final subscription = await client.graphql.subscribe<Post>(
///   document: '''
///     subscription OnPostCreated {
///       postCreated {
///         node { id title content }
///       }
///     }
///   ''',
///   parseData: (data) => Post.fromJson(data['postCreated']['node']),
/// );
///
/// subscription.listen(
///   (post) => print('New post: \${post.title}'),
///   onError: (error) => print('Error: \$error'),
///   onDone: () => print('Subscription closed'),
/// );
///
/// // Clean up when done
/// await subscription.cancel();
/// ```
abstract class IGraphQLSubscription<T> {
  /// Returns the underlying stream of subscription data.
  Stream<T> get stream;

  /// Cancels the subscription and closes the connection.
  ///
  /// After cancellation, no more data will be emitted and the stream
  /// will be closed. Calling this multiple times is safe.
  Future<void> cancel();

  /// Waits for the WebSocket connection to be established.
  ///
  /// Throws an exception if the connection fails to establish within
  /// the configured timeout period.
  Future<void> waitForConnection();

  /// Gets the current connection state.
  GraphQLSubscriptionState get state;
}

/// Represents the state of a GraphQL subscription connection.
enum GraphQLSubscriptionState {
  /// Connection is being established
  connecting,

  /// Connection is active and subscribed
  connected,

  /// Attempting to reconnect after a disconnection
  reconnecting,

  /// Connection is closed
  disconnected,

  /// An error occurred
  error,
}

/// Configuration for GraphQL subscriptions.
final class GraphQLSubscriptionConfig {
  const GraphQLSubscriptionConfig({
    this.reconnectInterval = const Duration(seconds: 5),
    this.maxReconnectAttempts,
    this.connectionTimeout = const Duration(seconds: 10),
    this.messageTimeout = const Duration(seconds: 30),
    this.autoReconnect = true,
    this.backoffMultiplier = 1.5,
    this.maxBackoffDelay = const Duration(seconds: 30),
    this.enableDebugLogging = false,
  });

  /// Duration between reconnection attempts (exponential backoff base).
  final Duration reconnectInterval;

  /// Maximum number of reconnection attempts (null for infinite).
  final int? maxReconnectAttempts;

  /// Timeout for establishing connection.
  final Duration connectionTimeout;

  /// Timeout for individual messages.
  final Duration messageTimeout;

  /// Whether to automatically reconnect on disconnection.
  final bool autoReconnect;

  /// Exponential backoff multiplier for reconnection delays.
  final double backoffMultiplier;

  /// Maximum reconnection delay cap.
  final Duration maxBackoffDelay;

  /// Whether to log debug information.
  final bool enableDebugLogging;

  /// Creates a copy with optional field overrides.
  GraphQLSubscriptionConfig copyWith({
    Duration? reconnectInterval,
    int? maxReconnectAttempts,
    Duration? connectionTimeout,
    Duration? messageTimeout,
    bool? autoReconnect,
    double? backoffMultiplier,
    Duration? maxBackoffDelay,
    bool? enableDebugLogging,
  }) {
    return GraphQLSubscriptionConfig(
      reconnectInterval: reconnectInterval ?? this.reconnectInterval,
      maxReconnectAttempts: maxReconnectAttempts ?? this.maxReconnectAttempts,
      connectionTimeout: connectionTimeout ?? this.connectionTimeout,
      messageTimeout: messageTimeout ?? this.messageTimeout,
      autoReconnect: autoReconnect ?? this.autoReconnect,
      backoffMultiplier: backoffMultiplier ?? this.backoffMultiplier,
      maxBackoffDelay: maxBackoffDelay ?? this.maxBackoffDelay,
      enableDebugLogging: enableDebugLogging ?? this.enableDebugLogging,
    );
  }
}

/// Error that occurs during a GraphQL subscription.
class GraphQLSubscriptionException implements Exception {
  GraphQLSubscriptionException({
    required this.message,
    this.cause,
    this.type = GraphQLSubscriptionErrorType.unknown,
  });

  /// The error message.
  final String message;

  /// The underlying exception, if any.
  final Exception? cause;

  /// The type of subscription error.
  final GraphQLSubscriptionErrorType type;

  @override
  String toString() => 'GraphQLSubscriptionException($type): $message';
}

/// Types of errors that can occur during subscriptions.
enum GraphQLSubscriptionErrorType {
  /// Connection could not be established
  connectionFailed,

  /// Connection was lost unexpectedly
  connectionLost,

  /// Server returned an error for the subscription
  serverError,

  /// Client received invalid response format
  invalidResponse,

  /// Subscription message parsing failed
  parseError,

  /// Authentication failed for the subscription
  authenticationFailed,

  /// Timeout occurred
  timeout,

  /// Unknown error
  unknown,
}
