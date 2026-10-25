import 'package:flutter/material.dart';
// The package also exports a `Widget` (a WordPress widget), so hide it.
import 'package:wordpress_client/wordpress_client.dart' hide Widget;

void main() => runApp(const ExampleApp());

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'wordpress_client',
      theme: ThemeData(colorSchemeSeed: Colors.blue, useMaterial3: true),
      home: const PostsPage(),
    );
  }
}

class PostsPage extends StatefulWidget {
  const PostsPage({super.key});

  @override
  State<PostsPage> createState() => _PostsPageState();
}

class _PostsPageState extends State<PostsPage> {
  // Any WordPress site works for reading. Drafting needs an application
  // password: Users > Profile > Application Passwords.
  static final _site = Uri.parse('https://wordpress.org/news');

  // Writes that fail while offline are kept here and replayed by `flush`.
  final _queue = OfflineWriteQueue(store: MemoryWriteQueueStore());

  late final WordpressClient _client = WordpressClient.forSite(
    siteUrl: _site,
    bootstrapper: (builder) => builder
        .withMiddleware(_queue)
        .withMiddleware(LoggingMiddleware(sink: debugPrint))
        .build(),
  );

  late Future<List<Post>> _posts = _load();

  Future<List<Post>> _load() async {
    final response = await _client.posts.list(
      ListPostRequest(perPage: 20, orderBy: OrderBy.date),
    );

    if (response case WordpressSuccessResponse(:final data)) {
      return data;
    }

    throw Exception(_describe(response));
  }

  Future<void> _draft() async {
    final response = await _client.posts.create(
      CreatePostRequest(title: 'Draft ${DateTime.now()}', status: 'draft'),
    );

    if (!mounted) {
      return;
    }

    final message = response.wasQueued
        ? 'Offline: draft queued (${await _queue.length} waiting)'
        : response.isSuccessful
            ? 'Draft created'
            : 'Failed: ${_describe(response)}';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String? _describe(WordpressResponse<Object?> response) {
    return response is WordpressFailureResponse
        ? (response.error?.message ?? response.message)
        : response.message;
  }

  Future<void> _sync() async {
    final result = await _queue.flush(_client);
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Sent ${result.sent.length}, rejected ${result.rejected.length}, '
          '${result.remaining} left',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Latest posts'),
        actions: [
          IconButton(
            tooltip: 'Send queued drafts',
            icon: const Icon(Icons.sync),
            onPressed: _sync,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => setState(() => _posts = _load()),
        child: FutureBuilder<List<Post>>(
          future: _posts,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return ListView(
                children: [ListTile(title: Text('${snapshot.error}'))],
              );
            }

            final posts = snapshot.requireData;

            return ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];

                return ListTile(
                  title: Text(post.title?.rendered ?? post.slug),
                  subtitle: Text(post.link),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _draft,
        icon: const Icon(Icons.edit),
        label: const Text('Draft'),
      ),
    );
  }
}
