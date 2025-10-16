import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

import '../../wordpress_client.dart';

/// Implementation of GraphQL subscriptions using WebSocket connections.
///
/// This class manages WebSocket connections for GraphQL subscriptions,
/// handling the Apollo Subscriptions protocol for real-time updates.
final class GraphQLSubscriptionImpl<T> implements IGraphQLSubscription<T> {
  GraphQLSubscriptionImpl({
    required this.endpoint,
    required this.document,
    required this.parseData,
    this.variables,
    this.auth,
    this.config = const GraphQLSubscriptionConfig(),
    this.customHeaders,
  });
  final Uri endpoint;
  final String document;
  final Map<String, dynamic>? variables;
  final T Function(Map<String, dynamic> data) parseData;
  final IAuthorization? auth;
  final GraphQLSubscriptionConfig config;
  final Map<String, String>? customHeaders;

  late WebSocketChannel _channel;
  late StreamController<T> _dataController;
  late Stream<T> _dataStream;
  StreamSubscription<dynamic>? _messageSubscription;
  bool _initialized = false;

  GraphQLSubscriptionState _state = GraphQLSubscriptionState.disconnected;
  int _reconnectAttempts = 0;
  Timer? _reconnectTimer;
  final int _subscriptionId = 1;
  bool _cancelled = false;

  @override
  Stream<T> get stream {
    if (!_initialized) {
      throw StateError(
        'Stream not initialized. Call initialize() first.',
      );
    }
    return _dataStream;
  }

  @override
  GraphQLSubscriptionState get state => _state;

  /// Initialize the subscription and establish the WebSocket connection.
  Future<void> initialize() async {
    _dataController = StreamController<T>.broadcast();
    _dataStream = _dataController.stream;
    _initialized = true;

    await _connect();
  }

  Future<void> _connect() async {
    if (_cancelled) return;

    _updateState(GraphQLSubscriptionState.connecting);

    try {
      // Convert HTTP/HTTPS to WS/WSS
      final wsEndpoint = _convertToWebSocketUrl(endpoint);

      if (config.enableDebugLogging) {
        print('[GraphQLSubscription] Connecting to $wsEndpoint');
      }

      _channel = WebSocketChannel.connect(wsEndpoint);

      // Wait for connection to be established with timeout
      await _channel.ready.timeout(
        config.connectionTimeout,
        onTimeout: () {
          throw GraphQLSubscriptionException(
            message:
                'WebSocket connection timeout after ${config.connectionTimeout.inSeconds}s',
            type: GraphQLSubscriptionErrorType.connectionFailed,
          );
        },
      );

      if (config.enableDebugLogging) {
        print('[GraphQLSubscription] Connected');
      }

      _updateState(GraphQLSubscriptionState.connected);
      _reconnectAttempts = 0;

      // Initialize connection with headers (passed in connection_init payload)
      await _sendMessage({
        'type': 'connection_init',
        'payload': {'headers': await _buildHeaders()},
      });

      // Listen for messages
      _messageSubscription = _channel.stream.listen(
        _handleMessage,
        onError: _handleError,
        onDone: _handleDone,
      );

      // Subscribe after connection is initialized
      await _subscribe();
    } catch (e) {
      _handleConnectionError(e);
    }
  }

  Future<void> _subscribe() async {
    final subscriptionMessage = {
      'id': _subscriptionId.toString(),
      'type': 'subscribe',
      'payload': {
        'operationName': null,
        'query': document,
        if (variables != null) 'variables': variables,
      },
    };

    if (config.enableDebugLogging) {
      print('[GraphQLSubscription] Sending subscription: $subscriptionMessage');
    }

    await _sendMessage(subscriptionMessage);
  }

  Future<void> _sendMessage(Map<String, dynamic> message) async {
    try {
      _channel.sink.add(jsonEncode(message));
    } catch (e) {
      if (config.enableDebugLogging) {
        print('[GraphQLSubscription] Error sending message: $e');
      }
      rethrow;
    }
  }

  void _handleMessage(dynamic rawMessage) {
    if (_cancelled) return;

    try {
      if (rawMessage is! String) {
        throw GraphQLSubscriptionException(
          message: 'Expected string message, got ${rawMessage.runtimeType}',
          type: GraphQLSubscriptionErrorType.invalidResponse,
        );
      }

      final message = jsonDecode(rawMessage) as Map<String, dynamic>;
      final type = message['type'] as String?;

      if (config.enableDebugLogging) {
        print('[GraphQLSubscription] Received message type: $type');
      }

      switch (type) {
        case 'connection_ack':
          if (config.enableDebugLogging) {
            print('[GraphQLSubscription] Connection acknowledged');
          }
          break;

        case 'next':
          _handleData(message);
          break;

        case 'error':
          _handleServerError(message);
          break;

        case 'complete':
          if (config.enableDebugLogging) {
            print('[GraphQLSubscription] Subscription completed');
          }
          break;

        case 'connection_error':
          _handleConnectionError(
            GraphQLSubscriptionException(
              message: message['payload']?['message'] ??
                  'Connection error from server',
              type: GraphQLSubscriptionErrorType.serverError,
            ),
          );
          break;

        default:
          if (config.enableDebugLogging) {
            print('[GraphQLSubscription] Unknown message type: $type');
          }
      }
    } catch (e) {
      _handleError(e);
    }
  }

