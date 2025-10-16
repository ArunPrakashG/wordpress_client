import 'dart:async';

import 'package:wordpress_client/wordpress_client.dart';

void main() async {
  // Example: Real-time WordPress Blog Updates using GraphQL Subscriptions

  // Initialize the WordPress client
  final client = WordpressClient(
    baseUrl: Uri.parse('https://your-wordpress-site.com'),
  );

  // Example 1: Subscribe to new posts
  await subscribeToNewPosts(client);

  // Example 2: Subscribe to new comments with variables
  await subscribeToNewComments(client, postId: 42);

  // Example 3: Subscribe with error handling
  await subscribeWithErrorHandling(client);

  // Example 4: Monitor connection state
  await subscribeWithStateMonitoring(client);
}

/// Example 1: Simple subscription to new posts
Future<void> subscribeToNewPosts(WordpressClient client) async {
  print('=== Example 1: Subscribe to New Posts ===\n');

  // Define the subscription query
  const subscriptionQuery = '''
    subscription {
      postCreated {
        id
        title
        content
        author {
          name
        }
        date
      }
    }
  ''';

  // Create subscription
  final subscription = await client.graphql.subscribe<Map<String, dynamic>>(
    document: subscriptionQuery,
    parseData: (data) => data['postCreated'] as Map<String, dynamic>,
  );

  print('Subscription created. Listening for new posts...\n');

  // Listen for updates
  subscription.stream.listen(
    (postData) {
      print('✅ New post received!');
      print('   Title: ${postData['title']}');
      print('   Author: ${postData['author']['name']}');
      print('   Date: ${postData['date']}\n');
    },
    onDone: () => print('Subscription closed'),
  );

  // Keep subscription active for demo (in real app, keep it running)
  await Future.delayed(const Duration(seconds: 10));
  await subscription.cancel();
}

/// Example 2: Subscription with variables
Future<void> subscribeToNewComments(
  WordpressClient client, {
  required int postId,
}) async {
  print('\n=== Example 2: Subscribe to New Comments ===\n');

  const subscriptionQuery = '''
    subscription OnNewComment(\$postId: Int!) {
      commentCreated(postId: \$postId) {
        id
        content
        author {
          name
          email
        }
        createdAt
      }
    }
  ''';

  // Create subscription with variables
  final subscription = await client.graphql.subscribe<Map<String, dynamic>>(
    document: subscriptionQuery,
    variables: {'postId': postId},
    parseData: (data) => data['commentCreated'] as Map<String, dynamic>,
  );

  print('Subscribed to comments on post #$postId\n');

  subscription.stream.listen(
    (commentData) {
      print('💬 New comment!');
      print('   From: ${commentData['author']['name']}');
      print('   Text: ${commentData['content']}');
      print('   Time: ${commentData['createdAt']}\n');
    },
  );

  await Future.delayed(const Duration(seconds: 5));
  await subscription.cancel();
}

/// Example 3: Comprehensive error handling
Future<void> subscribeWithErrorHandling(WordpressClient client) async {
  print('\n=== Example 3: Error Handling ===\n');

  try {
    const subscriptionQuery = '''
      subscription {
        postCreated {
          id title
        }
      }
    ''';

    final subscription = await client.graphql.subscribe<Post>(
      document: subscriptionQuery,
      parseData: (data) => Post.fromJson(data['postCreated']),
      config: const GraphQLSubscriptionConfig(
        reconnectInterval: Duration(seconds: 2),
        maxReconnectAttempts: 3,
        enableDebugLogging: true,
      ),
    );

    subscription.stream.listen(
      (post) {
        print('✅ Post: ${post.title}');
      },
      onError: (error) {
        if (error is GraphQLSubscriptionException) {
          print('❌ Error: ${error.message}');
          print('   Type: ${error.type}');
          switch (error.type) {
            case GraphQLSubscriptionErrorType.connectionFailed:
              print('   → Connection could not be established');
            case GraphQLSubscriptionErrorType.timeout:
              print('   → Operation timed out');
            case GraphQLSubscriptionErrorType.serverError:
              print('   → Server returned an error');
            default:
              print('   → See documentation for other error types');
          }
        }
      },
      onDone: () => print('Stream closed'),
    );

    await Future.delayed(const Duration(seconds: 5));
    await subscription.cancel();
  } catch (e) {
    print('Exception during subscription: $e');
  }
}

/// Example 4: Monitor connection state
Future<void> subscribeWithStateMonitoring(WordpressClient client) async {
  print('\n=== Example 4: State Monitoring ===\n');

  const subscriptionQuery = '''
    subscription {
      postCreated { id title }
    }
  ''';

  final subscription = await client.graphql.subscribe<Map<String, dynamic>>(
    document: subscriptionQuery,
    parseData: (data) => data['postCreated'] as Map<String, dynamic>,
    config: const GraphQLSubscriptionConfig(),
  );

  // Monitor state changes
  Future.delayed(Duration.zero, () {
    _monitorState(subscription);
  });

  subscription.stream.listen(
    (data) => print('Data: $data'),
  );

  await Future.delayed(const Duration(seconds: 10));
  await subscription.cancel();
}

/// Helper to monitor connection state
void _monitorState(IGraphQLSubscription subscription) {
  var lastState = subscription.state;
  print('Initial state: $lastState\n');

  // Check state every 500ms
  final timer = Timer.periodic(const Duration(milliseconds: 500), (_) {
    final currentState = subscription.state;
    if (currentState != lastState) {
      print('State changed: $lastState → $currentState');
      lastState = currentState;
    }
  });

  // Stop monitoring after 10 seconds
  Future.delayed(const Duration(seconds: 10), timer.cancel);
}

/// Simple Post model for Example 3
class Post {
  Post({required this.id, required this.title});

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] as String,
      title: json['title'] as String,
    );
  }
  final String id;
  final String title;
}
