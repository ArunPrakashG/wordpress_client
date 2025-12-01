import 'cache_exception_base.dart';

final class CacheNotExistsException extends CacheExceptionBase {
  const CacheNotExistsException({
    super.cause,
    super.message = 'Cache with the specified key does not exist.',
  });
}
