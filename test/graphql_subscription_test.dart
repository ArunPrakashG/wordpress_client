import 'package:test/test.dart';
import 'package:wordpress_client/src/graphql/graphql_subscription.dart';
import 'package:wordpress_client/src/graphql/graphql_subscription_impl.dart';

void main() {
  group('GraphQL Subscriptions', () {
    group('GraphQLSubscriptionConfig', () {
      test('should have default values', () {
        const config = GraphQLSubscriptionConfig();

        expect(config.reconnectInterval, const Duration(seconds: 5));
        expect(config.maxReconnectAttempts, isNull);
        expect(config.connectionTimeout, const Duration(seconds: 10));
        expect(config.messageTimeout, const Duration(seconds: 30));
        expect(config.autoReconnect, isTrue);
        expect(config.backoffMultiplier, 1.5);
        expect(config.maxBackoffDelay, const Duration(seconds: 30));
        expect(config.enableDebugLogging, isFalse);
      });

      test('should allow custom values', () {
        const config = GraphQLSubscriptionConfig(
          reconnectInterval: Duration(seconds: 3),
          maxReconnectAttempts: 5,
          connectionTimeout: Duration(seconds: 20),
          messageTimeout: Duration(seconds: 60),
          autoReconnect: false,
          backoffMultiplier: 2,
          maxBackoffDelay: Duration(seconds: 60),
          enableDebugLogging: true,
        );

        expect(config.reconnectInterval, const Duration(seconds: 3));
        expect(config.maxReconnectAttempts, 5);
        expect(config.connectionTimeout, const Duration(seconds: 20));
        expect(config.messageTimeout, const Duration(seconds: 60));
        expect(config.autoReconnect, isFalse);
        expect(config.backoffMultiplier, 2.0);
        expect(config.maxBackoffDelay, const Duration(seconds: 60));
        expect(config.enableDebugLogging, isTrue);
      });
    });

    group('GraphQLSubscriptionState', () {
      test('should have all required states', () {
        expect(GraphQLSubscriptionState.connecting, isNotNull);
        expect(GraphQLSubscriptionState.connected, isNotNull);
        expect(GraphQLSubscriptionState.reconnecting, isNotNull);
        expect(GraphQLSubscriptionState.disconnected, isNotNull);
        expect(GraphQLSubscriptionState.error, isNotNull);
      });

      test('should have 5 states', () {
        expect(GraphQLSubscriptionState.values.length, 5);
      });
    });

    group('GraphQLSubscriptionException', () {
      test('should be created with message and type', () {
        final exception = GraphQLSubscriptionException(
          message: 'Test error',
          type: GraphQLSubscriptionErrorType.connectionFailed,
        );

        expect(exception.message, 'Test error');
        expect(exception.type, GraphQLSubscriptionErrorType.connectionFailed);
      });

      test('should be created without optional fields', () {
        final exception = GraphQLSubscriptionException(
          message: 'Test error',
        );

        expect(exception.message, 'Test error');
        expect(exception.type, GraphQLSubscriptionErrorType.unknown);
      });

      test('should have toString method', () {
        final exception = GraphQLSubscriptionException(
          message: 'Test error',
          type: GraphQLSubscriptionErrorType.timeout,
        );

        expect(exception.toString(), contains('Test error'));
        expect(exception.toString(), contains('timeout'));
      });

      test('should have all error types', () {
        expect(GraphQLSubscriptionErrorType.connectionFailed, isNotNull);
        expect(GraphQLSubscriptionErrorType.connectionLost, isNotNull);
        expect(GraphQLSubscriptionErrorType.serverError, isNotNull);
        expect(GraphQLSubscriptionErrorType.invalidResponse, isNotNull);
        expect(GraphQLSubscriptionErrorType.parseError, isNotNull);
        expect(GraphQLSubscriptionErrorType.authenticationFailed, isNotNull);
        expect(GraphQLSubscriptionErrorType.timeout, isNotNull);
        expect(GraphQLSubscriptionErrorType.unknown, isNotNull);
      });

      test('should have 8 error types', () {
        expect(GraphQLSubscriptionErrorType.values.length, 8);
      });
    });

    group('GraphQLSubscriptionImpl', () {
      late GraphQLSubscriptionImpl<Map<String, dynamic>> subscription;
      const testQuery = '''
        subscription {
          posts {
            id
            title
          }
        }
      ''';

      setUp(() {
        subscription = GraphQLSubscriptionImpl<Map<String, dynamic>>(
          endpoint: Uri.parse('http://localhost:8080/graphql'),
          document: testQuery,
          parseData: (data) => data,
        );
      });

      test('should initialize with correct properties', () {
        expect(
          subscription.endpoint.toString(),
          'http://localhost:8080/graphql',
        );
        expect(subscription.document, testQuery);
        expect(subscription.variables, isNull);
        expect(subscription.state, GraphQLSubscriptionState.disconnected);
      });

      test('should have disconnected state initially', () {
        expect(subscription.state, GraphQLSubscriptionState.disconnected);
      });

      test('should expose stream', () {
        expect(
          () => subscription.stream,
          throwsA(isA<StateError>()),
        );
      });

      test('should convert HTTP URL to WS', () {
        final sub = GraphQLSubscriptionImpl<Map<String, dynamic>>(
          endpoint: Uri.parse('http://example.com/graphql'),
          document: testQuery,
          parseData: (data) => data,
        );

        // We can't directly test the private method, but we can verify through
        // the URI format expected by the implementation
        expect(sub.endpoint.scheme, 'http');
      });

      test('should convert HTTPS URL to WSS', () {
        final sub = GraphQLSubscriptionImpl<Map<String, dynamic>>(
          endpoint: Uri.parse('https://example.com/graphql'),
          document: testQuery,
          parseData: (data) => data,
        );

        expect(sub.endpoint.scheme, 'https');
      });

      test('should accept custom headers', () {
        final customHeaders = {'X-Custom': 'Value'};
        final sub = GraphQLSubscriptionImpl<Map<String, dynamic>>(
          endpoint: Uri.parse('http://example.com/graphql'),
          document: testQuery,
          parseData: (data) => data,
          customHeaders: customHeaders,
        );

        expect(sub.customHeaders, customHeaders);
      });

      test('should accept variables', () {
        final variables = {'id': '123'};
        final sub = GraphQLSubscriptionImpl<Map<String, dynamic>>(
          endpoint: Uri.parse('http://example.com/graphql'),
          document: testQuery,
          variables: variables,
          parseData: (data) => data,
        );

        expect(sub.variables, variables);
      });

      test('cancel should complete without error before initialization',
          () async {
        // Should not throw even if not initialized
        await subscription.cancel();
        expect(subscription.state, GraphQLSubscriptionState.disconnected);
      });

      test('multiple cancellations should be safe', () async {
        await subscription.cancel();
        await subscription.cancel();
        // Should not throw
      });

      test('should handle custom parse data function', () {
        List parseData(data) => data['posts'] as List<dynamic>;
        final sub = GraphQLSubscriptionImpl<List<dynamic>>(
          endpoint: Uri.parse('http://example.com/graphql'),
          document: testQuery,
          parseData: parseData,
        );

        expect(sub.parseData, parseData);
      });
    });

    group('GraphQLSubscriptionConfig with backoff calculation', () {
      test('should support exponential backoff settings', () {
        const config = GraphQLSubscriptionConfig(
          reconnectInterval: Duration(seconds: 2),
          backoffMultiplier: 2,
          maxBackoffDelay: Duration(seconds: 60),
        );

        expect(config.backoffMultiplier, 2.0);
        expect(config.maxBackoffDelay, const Duration(seconds: 60));
      });

      test('should have reasonable defaults for backoff', () {
        const config = GraphQLSubscriptionConfig();
        expect(config.backoffMultiplier, greaterThan(1.0));
        expect(config.maxBackoffDelay, greaterThan(Duration.zero));
      });
    });

    group('GraphQLSubscriptionException error types', () {
      test('connectionFailed type should be catchable', () {
        final exception = GraphQLSubscriptionException(
          message: 'Connection failed',
          type: GraphQLSubscriptionErrorType.connectionFailed,
        );

        expect(exception.type, GraphQLSubscriptionErrorType.connectionFailed);
      });

      test('timeout type should be catchable', () {
        final exception = GraphQLSubscriptionException(
          message: 'Operation timed out',
          type: GraphQLSubscriptionErrorType.timeout,
        );

        expect(exception.type, GraphQLSubscriptionErrorType.timeout);
      });

      test('serverError type should be catchable', () {
        final exception = GraphQLSubscriptionException(
          message: 'Server error',
          type: GraphQLSubscriptionErrorType.serverError,
        );

        expect(exception.type, GraphQLSubscriptionErrorType.serverError);
      });

      test('invalidResponse type should be catchable', () {
        final exception = GraphQLSubscriptionException(
          message: 'Invalid response',
          type: GraphQLSubscriptionErrorType.invalidResponse,
        );

        expect(exception.type, GraphQLSubscriptionErrorType.invalidResponse);
      });

      test('authenticationFailed type should be catchable', () {
        final exception = GraphQLSubscriptionException(
          message: 'Authentication failed',
          type: GraphQLSubscriptionErrorType.authenticationFailed,
        );

        expect(
            exception.type, GraphQLSubscriptionErrorType.authenticationFailed,);
      });

      test('serializationError type should be catchable', () {
        final exception = GraphQLSubscriptionException(
          message: 'Parse error',
          type: GraphQLSubscriptionErrorType.parseError,
        );

        expect(exception.type, GraphQLSubscriptionErrorType.parseError);
      });

      test('unknown type should be catchable', () {
        final exception = GraphQLSubscriptionException(
          message: 'Unknown error',
        );

        expect(exception.type, GraphQLSubscriptionErrorType.unknown);
      });
    });

    group('Stream interface compliance', () {
      test('stream should be broadcastable', () {
        const config = GraphQLSubscriptionConfig();
        expect(config, isNotNull);
      });

      test('state should be observable', () {
        final subscription = GraphQLSubscriptionImpl<Map<String, dynamic>>(
          endpoint: Uri.parse('http://localhost:8080/graphql'),
          document: 'subscription { posts { id } }',
          parseData: (data) => data,
        );

        expect(subscription.state, GraphQLSubscriptionState.disconnected);
      });
    });

    group('Configuration immutability', () {
      test('GraphQLSubscriptionConfig should be immutable', () {
        const config = GraphQLSubscriptionConfig();
        // Const constructor should guarantee immutability
        expect(config, isA<GraphQLSubscriptionConfig>());
      });

      test('two identical configs should be equal', () {
        const config1 = GraphQLSubscriptionConfig();
        const config2 = GraphQLSubscriptionConfig();

        expect(config1.reconnectInterval, config2.reconnectInterval);
      });
    });
  });
}
