import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:temp_mail_gen/temp_mail_gen.dart';
import 'package:test/test.dart';
import 'package:wordpress_client/src/requests/list/list_post.dart';
import 'package:wordpress_client/src/requests/list/list_tag.dart';
import 'package:wordpress_client/wordpress_client.dart';
import 'package:path_provider/path_provider.dart';

String getRandString(int len) {
  var random = Random.secure();
  var values = List<int>.generate(len, (i) => random.nextInt(255));
  return base64UrlEncode(values);
}

Future<void> main() async {
  WordpressClient client;
  TempMailClient tempMailClient;
  Map<String, dynamic>? json;

  final cachePath = (await getTemporaryDirectory()).path;

  final jsonFileContents = await File('test/test_settings.json').readAsString();

  json = jsonDecode(jsonFileContents) as Map<String, dynamic>;
  client = WordpressClient(
    json['base_url'] as String,
    json['path'] as String,
    bootstrapper: (builder) => builder
        .withDefaultMaxRedirects(5)
        .withFollowRedirects(true)
        .withRequestTimeout(60)
        .withResponseCache(true)
        .withCachePath(cachePath)
        .withStatisticDelegate((requestUrl, endpoint, count) {
          print('Request URL: $requestUrl');
        })
        .withDefaultAuthorizationBuilder(
          (authBuilder) => authBuilder
              .withUserName(json!['username'] as String)
              .withPassword(json['password'] as String)
              .withType(AuthorizationType.useful_jwt)
              .withCallback(
                Callback(
                  responseCallback: print,
                  requestErrorCallback: (error) {
                    print('Error: ${error.errorResponse!.message}');
                  },
                ),
              )
              .build(),
        )
        .build(),
  );

  tempMailClient = TempMailClient();
  final mailResponse = await tempMailClient.getEmails(1);

  group('', () {
    test(
      'Response Time',
      () async {
        final firstResponse = await client.posts.list(
          WordpressRequest(
            requestData: ListPostRequest(
              perPage: 20,
            ),
          ),
        );

        final secondResponse = await client.posts.list(
          (builder) => builder.withPerPage(20).withPageNumber(1).build(),
        );

        print(
            'First Response Time Taken: ${firstResponse.requestDuration?.inMilliseconds} ms');
        print(
            'Second Response Time Taken: ${secondResponse.requestDuration?.inMilliseconds} ms');

        expect(200, firstResponse.responseCode);
        expect(200, secondResponse.responseCode);
      },
    );

    test('List Posts', () async {
      final response = await client.posts.list(
        (builder) => builder.withPerPage(20).withPageNumber(1).build(),
      );

      expect(200, response.responseCode);
      expect(20, response.data!.length);
    });

    test('List Tags', () async {
      final response = await client.tags.list(
        (builder) => builder.withPerPage(20).withPageNumber(1).build(),
      );

      expect(200, response.responseCode);
      expect(20, response.data!.length);
    });

    test('List Category', () async {
      final response = await client.categories.list(
        (builder) => builder.withPerPage(2).withPageNumber(1).build(),
      );

      expect(200, response.responseCode);
      expect(2, response.data!.length);
    });

    test('List Media', () async {
      final response = await client.media.list(
        (builder) => builder.withPerPage(20).withPageNumber(1).build(),
      );

      expect(200, response.responseCode);
      expect(19, response.data!.length,
          reason:
              'For some reason, WP API is only returning PER_PAGE - 1 values.',
          skip: true);
    });

    test('List Users', () async {
      final response = await client.users.list(
        (builder) => builder.withPerPage(10).withPageNumber(1).build(),
      );

      expect(200, response.responseCode);
      expect(10, response.data!.length);
    });
  }, timeout: Timeout(Duration(minutes: 1)));

  group('', () {
    test('Retrive Current User', () async {
      final response = await client.me.retrive(
        (builder) => builder.withCallback(Callback(
          requestErrorCallback: (error) {
            print('Error: ' + error.errorResponse!.message!);
          },
        )).build(),
      );

      expect(200, response.responseCode);
      expect('arunprakash', response.data!.slug);
    });
  }, timeout: Timeout(Duration(minutes: 1)));

  group('', () {
    if (mailResponse == null || mailResponse.isEmpty) {
      fail('No temp emails generated.');
    }

    final email = mailResponse[0];
    int? userId = 0;

    test('Create User', () async {
      final response = await client.users.create(
        (builder) => builder
            .withEmail(email)
            .withDescription('Generate User')
            .withDisplayName('gen_user')
            .withUserName('generated_user_test')
            .withPassword(getRandString(13))
            .withSlug('gen_user_slug')
            .withCallback(
          Callback(
            requestErrorCallback: (error) {
              print('Error: ' + error.errorResponse!.message!);
            },
          ),
        ).build(),
      );

      expect(201, response.responseCode);
      expect('gen_user_slug', response.data!.slug);
      userId = response.data!.id;
    });

    test('Update User', () async {
      final response = await client.users.update((builder) =>
          builder.withId(userId).withFirstName('updated first name').build());

      expect(200, response.responseCode);
      expect('updated first name', response.data!.firstName);
    });

    test('Retrive User', () async {
      final response = await client.users
          .retrive((builder) => builder.withUserId(userId).build());

      expect(200, response.responseCode);
      expect(userId, response.data!.id);
    });

    test('Delete User', () async {
      final deleteUserResponse = await client.users.delete(
        (builder) => builder
            .withUserId(userId)
            .withForce(true)
            .withReassign(3)
            .withCallback(
          Callback(
            requestErrorCallback: (error) {
              print('Error: ' + error.errorResponse!.message!);
            },
          ),
        ).build(),
      );

      expect(200, deleteUserResponse.responseCode);
    });
  }, timeout: Timeout(Duration(minutes: 1)));

  group('', () {
    int? postId = -1;

    test(
      'Create Post',
      () async {
        final response = await client.posts.create(
          (builder) => builder
              .withCommentStatus(Status.closed)
              .withPingStatus(Status.closed)
              .withFormat(PostFormat.standard)
              .withContent(
                  'This a test post generated by an automated script using wordpress_client library. This post will be deleted automatically in short time.')
              .withExcerpt('A test post!')
              .withTitle('Generated Sample Post')
              .withSlug('generated-post-slug')
              .withStatus(ContentStatus.pending)
              .withFeaturedMedia(468930)
              .withAuthor(3)
              .withCallback(Callback(
            requestErrorCallback: (error) {
              print('Error: ' + error.errorResponse!.message!);
            },
          )).build(),
        );

        expect(201, response.responseCode);
        postId = response.data!.id;
        expect('Generated Sample Post', response.data!.title!.parsedText);
        expect('generated-post-slug', response.data!.slug);
      },
    );

    test('Update Post', () async {
      final response = await client.posts.update(
        (builder) => builder
            .withId(postId)
            .withFeaturedMedia(468930)
            .withAuthor(3)
            .withTitle('Generated Sample Post Edited')
            .withCallback(
          Callback(
            requestErrorCallback: (error) {
              print('Error: ' + error.errorResponse!.message!);
            },
          ),
        ).build(),
      );

      expect(200, response.responseCode);
      expect('Generated Sample Post Edited', response.data!.title!.parsedText);
      expect('generated-post-slug', response.data!.slug);
    });

    test('Retrive Post', () async {
      final response = await client.posts.retrive(
        (builder) => builder.withPostId(postId).build(),
      );

      expect(200, response.responseCode);
      expect(postId, response.data!.id);
    });

    test('Delete Post', () async {
      final deleteResponse = await client.posts.delete(
        (builder) => builder.withPostId(postId).withCallback(
          Callback(
            requestErrorCallback: (error) {
              print('Error: ' + error.errorResponse!.message!);
            },
          ),
        ).build(),
      );

      expect(200, deleteResponse.responseCode);
    });
  }, timeout: Timeout(Duration(minutes: 1)));
}
