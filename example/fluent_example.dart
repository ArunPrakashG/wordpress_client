import 'dart:developer' as dev;

import 'package:wordpress_client/wordpress_client.dart';

// This example demonstrates the fluent request builders layered over the existing API.
// It does not change the public API; instead, it adds extension helpers like listFluent.
Future<void> main() async {
  final client = WordpressClient(
    baseUrl: Uri.parse('https://example.com/wp-json/wp/v2'),
    bootstrapper: (b) => b.build(),
  );

  // Fluent list: start with a regular ListPostRequest seed
  final listRes = await client.posts.query
      .withPage(1)
      .withPerPage(5)
      .withSearch('welcome')
      .withInclude([1, 2, 3])
      .withCategories([10, 20])
      .withOrder(Order.desc)
      .execute();

  listRes.map(
    onSuccess: (s) {
      for (final p in s.data) {
        final t = p.title?.rendered ?? '(untitled)';
        dev.log('Post: $t');
      }
      return null;
    },
    onFailure: (f) {
      dev.log('List failed: ${f.message ?? ''}', level: 900);
      return null;
    },
  );

  // Simple extension retrieve
  final ret = await client.posts.extensions.getById(1);

  if (ret.isSuccessful) {
    dev.log('Retrieved post id: ${ret.asSuccess().data.id}');
  }
}
