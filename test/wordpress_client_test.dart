// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:test/test.dart';
import 'package:wordpress_client/wordpress_client.dart';

String getRandString(int len) {
  final random = Random.secure();
  final values = List<int>.generate(len, (i) => random.nextInt(255));
  return base64UrlEncode(values);
}

Future<void> main() async {
  final jsonFileContents = await File('test/test_settings.json').readAsString();
  final dynamic json = jsonDecode(jsonFileContents);

  final baseUrl = Uri.parse(json['base_url'] as String);

  final client = WordpressClient(
    baseUrl: baseUrl,
    bootstrapper: (builder) => builder
        .withDefaultMaxRedirects(5)
        .withFollowRedirects(true)
        .withRequestTimeout(const Duration(seconds: 60))
        .withDebugMode(false)
        .withDefaultAuthorizationBuilder(
          (authBuilder) => authBuilder
              .withUserName(json!['username'] as String)
              .withPassword(json['password'] as String)
              .withType(AuthorizationType.useful_jwt)
              .withEvents(
                const WordpressEvents(
                  onError: print,
                ),
              )
              .build(),
        )
        .withMiddleware(
          DelegatedMiddleware(
            onRequestDelegate: (request) async {
              // print('Request: ${request.url}');
              return request;
            },
            onResponseDelegate: (response) async {
              // print('Response: ${response.code}');
              return response;
            },
          ),
        )
        .build(),
  );

  client.initialize();

  group(
    'Post Requests: ',
    () {
      const MAX_PAGES = 30;
      const MAX_PER_PAGE = 15;

      print('Max Pages: $MAX_PAGES');
      print('Max Per Page: $MAX_PER_PAGE');
      var parallelMs = 0;
      var sequentialMs = 0;

      test(
        'Parallel',
        () async {
          final stopwatch = Stopwatch()..start();
          final parallelWordpress = ParallelWordpress(client: client);

          print('Starting Parallel...');
          final responses = await parallelWordpress.list(
            interface: client.posts,
            requestBuilder: () {
              return List.generate(
                MAX_PAGES,
                (index) => ParallelRequest(
                  page: index + 1,
                  request: ListPostRequest(
                    perPage: MAX_PER_PAGE,
                    page: index + 1,
                  ),
                ),
              );
            },
          );

          stopwatch.stop();
          parallelMs = stopwatch.elapsed.inMilliseconds;
          print('Parallel Time Taken: $parallelMs ms');

          expect(
            responses.length,
            MAX_PAGES * MAX_PER_PAGE,
            reason: 'Responses length should be equal to MAX_PAGES.',
          );

          const expectedTotalLength = MAX_PAGES * MAX_PER_PAGE;
          final actualTotalLength = responses.length;

          expect(
            actualTotalLength,
            expectedTotalLength,
            reason:
                'Total length of all responses should be equal to MAX_PAGES * MAX_PER_PAGE.',
          );
        },
      );

      test(
        'Sequential',
        () async {
          final stopwatch = Stopwatch()..start();
          final responses = <List<Post>>[];

          print('Starting Sequential...');
          for (var index = 0; index < MAX_PAGES; index++) {
            final page = index + 1;
            final response = await client.posts.list(
              ListPostRequest(
                perPage: MAX_PER_PAGE,
                page: page,
              ),
            );

            responses.add(response.asSuccess().data);
          }

          final folded = responses.fold<List<Post>>(
            <Post>[],
            (previousValue, element) =>
                previousValue.followedBy(element).map((e) => e).toList(),
          );

          stopwatch.stop();
          sequentialMs = stopwatch.elapsed.inMilliseconds;
          print('Sequential Time Taken: $sequentialMs ms');

          expect(
            folded.length,
            MAX_PAGES * MAX_PER_PAGE,
            reason: 'Responses length should be equal to MAX_PAGES.',
          );

          const expectedTotalLength = MAX_PAGES * MAX_PER_PAGE;
          final actualTotalLength = folded.length;

          expect(
            actualTotalLength,
            expectedTotalLength,
            reason:
                'Total length of all responses should be equal to MAX_PAGES * MAX_PER_PAGE.',
          );
        },
      );

      test('Check time difference', () async {
        while (parallelMs == 0 || sequentialMs == 0) {
          await Future.delayed(const Duration(milliseconds: 100));
        }

        final difference = sequentialMs - parallelMs;
        final percentage = (difference / sequentialMs) * 100;

        print('Difference: $difference ms (${percentage.toStringAsFixed(2)}%)');

        expect(
          parallelMs < sequentialMs,
          true,
          reason: 'Parallel time should be less than sequential time.',
        );
      });
    },
  );

  group(
    'Discovery',
    () {
      test(
        'Discovery Request',
        () async {
          final result = await client.discover();

          expect(true, result);
        },
      );

      test(
        'Discovery Data',
        () async {
          expect(json['base_host'] as String, client.discovery.home);
        },
      );
    },
  );

  group('Pages', () {
    test(
      'List Pages',
      () async {
        final response = await client.pages.list(
          ListPageRequest(
            perPage: 2,
          ),
        );

        expect(200, response.code);
        expect(2, response.asSuccess().data.length);
      },
    );
  });

  group('', () {
    test(
      'Response Time',
      () async {
        final firstResponse = await client.posts.list(
          ListPostRequest(
            perPage: 20,
          ),
        );

        final secondResponse = await client.posts.list(
          ListPostRequest(
            perPage: 20,
          ),
        );

        print(
          'First Response Time Taken: ${firstResponse.duration.inMilliseconds} ms',
        );
        print(
          'Second Response Time Taken: ${secondResponse.duration.inMilliseconds} ms',
        );

        expect(200, firstResponse.code);
        expect(200, secondResponse.code);
      },
    );

    test('List Posts', () async {
      final response = await client.posts.list(
        ListPostRequest(
          perPage: 20,
        ),
      );

      expect(200, response.code);
      expect(20, response.asSuccess().data.length);
    });

    test('List Tags', () async {
      final response = await client.tags.list(
        ListTagRequest(
          perPage: 20,
        ),
      );

      expect(200, response.code);
      expect(20, response.asSuccess().data.length);
    });

    test('List Category', () async {
      final response = await client.categories.list(
        ListCategoryRequest(
          perPage: 2,
        ),
      );

      expect(200, response.code);
      expect(2, response.asSuccess().data.length);
    });

    test('List Media', () async {
      final response = await client.media.list(
        ListMediaRequest(
          perPage: 20,
        ),
      );

      expect(200, response.code);
      expect(
        19,
        response.asSuccess().data.length,
        reason:
            'For some reason, WP API is only returning PER_PAGE - 1 values.',
        skip: true,
      );
    });

    test('List Users', () async {
      final response = await client.users.list(ListUserRequest());

      expect(200, response.code);
      expect(10, response.asSuccess().data.length);
    });
  });

  group('', () {
    test('Retrive Current User', () async {
      final response = await client.me.retrieve(
        RetrieveMeRequest(),
      );

      expect(200, response.code);
      expect('desk02', response.asSuccess().data.slug);
    });
  });

  // group(
  //   '',
  //   () {
  //     if (mailResponse == null || mailResponse.isEmpty) {
  //       fail('No temp emails generated.');
  //     }

  //     final email = mailResponse[0];
  //     int? userId = 0;

  //     late WordpressResponse<User> createResponse;

  //     test('Create User', () async {
  //       createResponse = await client.users.create(
  //         CreateUserRequest(
  //           username: getRandString(10),
  //           email: email,
  //           password: getRandString(10),
  //         ),
  //       );
  //     });

  //     expect(201, createResponse.code);
  //     expect('gen_user_slug', createResponse.asSuccess().data.slug);
  //     userId = createResponse.asSuccess().data.id;

  //     test('Update User', () async {
  //       final response = await client.users.update(
  //         UpdateUserRequest(
  //           email: email,
  //           id: userId!,
  //           username: createResponse.asSuccess().data.username!,
  //           firstName: 'updated first name',
  //         ),
  //       );

  //       expect(200, response.code);
  //       expect('updated first name', response.asSuccess().data.firstName);
  //     });

  //     test('Retrive User', () async {
  //       final response = await client.users.retrive(
  //         RetriveUserRequest(
  //           id: userId!,
  //         ),
  //       );

  //       expect(200, response.code);
  //       expect(userId, response.asSuccess().data.id);
  //     });
  //   },
  // );

  // group('', () {
  //   int? postId = -1;

  //   test(
  //     'Create Post',
  //     () async {
  //       final response = await client.posts.create(
  //         (builder) => builder
  //             .withCommentStatus(Status.closed)
  //             .withPingStatus(Status.closed)
  //             .withFormat(PostFormat.standard)
  //             .withContent(
  //                 'This a test post generated by an automated script using wordpress_client library. This post will be deleted automatically in short time.')
  //             .withExcerpt('A test post!')
  //             .withTitle('Generated Sample Post')
  //             .withSlug('generated-post-slug')
  //             .withStatus(ContentStatus.pending)
  //             .withFeaturedMedia(468930)
  //             .withAuthor(3)
  //             .withCallback(Callback(
  //           requestErrorCallback: (error) {
  //             print('Error: ' + error.errorResponse!.message!);
  //           },
  //         )).build(),
  //       );

  //       expect(201, response.responseCode);
  //       postId = response.data!.id;
  //       expect('Generated Sample Post', response.data!.title!.parsedText);
  //       expect('generated-post-slug', response.data!.slug);
  //     },
  //   );

  //   test('Update Post', () async {
  //     final response = await client.posts.update(
  //       (builder) => builder
  //           .withId(postId)
  //           .withFeaturedMedia(468930)
  //           .withAuthor(3)
  //           .withTitle('Generated Sample Post Edited')
  //           .withCallback(
  //         Callback(
  //           requestErrorCallback: (error) {
  //             print('Error: ' + error.errorResponse!.message!);
  //           },
  //         ),
  //       ).build(),
  //     );

  //     expect(200, response.responseCode);
  //     expect('Generated Sample Post Edited', response.data!.title!.parsedText);
  //     expect('generated-post-slug', response.data!.slug);
  //   });

  //   test('Retrive Post', () async {
  //     final response = await client.posts.retrive(
  //       (builder) => builder.withPostId(postId).build(),
  //     );

  //     expect(200, response.responseCode);
  //     expect(postId, response.data!.id);
  //   });

  //   test('Delete Post', () async {
  //     final deleteResponse = await client.posts.delete(
  //       (builder) => builder.withPostId(postId).withCallback(
  //         Callback(
  //           requestErrorCallback: (error) {
  //             print('Error: ' + error.errorResponse!.message!);
  //           },
  //         ),
  //       ).build(),
  //     );

  //     expect(200, deleteResponse.responseCode);
  //   });
  // }, timeout: Timeout(Duration(minutes: 1)));
}
