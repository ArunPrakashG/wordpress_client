import 'dart:async';

import '../../wordpress_client.dart';

typedef ParallelResultTransformer<T> = FutureOr<ParallelResult<T>> Function(
  WordpressResponse<List<T>> response,
);

typedef ParallelExceptionHandler<T> = FutureOr<ParallelResult<T>> Function(
  Object error,
);

typedef RequestBuilder<T> = FutureOr<List<ParallelRequest<T>>> Function();

typedef ParallelInitialItems<T> = FutureOr<List<T>> Function();
