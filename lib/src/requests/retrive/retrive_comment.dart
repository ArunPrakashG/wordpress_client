import '../../enums.dart';
import '../../utilities/helpers.dart';
import '../request_content.dart';
import '../request_interface.dart';

class RetriveCommentRequest implements IRequest {
  RetriveCommentRequest({
    this.context,
    this.password,
    required this.id,
  });

  FilterContext? context;
  String? password;
  int id;

  @override
  void build(RequestContent requestContent) {
    requestContent.queryParameters
      ..addIfNotNull('context', context?.name)
      ..addIfNotNull('password', password);

    requestContent.endpoint = 'comments';
    requestContent.method = HttpMethod.get;
  }
}
