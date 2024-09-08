import 'cache_exception_base.dart';

final class CacheExpiredException extends CacheExceptionBase {
  const CacheExpiredException({
    super.cause,
    super.message = 'Cache expired',
  });
}
