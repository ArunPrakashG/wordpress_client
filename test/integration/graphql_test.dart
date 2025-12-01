
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

    // ─────────────────────────────────────────────────────────────────────────
    // Registered Queries Tests
    // ─────────────────────────────────────────────────────────────────────────

    test(
      'can register and execute a query',
      () async {
        final typeName = RegisteredQuery<Map<String, dynamic>>(
          name: 'getTypeName',
          document: '{ __typename }',
          parseData: (data) => data,
        );

        client.graphql.register(typeName);

        expect(client.graphql.isRegistered('getTypeName'), isTrue);
        expect(client.graphql.registeredQueryCount, greaterThanOrEqualTo(1));

        final res = await client.graphql
            .executeRegistered<Map<String, dynamic>>('getTypeName');

        expect(
          res is WordpressSuccessResponse<Map<String, dynamic>>,
          isTrue,
          reason: 'Expected registered query to succeed',
        );

        // Cleanup
        client.graphql.unregister('getTypeName');
        expect(client.graphql.isRegistered('getTypeName'), isFalse);
      },
      timeout: const Timeout(Duration(minutes: 2)),
    );

    test(
      'registered query with default variables can be overridden',
      () async {
        final postsQuery = RegisteredQuery<List<Map<String, dynamic>>>(
          name: 'getPosts',
          document: r'''
          query Posts($first: Int!) {
            posts(first: $first) {
              nodes { id title }
            }
          }
        ''',
          parseData: (data) {
            final nodes =
                (data['posts']?['nodes'] as List<dynamic>? ?? const [])
                    .cast<Map<String, dynamic>>();
            return nodes;
          },
          defaultVariables: {'first': 2},
        );

        client.graphql.register(postsQuery);

        // Execute with default variables
        final res1 = await client.graphql
            .executeRegistered<List<Map<String, dynamic>>>('getPosts');
        expect(res1 is WordpressSuccessResponse<List<Map<String, dynamic>>>,
            isTrue);

        // Execute with overridden variables
        final res2 =
            await client.graphql.executeRegistered<List<Map<String, dynamic>>>(
          'getPosts',
          variables: {'first': 1},
        );
        expect(res2 is WordpressSuccessResponse<List<Map<String, dynamic>>>,
            isTrue);

        // Cleanup
        client.graphql.unregister('getPosts');
      },
      timeout: const Timeout(Duration(minutes: 2)),
    );

    test(
      'registerAll registers multiple queries',
      () async {
        final query1 = RegisteredQuery<Map<String, dynamic>>(
          name: 'testQuery1',
          document: '{ __typename }',
          parseData: (data) => data,
        );
        final query2 = RegisteredQuery<Map<String, dynamic>>(
          name: 'testQuery2',
          document: '{ __typename }',
          parseData: (data) => data,
        );

        client.graphql.registerAll([query1, query2]);

        expect(client.graphql.isRegistered('testQuery1'), isTrue);
        expect(client.graphql.isRegistered('testQuery2'), isTrue);
        expect(client.graphql.registeredQueryNames,
            containsAll(['testQuery1', 'testQuery2']));

        // Cleanup
        client.graphql.clearRegistry();
        expect(client.graphql.registeredQueryCount, equals(0));
      },
      timeout: const Timeout(Duration(minutes: 1)),
    );

    test('throws when executing unregistered query', () async {
      expect(
        () => client.graphql
            .executeRegistered<Map<String, dynamic>>('nonExistent'),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('throws when registering duplicate without allowOverwrite', () {
      final query = RegisteredQuery<Map<String, dynamic>>(
        name: 'duplicateTest',
        document: '{ __typename }',
        parseData: (data) => data,
      );

      client.graphql.register(query);

      expect(
        () => client.graphql.register(query),
        throwsA(isA<ArgumentError>()),
      );

      // But allowOverwrite should work
      expect(
        () => client.graphql.register(query, allowOverwrite: true),
        returnsNormally,
      );

      // Cleanup
      client.graphql.unregister('duplicateTest');
    });

    test('getRegistered returns the registered query', () {
      final query = RegisteredQuery<Map<String, dynamic>>(
        name: 'getTest',
        document: '{ __typename }',
        parseData: (data) => data,
        defaultVariables: {'foo': 'bar'},
      );

      client.graphql.register(query);

      final retrieved =
          client.graphql.getRegistered<Map<String, dynamic>>('getTest');
      expect(retrieved, isNotNull);
      expect(retrieved!.name, equals('getTest'));
      expect(retrieved.defaultVariables, equals({'foo': 'bar'}));

      // Non-existent returns null
      expect(client.graphql.getRegistered<Map<String, dynamic>>('nonExistent'),
          isNull);

      // Cleanup
      client.graphql.unregister('getTest');
    });
  });
}
