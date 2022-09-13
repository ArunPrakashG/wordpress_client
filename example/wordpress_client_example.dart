// ignore_for_file: avoid_redundant_argument_values, omit_local_variable_types, avoid_print

import 'dart:convert';

import 'package:wordpress_client/requests.dart';
import 'package:wordpress_client/responses.dart';
import 'package:wordpress_client/wordpress_client.dart';

Future<void> main() async {
  WordpressClient client;

  // Simple Usage
  client = WordpressClient.initialize(
    'https://example.com/',
    'wp-json/wp/v2',
    bootstrapper: (bootstrapper) => bootstrapper.withDebugMode(false).build(),
  );

  WordpressResponse<Media?> mediaResponse = await client.media.retrive(
    WordpressRequest(
      requestData: RetriveMediaRequest(
        id: 0,
      ),
    ),
  );

  print(jsonEncode(mediaResponse.data));
}
