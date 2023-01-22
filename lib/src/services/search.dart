import '../../operations.dart';
import '../../responses.dart';
import '../library_exports.dart';
import '../requests/list/list_search.dart';

class SearchService extends IWordpressService
    with ListMixin<Search, ListSearchRequest> {}
