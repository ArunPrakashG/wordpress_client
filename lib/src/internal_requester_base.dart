import 'package:meta/meta.dart';

import 'codable_map.dart';
import 'library_exports.dart';
import 'responses/wordpress_error.dart';
import 'responses/wordpress_raw_response.dart';

abstract base class IRequestExecutor {
  Uri get baseUrl;

  void configure(BootstrapConfiguration configuration);

  Future<WordpressResponse<T>> create<T>(
    WordpressRequest request,
  ) async {
    final rawResponse = await execute(request);

    return rawResponse.map<T>(
      onSuccess: (response) {
        final decoder = CodableMap.getDecoder<T>();
        final data = decoder(response.data);

        return WordpressSuccessResponse<T>(
          data: data,
          code: response.code,
          headers: response.headers,
          duration: response.duration,
          message: response.message,
        );
      },
      onFailure: (response) {
        final error = WordpressError.fromMap(response.data);

        return WordpressFailureResponse<T>(
          error: error,
          code: response.code,
          headers: response.headers,
          duration: response.duration,
          message: response.message,
        );
      },
    );
  }

  Future<WordpressResponse<T>> retrive<T>(
    WordpressRequest request,
  ) async {
    final rawResponse = await execute(request);

    return rawResponse.map<T>(
      onSuccess: (response) {
        final decoder = CodableMap.getDecoder<T>();
        final data = decoder(response.data);

        return WordpressSuccessResponse<T>(
          data: data,
          code: response.code,
          headers: response.headers,
          duration: response.duration,
          message: response.message,
        );
      },
      onFailure: (response) {
        final error = WordpressError.fromMap(response.data);

        return WordpressFailureResponse<T>(
          error: error,
          code: response.code,
          headers: response.headers,
          duration: response.duration,
          message: response.message,
        );
      },
    );
  }

  Future<WordpressResponse<bool>> delete(
    WordpressRequest request,
  ) async {
    final rawResponse = await execute(request);

    return rawResponse.map(
      onSuccess: (response) {
        return WordpressSuccessResponse(
          data: true,
          code: response.code,
          headers: response.headers,
          duration: response.duration,
          message: response.message,
        );
      },
      onFailure: (response) {
        final error = WordpressError.fromMap(response.data);

        return WordpressFailureResponse(
          error: error,
          code: response.code,
          headers: response.headers,
          duration: response.duration,
          message: response.message,
        );
      },
    );
  }

  Future<WordpressResponse<List<T>>> list<T>(
    WordpressRequest request,
  ) async {
    final rawResponse = await execute(request);

    return rawResponse.map<List<T>>(
      onSuccess: (response) {
        final decoder = CodableMap.getDecoder<List<T>>();
        final data = decoder(response.data);

        return WordpressSuccessResponse<List<T>>(
          data: data,
          code: response.code,
          headers: response.headers,
          duration: response.duration,
          message: response.message,
        );
      },
      onFailure: (response) {
        final error = WordpressError.fromMap(response.data);

        return WordpressFailureResponse(
          error: error,
          code: response.code,
          headers: response.headers,
          duration: response.duration,
          message: response.message,
        );
      },
    );
  }

  Future<WordpressResponse<T>> update<T>(
    WordpressRequest request,
  ) async {
    final rawResponse = await execute(request);

    return rawResponse.map(
      onSuccess: (response) {
        final decoder = CodableMap.getDecoder<T>();
        final data = decoder(response.data);

        return WordpressSuccessResponse<T>(
          data: data,
          code: response.code,
          headers: response.headers,
          duration: response.duration,
          message: response.message,
        );
      },
      onFailure: (response) {
        final error = WordpressError.fromMap(response.data);

        return WordpressFailureResponse(
          error: error,
          code: response.code,
          headers: response.headers,
          duration: response.duration,
          message: response.message,
        );
      },
    );
  }

  @protected
  Future<WordpressRawResponse> execute(WordpressRequest request);
}
