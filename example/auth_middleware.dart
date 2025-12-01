import 'package:wordpress_client/wordpress_client.dart';

final class AuthMiddleware extends IWordpressMiddleware {
  @override
  Future<void> onLoad() async {
    // Handle some logic for persistance here or anything else
  }

  @override
  String get name => 'AuthMiddleware';

  @override
  Future<WordpressRequest> onRequest(WordpressRequest request) async {
    return request.copyWith(
      headers: {
        'Authorization': 'Bearer YOUR_TOKEN HERE',
      },
    );
  }

  @override
  Future<WordpressRawResponse> onResponse(WordpressRawResponse response) async {
    return response;
  }

  @override
  Future<void> onUnload() async {
    // Some logic to save the key maybe?
  }
}
