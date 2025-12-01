import '../../responses/wordpress_response.dart';

extension ResponseExtensions<T> on WordpressResponse<T> {
  bool get isSuccessful => this is WordpressSuccessResponse<T>;

  bool get isFailure => this is WordpressFailureResponse;

  WordpressSuccessResponse<T> asSuccess() {
    if (this is! WordpressSuccessResponse<T>) {
      throw StateError('Response is not a success response');
    }

    return this as WordpressSuccessResponse<T>;
  }

  WordpressFailureResponse asFailure() {
    if (this is! WordpressFailureResponse) {
      throw StateError('Response is not a failure response');
    }

    return this as WordpressFailureResponse;
  }

  T? dataOrNull() {
    if (isFailure) {
      return null;
    }

    return asSuccess().data;
  }

  R map<R>({
    required R Function(WordpressSuccessResponse<T> response) onSuccess,
    required R Function(WordpressFailureResponse response) onFailure,
  }) {
    if (isFailure) {
      return onFailure(asFailure());
    }

    return onSuccess(asSuccess());
  }

  R? mapOrNull<R>({
    required R Function(WordpressSuccessResponse<T> response) onSuccess,
    R? Function(WordpressFailureResponse response)? onFailure,
  }) {
    if (isFailure) {
      return onFailure?.call(asFailure());
    }

    return onSuccess(asSuccess());
  }
}
