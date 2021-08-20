import 'dart:convert';
import 'dart:io';

import 'package:temp_mail_gen/temp_mail_gen.dart';
import 'package:test/test.dart';
import 'package:wordpress_client/src/utilities/helpers.dart';
import 'package:wordpress_client/wordpress_client.dart';

void main() async {
  WordpressClient client;
  TempMailClient tempMailClient;
  Map<String, dynamic>? json;

  json = jsonDecode(await (await File('test/test_settings.json')).readAsString());
  client = WordpressClient(
    json!['base_url'],
    json['path'],
    bootstrapper: (builder) => builder
        .withDefaultMaxRedirects(5)
        .withFollowRedirects(true)
        .withRequestTimeout(60)
        .withStatisticDelegate((requestUrl, endpoint, count) {
          print('Request URL: $requestUrl');
        })
        .withDefaultAuthorizationBuilder(
          (authBuilder) => authBuilder
              .withUserName(json!['username'])
              .withPassword(json['password'])
              .withType(AuthorizationType.USEFUL_JWT)
              .withCallback(
                Callback(
                  responseCallback: (response) {
                    print(response);
                  },
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
    test('List Posts', () async {
      final response = await client.listPost(
        (builder) => builder.withPerPage(20).withPageNumber(1).build(),
      );

      expect(200, response.responseCode);
      expect(20, response.value!.length);
    });

    test('List Tags', () async {
      final response = await client.listTag(
        (builder) => builder.withPerPage(20).withPageNumber(1).build(),
      );

      expect(200, response.responseCode);
      expect(20, response.value!.length);
    });

    test('List Category', () async {
      final response = await client.listCategory(
        (builder) => builder.withPerPage(2).withPageNumber(1).build(),
      );

      expect(200, response.responseCode);
      expect(2, response.value!.length);
    });

    test('List Media', () async {
      final response = await client.listMedia(
        (builder) => builder.withPerPage(20).withPageNumber(1).build(),
      );

      expect(200, response.responseCode);
      expect(19, response.value!.length, reason: 'For some reason, WP API is only returning PER_PAGE - 1 values.', skip: true);
    });

    test('List Users', () async {
      final response = await client.listUsers(
        (builder) => builder.withPerPage(10).withPageNumber(1).build(),
      );

      expect(200, response.responseCode);
      expect(10, response.value!.length);
    });
  }, timeout: Timeout(Duration(minutes: 1)));

  group('', () {
    test('Retrive Current User', () async {
      final response = await client.retriveMe(
        (builder) => builder.withCallback(Callback(
          requestErrorCallback: (error) {
            print('Error: ' + error.errorResponse!.message!);
          },
        )).build(),
      );

      expect(200, response.responseCode);
      expect('arunprakash', response.value!.slug);
    });
  }, timeout: Timeout(Duration(minutes: 1)));

  group('', () {
    if (mailResponse == null || mailResponse.isEmpty) {
      fail('No temp emails generated.');
    }

    final email = mailResponse[0];
    int? userId = 0;

    test('Create User', () async {
      final response = await client.createUser(
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
      expect('gen_user_slug', response.value!.slug);
      userId = response.value!.id;
    });

    test('Update User', () async {
      final response = await client.updateUser((builder) => builder.withId(userId).withFirstName('updated first name').build());

      expect(200, response.responseCode);
      expect('updated first name', response.value!.firstName);
    });

    test('Retrive User', () async {
      final response = await client.retriveUser((builder) => builder.withUserId(userId).build());

      expect(200, response.responseCode);
      expect(userId, response.value!.id);
    });

    test('Delete User', () async {
      final deleteUserResponse = await client.deleteUser(
        (builder) => builder.withUserId(userId).withForce(true).withReassign(3).withCallback(
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
        final response = await client.createPost(
          (builder) => builder
              .withCommentStatus(Status.CLOSED)
              .withPingStatus(Status.CLOSED)
              .withFormat(PostFormat.STANDARD)
              .withContent(
                  'This a test post generated by an automated script using wordpress_client library. This post will be deleted automatically in short time.')
              .withExcerpt('A test post!')
              .withTitle('Generated Sample Post')
              .withSlug('generated-post-slug')
              .withStatus(ContentStatus.PENDING)
              .withFeaturedMedia(468930)
              .withAuthor(3)
              .withCallback(Callback(
            requestErrorCallback: (error) {
              print('Error: ' + error.errorResponse!.message!);
            },
          )).build(),
        );

        expect(201, response.responseCode);
        postId = response.value!.id;
        expect('Generated Sample Post', response.value!.title!.parsedText);
        expect('generated-post-slug', response.value!.slug);
      },
    );

    test('Update Post', () async {
      final response = await client.updatePost(
        (builder) => builder.withId(postId).withFeaturedMedia(468930).withAuthor(3).withTitle('Generated Sample Post Edited').withCallback(
          Callback(
            requestErrorCallback: (error) {
              print('Error: ' + error.errorResponse!.message!);
            },
          ),
        ).build(),
      );

      expect(200, response.responseCode);
      expect('Generated Sample Post Edited', response.value!.title!.parsedText);
      expect('generated-post-slug', response.value!.slug);
    });

    test('Retrive Post', () async {
      final response = await client.retrivePost(
        (builder) => builder.withPostId(postId).build(),
      );

      expect(200, response.responseCode);
      expect(postId, response.value!.id);
    });

    test('Delete Post', () async {
      final deleteResponse = await client.deletePost(
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
