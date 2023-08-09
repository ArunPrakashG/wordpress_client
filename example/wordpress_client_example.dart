// ignore_for_file: avoid_print

import 'package:wordpress_client/wordpress_client.dart';

import 'my_request/my_interface.dart';
import 'my_request/my_response.dart';

Future<void> main() async {
  final baseUrl = Uri.parse('https://example.com/wp-json/wp/v2');

  // Simple Usage
  final client = WordpressClient(
    baseUrl: baseUrl,
  );

  client.initialize();

  final response = await client.media.create(
    CreateMediaRequest(
      mediaFilePath: 'sample.jpg',
      authorization: UsefulJwtAuth(
        userName: 'john_doe',
        password: 'password',
      ),
    ),
  );

  response.map<void>(
    onSuccess: (response) {},
    onFailure: (response) {
      print(response.error.toString());
    },
  );

  client.register<MyInterface, MyResponse>(
    interface: MyInterface(),
    decoder: MyResponse.fromJson,
    encoder: (instance) => (instance as MyResponse).toJson(),
    key: 'my_interface', // Optional
    overriteIfTypeExists: true, // Optional
  );
}