  void _handleData(Map<String, dynamic> message) {
    try {
      final payload = message['payload'] as Map<String, dynamic>?;
      if (payload == null) {
        throw GraphQLSubscriptionException(
          message: 'Missing payload in data message',
          type: GraphQLSubscriptionErrorType.invalidResponse,
        );
      }

      final data = payload['data'] as Map<String, dynamic>?;
      final errors = payload['errors'] as List<dynamic>?;

      if (errors != null && errors.isNotEmpty) {
        final errorMessage = errors
            .map((e) =>
                (e as Map<String, dynamic>)['message'] ?? 'Unknown error',)
            .join(', ');
        throw GraphQLSubscriptionException(
          message: 'GraphQL error: $errorMessage',
          type: GraphQLSubscriptionErrorType.serverError,
        );
      }

      if (data == null) {
        throw GraphQLSubscriptionException(
          message: 'Missing data in payload',
          type: GraphQLSubscriptionErrorType.invalidResponse,
        );
      }

      final parsedData = parseData(data);
      _dataController.add(parsedData);
    } catch (e) {
      _handleError(e);
    }
  }

  void _handleServerError(Map<String, dynamic> message) {
    final payload = message['payload'];
    final errorMessage = payload is List
        ? (payload.isNotEmpty
            ? payload.first['message'] ?? 'Server error'
            : 'Server error')
        : 'Unknown server error';

    _handleError(
      GraphQLSubscriptionException(
        message: errorMessage,
        type: GraphQLSubscriptionErrorType.serverError,
      ),
    );
  }

  void _handleConnectionError(dynamic error) {
    _updateState(GraphQLSubscriptionState.error);

    if (config.enableDebugLogging) {
      print('[GraphQLSubscription] Connection error: $error');
    }

    if (!config.autoReconnect || _cancelled) {
      _dataController.addError(error);
      return;
    }

    if (config.maxReconnectAttempts != null &&
        _reconnectAttempts >= config.maxReconnectAttempts!) {
      if (config.enableDebugLogging) {
        print('[GraphQLSubscription] Max reconnection attempts reached');
      }
      _dataController.addError(error);
      return;
    }

    _updateState(GraphQLSubscriptionState.reconnecting);
    _reconnectAttempts++;

    final delay = _calculateBackoff(_reconnectAttempts);
    if (config.enableDebugLogging) {
      print(
        '[GraphQLSubscription] Reconnecting in ${delay.inSeconds}s (attempt $_reconnectAttempts)',
      );
    }

    _reconnectTimer = Timer(delay, () async {
      if (!_cancelled) {
        try {
          await _channel.sink.close();
        } catch (_) {}
        await _connect();
      }
    });
  }

  void _handleError(dynamic error) {
    if (_cancelled) return;

    if (config.enableDebugLogging) {
      print('[GraphQLSubscription] Error: $error');
    }

    _dataController.addError(error);
  }

  void _handleDone() {
    if (config.enableDebugLogging) {
      print('[GraphQLSubscription] Stream done');
    }
    _updateState(GraphQLSubscriptionState.disconnected);
  }

  Future<Map<String, String>> _buildHeaders() async {
    final headers = <String, String>{
      'Sec-WebSocket-Protocol': 'graphql-ws',
      ...?customHeaders,
    };

    // Add authorization header if available
    if (auth != null) {
      final authHeader = await auth!.generateAuthUrl();
      if (authHeader != null) {
        headers['Authorization'] = authHeader;
      }
    }

    return headers;
  }

  Duration _calculateBackoff(int attempt) {
    var delay = config.reconnectInterval;
    for (var i = 1; i < attempt; i++) {
      delay = Duration(
        milliseconds: (delay.inMilliseconds * config.backoffMultiplier).toInt(),
      );
      if (delay > config.maxBackoffDelay) {
        delay = config.maxBackoffDelay;
        break;
      }
    }
    return delay;
  }

  Uri _convertToWebSocketUrl(Uri httpUri) {
    final scheme = httpUri.scheme == 'https' ? 'wss' : 'ws';
    return httpUri.replace(scheme: scheme);
  }

  void _updateState(GraphQLSubscriptionState newState) {
    _state = newState;
  }

  @override
  Future<void> waitForConnection() async {
    if (_state == GraphQLSubscriptionState.connected) {
      return;
    }

    final completer = Completer<void>();
    StreamSubscription<T>? subscription;

    subscription = stream.listen(
      (_) {}, // Just wait for first event
      onError: (error) {
        if (!completer.isCompleted) {
          completer.completeError(error);
        }
        subscription?.cancel();
      },
      onDone: () {
        if (!completer.isCompleted) {
          completer.completeError(
            GraphQLSubscriptionException(
              message: 'Stream closed before connection established',
              type: GraphQLSubscriptionErrorType.connectionFailed,
            ),
          );
        }
        subscription?.cancel();
      },
    );

    // Timeout if connection not established
    return completer.future.timeout(
      config.connectionTimeout,
      onTimeout: () {
        subscription?.cancel();
        throw GraphQLSubscriptionException(
          message:
              'Connection timeout after ${config.connectionTimeout.inSeconds}s',
          type: GraphQLSubscriptionErrorType.timeout,
        );
      },
    );
  }

  @override
  Future<void> cancel() async {
    if (_cancelled) return;

    _cancelled = true;
    _updateState(GraphQLSubscriptionState.disconnected);

    _reconnectTimer?.cancel();
    await _messageSubscription?.cancel();
    if (_initialized) {
      await _dataController.close();
    }

    try {
      await _channel.sink.close();
    } catch (_) {}

    if (config.enableDebugLogging) {
      print('[GraphQLSubscription] Subscription cancelled');
    }
  }
}
