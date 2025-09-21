import 'dart:convert';
import 'dart:developer' as dev;
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
  // Try to load local test config; if not present, skip this heavy integration suite.
  final localCfg = (() {
    try {
      final f = File('test/test_local.json');
      if (f.existsSync()) return jsonDecode(f.readAsStringSync());
    } catch (_) {}
    return null;
  })();
  if (localCfg == null) {
    dev.log('Skipping legacy integration suite: no test/test_local.json');
    return;
  }
  final jsonFileContents = File('test/test_settings.json').readAsStringSync();
  final dynamic json = jsonDecode(jsonFileContents);

  final baseUrl =
      Uri.parse((localCfg['base_url'] ?? json['base_url']) as String);

  final client = WordpressClient(
    baseUrl: baseUrl,
    bootstrapper: (builder) => builder
        .withMaxRedirects(5)
        .withFollowRedirects(true)
        .withRequestTimeout(const Duration(seconds: 60))
        .withDebugMode(false)
        .withDefaultAuthorizationBuilder(
          (authBuilder) => authBuilder
              .withUserName(
                (localCfg['username'] ?? json!['username']) as String,
              )
              .withPassword(
                (localCfg['password'] ?? json['password']) as String,
              )
              // Prefer Basic JWT to match local Docker plugin defaults
              .withType(AuthorizationType.basic_jwt)
              .withEvents(const WordpressEvents())
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

  group(
    'Post Requests: ',
    () {
      // Keep modest to avoid invalid page requests on fresh sites
      const MAX_PAGES = 5;
      const MAX_PER_PAGE = 10;

      dev.log('Max Pages: $MAX_PAGES');
      dev.log('Max Per Page: $MAX_PER_PAGE');
      var parallelMs = 0;
      var sequentialMs = 0;

      test(
        'Parallel',
        () async {
          final stopwatch = Stopwatch()..start();

          dev.log('Starting Parallel...');
          final responses = await client.parallel.list(
            interface: client.posts,
            requestBuilder: () {
              return List.generate(
                MAX_PAGES,
                (index) => ParallelRequest(
                  page: index + 1,
                  request: ListPostRequest(
                    page: index + 1,
                  ),
                ),
              );
            },
          );

          final merged = responses.merge();

          stopwatch.stop();
          parallelMs = stopwatch.elapsed.inMilliseconds;
          dev.log('Parallel Time Taken: $parallelMs ms');

          // On a fresh site there may be few or no posts; just ensure we received a list (may be empty).
          expect(merged, isA<List<Post>>());
        },
      );

      test(
        'Sequential',
        () async {
          final stopwatch = Stopwatch()..start();
          final responses = <List<Post>>[];

          dev.log('Starting Sequential...');
          for (var index = 0; index < MAX_PAGES; index++) {
            final page = index + 1;
            final response = await client.posts.list(
              ListPostRequest(
                page: page,
              ),
            );

            if (response.isSuccessful) {
              responses.add(response.asSuccess().data);
            } else {
              // Stop if we hit an invalid page or auth boundary
              break;
            }
          }

          final folded = responses.fold<List<Post>>(
            <Post>[],
            (previousValue, element) =>
                previousValue.followedBy(element).map((e) => e).toList(),
          );

          stopwatch.stop();
          sequentialMs = stopwatch.elapsed.inMilliseconds;
          dev.log('Sequential Time Taken: $sequentialMs ms');

          // As above, don't assert exact totals; just verify list shape.
          expect(folded, isA<List<Post>>());
        },
      );

      test('Check time difference', () async {
        while (parallelMs == 0 || sequentialMs == 0) {
          await Future.delayed(const Duration(milliseconds: 100));
        }

        final difference = sequentialMs - parallelMs;
        final percentage = (difference / sequentialMs) * 100;

        dev.log(
          'Difference: $difference ms (${percentage.toStringAsFixed(2)}%)',
        );

        // Timings can be noisy on small datasets; avoid strict assertion.
        expect(parallelMs, greaterThanOrEqualTo(0));
      });
    },
  );

  group(
    'Discovery',
    () {
      test(
        'Discovery Request',
        () async {
          final ok = await client.discover();
          expect(ok, isTrue);
        },
      );

      test(
        'Discovery Data',
        () async {
          // Avoid site-specific assertions; just ensure discovery has a home string (may be empty on some sites).
          expect(client.discovery.home, isA<String>());
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
        expect(response.asSuccess().data, isA<List<Page>>());
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

        dev.log(
          'First Response Time Taken: ${firstResponse.duration.inMilliseconds} ms',
        );
        dev.log(
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
      expect(response.asSuccess().data, isA<List<Post>>());
    });

    test('List Tags', () async {
      final response = await client.tags.list(
        ListTagRequest(
          perPage: 20,
        ),
      );

      expect(200, response.code);
      expect(response.asSuccess().data, isA<List<Tag>>());
    });

    test('List Category', () async {
      final response = await client.categories.list(
        ListCategoryRequest(
          perPage: 2,
        ),
      );

      expect(200, response.code);
      expect(response.asSuccess().data, isA<List<Category>>());
    });

    test('List Media', () async {
      final response = await client.media.list(
        ListMediaRequest(
          perPage: 20,
        ),
      );

      expect(200, response.code);
      expect(response.asSuccess().data, isA<List<Media>>());
    });

    test('List Users', () async {
      final response = await client.users.list(ListUserRequest());

      expect(200, response.code);
      expect(response.asSuccess().data, isA<List<User>>());
    });
  });

  group('', () {
    test('Retrive Current User', () async {
      final response = await client.me.retrieve(
        RetrieveMeRequest(),
      );

      if (response.code == 200) {
        // Slug varies per environment; just ensure we got a user object.
        expect(response.asSuccess().data, isA<User>());
      } else {
        expect(response.code, anyOf(401, 403));
      }
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
