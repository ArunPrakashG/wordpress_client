
import 'package:test/test.dart';
import 'package:wordpress_client/wordpress_client.dart';

import 'test_harness.dart';

void main() {
  group('GraphQL (WPGraphQL)', () {
    late TestConfig cfg;
    late WordpressClient client;
    late bool hasAuth; // credentials provided
    late bool isAuthenticated; // verified via viewer query

    setUpAll(() async {
      final maybeCfg = await TestConfig.tryLoad();
      if (maybeCfg == null) {
        throw StateError('Missing test config. Provide test/test_local.json or env vars.');
      }
      cfg = maybeCfg;
      client = await bootstrapClient(cfg);
  hasAuth = cfg.appPassword != null || (cfg.username != null && cfg.password != null);
  isAuthenticated = false;

      // Ensure the REST base is reachable to derive GraphQL endpoint from it.
      final ok = await isRestReachable(cfg.baseUrl);
      if (!ok) {
        throw StateError('REST base not reachable at ${cfg.baseUrl}');
      }

      // Probe actual auth status via viewer query (non-fatal)
      if (hasAuth) {
        final probe = await client.graphql.query<Map<String, dynamic>>(
          document: '{ viewer { databaseId username name } }',
          parseData: (d) => d,
        );
        if (probe is WordpressSuccessResponse<Map<String, dynamic>>) {
          final v = probe.data['viewer'];
          isAuthenticated = v != null && v['databaseId'] != null;
        }
      }
    });

    tearDownAll(() {
      client.dispose();
    });

    test('GraphQL __typename query returns a payload', () async {
      final res = await client.graphql.query<Map<String, dynamic>>(
        document: '{ __typename }',
        parseData: (data) => data,
      );

      expect(res is WordpressSuccessResponse<Map<String, dynamic>>, isTrue,
          reason: 'Expected a successful GraphQL response.',);
    }, timeout: const Timeout(Duration(minutes: 2)),);

    test('GraphQL errors are mapped to failure', () async {
      // Intentionally query an unknown field to trigger an error
      final res = await client.graphql.query<Map<String, dynamic>>(
        document: '{ unknownField }',
        parseData: (data) => data,
      );

      expect(res is WordpressFailureResponse<Map<String, dynamic>>, isTrue,
          reason: 'Expected a failure response due to GraphQL error.',);
    }, timeout: const Timeout(Duration(minutes: 2)),);

    test('GraphQL error payload includes message/locations/extensions', () async {
      final res = await client.graphql.query<Map<String, dynamic>>(
        document: '{ unknownField }',
        parseData: (data) => data,
      );

      expect(res, isA<WordpressFailureResponse<Map<String, dynamic>>>());
      final fail = res as WordpressFailureResponse<Map<String, dynamic>>;

      // error.message from aggregated GraphQL messages
      expect(fail.error, isNotNull);
      expect(fail.error!.message, isNotEmpty);

      // raw GraphQL envelope is accessible via index operator
      final errors = fail['errors'] as List?;
      expect(errors, isA<List>());
      expect(errors!.isNotEmpty, isTrue);

      final first = errors.first as Map<String, dynamic>;
      expect(first['message'], isA<String>());

      // locations should be a list with objects having line/column
      if (first['locations'] != null) {
        expect(first['locations'], isA<List>());
        final loc = (first['locations'] as List).first as Map<String, dynamic>;
        expect(loc['line'], isA<int>());
        expect(loc['column'], isA<int>());
      }

      // extensions may exist; if present, must be a map (WPGraphQL often sets category/path)
      if (first['extensions'] != null) {
        expect(first['extensions'], isA<Map<String, dynamic>>());
      }
    }, timeout: const Timeout(Duration(minutes: 2)),);

    test('Query posts list returns nodes', () async {
      const doc = '''
        query PostsList {
          posts(first: 3) {
            nodes { databaseId title }
          }
        }
      ''';

      final res = await client.graphql.query<Map<String, dynamic>>(
        document: doc,
        parseData: (data) => data,
      );

      expect(res is WordpressSuccessResponse<Map<String, dynamic>>, isTrue,
          reason: 'Expected posts list query to succeed',);

      final ok = res as WordpressSuccessResponse<Map<String, dynamic>>;
      final nodes = (ok.data['posts']?['nodes'] as List?) ?? const [];
      // It's okay if site has 0 posts; just ensure shape is a list
      expect(nodes, isA<List>());
    }, timeout: const Timeout(Duration(minutes: 2)),);

    test('Query with variables: fetch post by databaseId', () async {
      // First fetch an available databaseId
      const listDoc = '''query One { posts(first: 1) { nodes { databaseId } } }''';
      final listRes = await client.graphql.query<Map<String, dynamic>>(
        document: listDoc,
        parseData: (d) => d,
      );
      if (listRes is! WordpressSuccessResponse<Map<String, dynamic>>) {
        // Can't proceed reliably
        return;
      }
      final nodes = (listRes.data['posts']?['nodes'] as List?) ?? const [];
      if (nodes.isEmpty || nodes.first == null || nodes.first['databaseId'] == null) {
        // No posts available. If auth present, attempt to create one; else skip.
        if (!hasAuth) return;

        final created = await client.graphql.mutate<Map<String, dynamic>>(
          document: r'''
            mutation Create($input: CreatePostInput!) {
              createPost(input: $input) {
                post { id databaseId title status }
              }
            }
          ''',
          variables: {
            'input': {
              'title': 'Temp Post ${DateTime.now().toIso8601String()}',
              'content': 'Created for integration test',
              'status': 'DRAFT',
            },
          },
          parseData: (d) => d,
        );
        if (created is! WordpressSuccessResponse<Map<String, dynamic>>) return;
        final createdId = created.data['createPost']?['post']?['databaseId'] as int?;
        if (createdId == null) return;

        // Proceed with querying the created post by databaseId
        final getRes = await client.graphql.query<Map<String, dynamic>>(
          document: r'''
            query Get($id: ID!) {
              post(id: $id, idType: DATABASE_ID) { databaseId title }
            }
          ''',
          variables: {'id': createdId.toString()},
          parseData: (d) => d,
        );
        expect(getRes is WordpressSuccessResponse<Map<String, dynamic>>, isTrue);

        // Cleanup if possible
        final createdGlobalId = created.data['createPost']?['post']?['id'] as String?;
        if (createdGlobalId != null) {
          await client.graphql.mutate<Map<String, dynamic>>(
            document: r'''
              mutation Delete($input: DeletePostInput!) {
                deletePost(input: $input) { deletedId }
              }
            ''',
            variables: {
              'input': {'id': createdGlobalId},
            },
            parseData: (d) => d,
          );
        }
        return;
      }

      final dbId = nodes.first['databaseId'] as int;
      final res = await client.graphql.query<Map<String, dynamic>>(
        document: r'''
          query Get($id: ID!) {
            post(id: $id, idType: DATABASE_ID) { databaseId title }
          }
        ''',
        variables: {'id': dbId.toString()},
        parseData: (d) => d,
      );

      expect(res is WordpressSuccessResponse<Map<String, dynamic>>, isTrue,
          reason: 'Expected fetching post by databaseId to succeed',);
      final ok = res as WordpressSuccessResponse<Map<String, dynamic>>;
      expect(ok.data['post']?['databaseId'], dbId);
    }, timeout: const Timeout(Duration(minutes: 3)),);

    test('Authenticated viewer query (skips if no auth)', () async {
      if (!isAuthenticated) {
        // No credentials; skip dynamically
        return;
      }

      final res = await client.graphql.query<Map<String, dynamic>>(
        document: '{ viewer { databaseId name username } }',
        parseData: (d) => d,
      );

      expect(res is WordpressSuccessResponse<Map<String, dynamic>>, isTrue,
          reason: 'Expected viewer query to succeed when authenticated',);
      final ok = res as WordpressSuccessResponse<Map<String, dynamic>>;
      expect(ok.data['viewer']?['databaseId'], isNotNull);
    }, timeout: const Timeout(Duration(minutes: 2)),);

    test('Create and delete post mutation (auth required)', () async {
      if (!isAuthenticated) return;

      // Create
      final title = 'GraphQL E2E ${DateTime.now().millisecondsSinceEpoch}';
      final createRes = await client.graphql.mutate<Map<String, dynamic>>(
        document: r'''
          mutation Create($input: CreatePostInput!) {
            createPost(input: $input) {
              post { id databaseId title status }
            }
          }
        ''',
        variables: {
          'input': {
            'title': title,
            'content': 'Content created via integration test',
            'status': 'DRAFT',
          },
        },
        parseData: (d) => d,
      );

      expect(createRes is WordpressSuccessResponse<Map<String, dynamic>>, isTrue,
          reason: 'Expected createPost mutation to succeed',);
      final created = createRes as WordpressSuccessResponse<Map<String, dynamic>>;
      final createdId = created.data['createPost']?['post']?['id'] as String?;
      expect(createdId, isNotNull, reason: 'Mutation should return post.id');

      // Delete (cleanup)
      final deleteRes = await client.graphql.mutate<Map<String, dynamic>>(
        document: r'''
          mutation Delete($input: DeletePostInput!) {
            deletePost(input: $input) {
              deletedId
              post { databaseId status }
            }
          }
        ''',
        variables: {
          'input': {'id': createdId},
        },
        parseData: (d) => d,
      );

      expect(deleteRes is WordpressSuccessResponse<Map<String, dynamic>>, isTrue,
          reason: 'Expected deletePost mutation to succeed',);
    }, timeout: const Timeout(Duration(minutes: 3)),);
  });
}
