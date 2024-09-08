import 'dart:async';

import '../../wordpress_client.dart';

typedef ParallelIterableResultTransformer<T>
    = FutureOr<ParallelIterableResult<T>> Function(
  WordpressResponse<List<T>> response,
);

typedef ParallelResultTransformer<T> = FutureOr<ParallelResult<T>> Function(
  WordpressResponse<T> response,
);

typedef ParallelIterableExceptionHandler<T>
    = FutureOr<ParallelIterableResult<T>> Function(
  Object error,
);

typedef ParallelExceptionHandler<T> = FutureOr<ParallelResult<T>> Function(
  Object error,
);

typedef RequestBuilder<T> = FutureOr<List<ParallelRequest<T>>> Function();

typedef ParallelInitialItems<T> = FutureOr<List<T>> Function();
typedef ParallelInitialItem<T> = FutureOr<T> Function();
