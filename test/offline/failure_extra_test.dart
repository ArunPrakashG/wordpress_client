import 'package:test/test.dart';
import 'package:wordpress_client/testing.dart';
import 'package:wordpress_client/wordpress_client.dart';

import 'support.dart';

class _Tagger extends IWordpressMiddleware {
  const _Tagger();

  @override
  String get name => 'Tagger';

  @override
  Future<void> onLoad() async {}

  @override
  Future<WordpressRequest> onRequest(WordpressRequest request) async {
    return request.copyWith(extra: {...request.extra, 'tag': 'seen'});
  }

  @override
  Future<WordpressRawResponse> onResponse(WordpressRawResponse response) async {
    return response;
  }

  @override
  Future<void> onUnload() async {}
}

void main() {
  test('transport failures keep what request middlewares put in extra',
      () async {
    final adapter = MockWordpressAdapter()
      ..reply('GET', '/posts', MockResponse.timeout());
    final client = makeClient(adapter, middlewares: const [_Tagger()]);

    final response = await client.posts.list(ListPostRequest());

    expect(response, isA<WordpressFailureResponse<List<Post>>>());
    expect(response.code, -RequestErrorType.timeout.index);
    expect(response.extra?['tag'], 'seen');
  });
}
