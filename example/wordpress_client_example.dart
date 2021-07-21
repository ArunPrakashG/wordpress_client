import 'dart:convert';
import 'dart:io';

import 'package:wordpress_client/src/responses/user_response.dart';
import 'package:wordpress_client/wordpress_client.dart';

void main() async {
  File file = await File('example/test_settings.json');
  final json = jsonDecode(await file.readAsString());

  WordpressClient client = WordpressClient(
    json['base_url'],
    json['path'],
    bootstrapper: (builder) => builder
        .withDefaultMaxRedirects(5)
        .withFollowRedirects(true)
        .withRequestTimeout(60)
        .withDefaultAuthorization(
          Authorization(userName: json['username'], password: json['password'], authType: AuthorizationType.JWT),
        )
        .build(),
  );

  final response = await client.retrivePost((builder) => builder.withPostId(45565).withCallback(
        Callback(
          requestErrorCallback: (error) {
            print('Request error: ${error.errorResponse.message}');
          },
        ),
      ).build());

  print('Request completed in ${response?.duration?.inSeconds} second(s)');
  print('Status Code: ${response.responseCode}');
  print('Content: ${response.value?.content?.parsedText}');
}
