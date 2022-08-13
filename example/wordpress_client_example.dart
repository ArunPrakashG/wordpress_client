// ignore_for_file: avoid_redundant_argument_values, omit_local_variable_types, avoid_print

import 'package:wordpress_client/requests.dart';
import 'package:wordpress_client/responses.dart';
import 'package:wordpress_client/src/requests/list/list_search.dart';
import 'package:wordpress_client/wordpress_client.dart';

Future<void> main() async {
  WordpressClient client;

  // Simple Usage
  client = WordpressClient.initialize(
    'https://example.com/',
    'wp-json/wp/v2',
    bootstrapper: (bootstrapper) => bootstrapper.withDebugMode(true).build(),
  );

  WordpressResponse<List<Search>?> userResponse = await client.search.list(
    WordpressRequest(
      requestData: ListSearchRequest()
        ..page = 1
        ..perPage = 10
        ..search = 'test',
    ),
  );

  print(userResponse.message);

  if (userResponse.isSuccess) {
    for (final user in userResponse.data!) {
      print(user.title);
    }
  }
}
