import 'package:meta/meta.dart';

import 'library_exports.dart';
import 'responses/wordpress_error.dart';
import 'utilities/codable_map/codable_map.dart';

abstract base class IRequestExecutor {
  Uri get baseUrl;

  void configure(BootstrapConfiguration configuration);

  @internal
  Future<WordpressResponse<T>> create<T>(
    WordpressRequest request,
  ) async {
    final rawResponse = await executeGuarded<WordpressRawResponse>(
      function: () async => execute(request),
      onError: (error, stackTrace) async {
        return WordpressRawResponse(
          data: null,
          code: -RequestErrorType.internalGenericError.index,
          extra: <String, dynamic>{
            'error': error,
            'stackTrace': stackTrace,
          },
          message: '$error\n\n$stackTrace',
        );
      },
    );

    return rawResponse.map<T>(
      onSuccess: (response) {
        final decoder = CodableMap.getDecoder<T>();
        final data = decoder(response.data);

        return WordpressSuccessResponse<T>(
          data: data,
          code: response.code,
          rawData: response.data,
          extra: response.extra,
          requestHeaders: response.requestHeaders,
          headers: response.headers,
          duration: response.duration,
          message: response.message,
        );
      },
      onFailure: (response) {
        final error = mapGuarded(
          mapper: WordpressError.fromMap,
          json: response.data,
        );

        return WordpressFailureResponse<T>(
          error: error,
          code: response.code,
          rawData: response.data,
          headers: response.headers,
          duration: response.duration,
          extra: response.extra,
          requestHeaders: response.requestHeaders,
          message: response.message,
        );
      },
    );
  }

  @internal
  Future<WordpressResponse<T>> retrive<T>(
    WordpressRequest request,
  ) async {
    final rawResponse = await executeGuarded<WordpressRawResponse>(
      function: () async => execute(request),
      onError: (error, stackTrace) async {
        return WordpressRawResponse(
          data: null,
          code: -RequestErrorType.internalGenericError.index,
          extra: <String, dynamic>{
            'error': error,
            'stackTrace': stackTrace,
          },
          message: '$error\n\n$stackTrace',
        );
      },
    );

    return rawResponse.map<T>(
      onSuccess: (response) {
        final decoder = CodableMap.getDecoder<T>();
        final data = decoder(response.data);

        return WordpressSuccessResponse<T>(
          data: data,
          code: response.code,
          rawData: response.data,
          headers: response.headers,
          extra: response.extra,
          requestHeaders: response.requestHeaders,
          duration: response.duration,
          message: response.message,
        );
      },
      onFailure: (response) {
        final error = mapGuarded(
          mapper: WordpressError.fromMap,
          json: response.data,
        );

        return WordpressFailureResponse<T>(
          error: error,
          code: response.code,
          headers: response.headers,
          rawData: response.data,
          duration: response.duration,
          extra: response.extra,
          requestHeaders: response.requestHeaders,
          message: response.message,
        );
      },
    );
  }

  @internal
  Future<WordpressResponse<bool>> delete(
    WordpressRequest request,
  ) async {
    final rawResponse = await executeGuarded<WordpressRawResponse>(
      function: () async => execute(request),
      onError: (error, stackTrace) async {
        return WordpressRawResponse(
          data: null,
          code: -RequestErrorType.internalGenericError.index,
          extra: <String, dynamic>{
            'error': error,
            'stackTrace': stackTrace,
          },
          message: '$error\n\n$stackTrace',
        );
      },
    );

    return rawResponse.map(
      onSuccess: (response) {
        return WordpressSuccessResponse(
          data: true,
          code: response.code,
          headers: response.headers,
          rawData: response.data,
          extra: response.extra,
          requestHeaders: response.requestHeaders,
          duration: response.duration,
          message: response.message,
        );
      },
      onFailure: (response) {
        final error = mapGuarded(
          mapper: WordpressError.fromMap,
          json: response.data,
        );

        return WordpressFailureResponse(
          error: error,
          code: response.code,
          headers: response.headers,
          rawData: response.data,
          duration: response.duration,
          extra: response.extra,
          requestHeaders: response.requestHeaders,
          message: response.message,
        );
      },
    );
  }

  @internal
  Future<WordpressResponse<List<T>>> list<T>(
    WordpressRequest request,
  ) async {
    final rawResponse = await executeGuarded<WordpressRawResponse>(
      function: () async => execute(request),
      onError: (error, stackTrace) async {
        return WordpressRawResponse(
          data: null,
          code: -RequestErrorType.internalGenericError.index,
          extra: <String, dynamic>{
            'error': error,
            'stackTrace': stackTrace,
          },
          message: '$error\n\n$stackTrace',
        );
      },
    );

    return rawResponse.map<List<T>>(
      onSuccess: (response) {
        final decoder = CodableMap.getDecoder<T>();
        final data = (response.data as Iterable<dynamic>).map(decoder).toList();

        return WordpressSuccessResponse<List<T>>(
          data: data,
          code: response.code,
          extra: response.extra,
          rawData: response.data,
          requestHeaders: response.requestHeaders,
          headers: response.headers,
          duration: response.duration,
          message: response.message,
        );
      },
      onFailure: (response) {
        final error = mapGuarded(
          mapper: WordpressError.fromMap,
          json: response.data,
        );

        return WordpressFailureResponse(
          error: error,
          code: response.code,
          headers: response.headers,
          rawData: response.data,
          extra: response.extra,
          requestHeaders: response.requestHeaders,
          duration: response.duration,
          message: response.message,
        );
      },
    );
  }

  @internal
  Future<WordpressResponse<T>> update<T>(
    WordpressRequest request,
  ) async {
    final rawResponse = await executeGuarded<WordpressRawResponse>(
      function: () async => execute(request),
      onError: (error, stackTrace) async {
        return WordpressRawResponse(
          data: null,
          code: -RequestErrorType.internalGenericError.index,
          extra: <String, dynamic>{
            'error': error,
            'stackTrace': stackTrace,
          },
          message: '$error\n\n$stackTrace',
        );
      },
    );

    return rawResponse.map(
      onSuccess: (response) {
        final decoder = CodableMap.getDecoder<T>();
        final data = decoder(response.data);

        return WordpressSuccessResponse<T>(
          data: data,
          code: response.code,
          extra: response.extra,
          rawData: response.data,
          requestHeaders: response.requestHeaders,
          headers: response.headers,
          duration: response.duration,
          message: response.message,
        );
      },
      onFailure: (response) {
        final error = mapGuarded(
          mapper: WordpressError.fromMap,
          json: response.data,
        );

        return WordpressFailureResponse(
          error: error,
          code: response.code,
          headers: response.headers,
          rawData: response.data,
          duration: response.duration,
          extra: response.extra,
          requestHeaders: response.requestHeaders,
          message: response.message,
        );
      },
    );
  }

  /// Executes the given [request] on the associated base url and returns the result in raw format.
  @internal
  Future<WordpressRawResponse> execute(WordpressRequest request);
}
