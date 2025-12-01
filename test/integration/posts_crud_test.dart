import 'package:faker/faker.dart';
import 'package:test/test.dart';
import 'package:wordpress_client/wordpress_client.dart';

import 'test_harness.dart';

void main() {
  group('Posts CRUD', () {
    TestConfig? cfg;
    final faker = Faker();

    setUpAll(() async {
      cfg = await TestConfig.tryLoad();
    });

    test('create, update, retrieve, delete', () async {
      cfg ??= await TestConfig.tryLoad();
      if (cfg == null) return;
      final client = await bootstrapClient(cfg!);

      int? postId;
      try {
        // Create
        final title = 'wc: ${faker.lorem.sentence()}';
        final content = '<p>${faker.lorem.sentences(3).join(' ')}</p>';
        final created = await client.posts.create(
          CreatePostRequest(
            title: title,
            content: content,
            status: 'draft',
          ),
        );
        if (created.code != 200 && created.code != 201) {
          // Some sites require auth/caps to create posts; bail gracefully
          expect(created.code, anyOf(401, 403));
          return;
        }
        final createdPost = created.asSuccess().data;
        postId = createdPost.id;
        expect(createdPost.title?.rendered?.isNotEmpty ?? true, true);

        // Update
        final newTitle = 'wc-upd: ${faker.lorem.words(3).join(' ')}';
        final updated = await client.posts.update(
          UpdatePostRequest(
            id: postId,
            title: newTitle,
          ),
        );
        if (updated.code != 200) {
          // Some sites require elevated caps; bail out gracefully.
          expect(updated.code, anyOf(200, 401, 403));
          return;
        }
        expect(
          updated.asSuccess().data.title?.rendered?.contains(newTitle) ?? true,
          true,
        );

        // Retrieve
        final retrieved = await client.posts.retrieve(
          RetrievePostRequest(id: postId),
        );
        expect(retrieved.code, anyOf(200, 401, 403));
        if (retrieved.code == 200) {
          expect(retrieved.asSuccess().data.id, postId);
        }
      } finally {
        if (postId != null) {
          final del = await client.posts.delete(
            DeletePostRequest(id: postId, force: true),
          );
          expect(del.code, anyOf(200, 401, 403, 410));
        }
      }
    });
  });
}
