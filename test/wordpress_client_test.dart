import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';
import 'package:wordpress_client/wordpress_client.dart';

void main() async {
  WordpressClient client;
  Map<String, dynamic> json;

  json = jsonDecode(await (await File('example/test_settings.json')).readAsString());
  client = WordpressClient(
    json['base_url'],
    json['path'],
    bootstrapper: (builder) => builder
        .withDefaultMaxRedirects(5)
        .withFollowRedirects(true)
        .withRequestTimeout(60)
        .withDefaultAuthorization(
          (authBuilder) => authBuilder.withUserName(json['username']).withPassword(json['password']).withType(AuthorizationType.JWT).build(),
        )
        .build(),
  );

  test('List Posts', () async {
    final response = await client.listPost(
      (builder) => builder.withPerPage(20).withPageNumber(1).withCallback(
        Callback(
          requestErrorCallback: (error) {
            print('Request error: ${error.errorResponse.message}');
          },
        ),
      ).build(),
    );

    expect(200, response.responseCode);
    expect(20, response.value.length);
  });

  test('Retrive Post', () async {
    final response = await client.retrivePost(
      (builder) => builder.withPostId(468894).withCallback(
        Callback(
          requestErrorCallback: (error) {
            print('Request error: ${error.errorResponse.message}');
          },
        ),
      ).build(),
    );

    expect(200, response.responseCode);
    expect(468894, response.value.id);
    
  });
}
