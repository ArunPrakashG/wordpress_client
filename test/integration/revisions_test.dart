import 'package:faker/faker.dart';
import 'package:test/test.dart';
import 'package:wordpress_client/wordpress_client.dart';

import 'test_harness.dart';

void main() {
  group('Revisions', () {
    TestConfig? cfg;
    setUpAll(() async => cfg = await TestConfig.tryLoad());

    test('post revisions roundtrip (tolerant)', () async {
      cfg ??= await TestConfig.tryLoad();
      if (cfg == null) return;
      final client = await bootstrapClient(cfg!);
      final faker = Faker();

      int? postId;
      try {
        final created = await client.posts.create(
          CreatePostRequest(
            title: 'rev: ${faker.lorem.words(2).join(' ')}',
            content: '<p>${faker.lorem.sentences(2).join(' ')}</p>',
            status: 'draft',
          ),
        );
        if (created.code != 200 && created.code != 201) {
          expect(created.code, anyOf(401, 403));
          return;
        }
        postId = created.asSuccess().data.id;

        final updated = await client.posts.update(
          UpdatePostRequest(
            id: postId,
            content: '<p>${faker.lorem.sentences(3).join(' ')}</p>',
          ),
        );
        expect(updated.code, anyOf(200, 401, 403));
        if (updated.code != 200) return;

        final revisions = await client.postRevisions.list(
          ListPostRevisionsRequest(postId: postId),
        );
        expect(revisions.code, anyOf(200, 401, 403));
        if (revisions.code == 200) {
          expect(revisions.asSuccess().data.length, greaterThanOrEqualTo(1));
        }
      } finally {
        if (postId != null) {
          try {
            await client.posts
                .delete(DeletePostRequest(id: postId, force: true));
          } catch (_) {}
        }
      }
    });
  });
}
